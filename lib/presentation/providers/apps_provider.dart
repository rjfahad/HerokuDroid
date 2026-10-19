import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/data/repositories/app_repository.dart';
import 'package:herokudroid/data/services/cache_service.dart';

/// Provider for apps state management
class AppsProvider extends ChangeNotifier {
  final AppRepository _repository;
  final CacheService _cacheService;
  final SharedPreferences _prefs;

  AppsProvider({
    required AppRepository repository,
    required CacheService cacheService,
    required SharedPreferences prefs,
  }) : _repository = repository,
       _cacheService = cacheService,
       _prefs = prefs {
    _showLiveStatus = _prefs.getBool(_liveStatusKey) ?? true;
  }

  /// Above this many apps we stop eagerly enriching every card and instead
  /// fetch status lazily for the cards that are actually rendered.
  static const int autoEnrichLimit = 40;

  /// Max simultaneous formation requests.
  static const int _enrichConcurrency = 6;

  /// How long a per-app dyno summary is considered fresh.
  static const Duration _summaryTtl = Duration(seconds: 90);

  static const String _liveStatusKey = 'show_live_status';

  List<App> _apps = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _showLiveStatus = true;

  final Map<String, _DynoSummary> _summaryCache = {};
  final Set<String> _inFlight = {};

  List<App> get apps => _filteredApps;
  List<App> get allApps => _apps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasApps => _apps.isNotEmpty;
  bool get showLiveStatus => _showLiveStatus;

  /// Get filtered apps based on search query
  List<App> get _filteredApps {
    if (_searchQuery.isEmpty) {
      return _apps;
    }

    final query = _searchQuery.toLowerCase();
    return _apps.where((app) {
      return app.name.toLowerCase().contains(query) ||
          (app.region?.toLowerCase().contains(query) ?? false) ||
          (app.stack?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Load all apps
  Future<void> loadApps({bool forceRefresh = false}) async {
    if (forceRefresh) {
      // Drop freshness so status is refetched.
      _summaryCache.clear();
    }

    // Try to load from cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedApps = _cacheService.getCachedApps();
      if (cachedApps != null) {
        _apps = cachedApps;
        _error = null;
        notifyListeners();
        // Still fetch fresh data in background
        _loadAppsFromNetwork();
        return;
      }
    }

    // No cache or force refresh - show loading
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _loadAppsFromNetwork();
  }

  /// Load apps from network and cache them
  Future<void> _loadAppsFromNetwork() async {
    try {
      _apps = await _repository.getApps();

      await _cacheService.cacheApps(_apps);
      _error = null;
    } on HerokuException catch (e) {
      _error = e.message;
      if (_apps.isEmpty) {
        // Only clear apps if we don't have cached data
        _apps = [];
      }
    } catch (e) {
      _error = 'Failed to load apps: ${e.toString()}';
      if (_apps.isEmpty) {
        _apps = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Derive per-app status from the dyno formation in the background.
    await _enrichDynoInfo();
  }

  /// Attach per-app dyno summaries so the dashboard can show real
  /// running/stopped status.
  ///
  /// For large accounts we skip the eager pass entirely and let
  /// [requestEnrichment] fetch status lazily for rendered cards.
  Future<void> _enrichDynoInfo() async {
    if (!_showLiveStatus || _apps.isEmpty) return;
    if (_apps.length > autoEnrichLimit) return;

    final stale = _apps.where(_needsSummary).toList();
    if (stale.isEmpty) return;

    await _forEachConcurrent(stale, _enrichConcurrency, _refreshSummary);

    await _cacheService.cacheApps(_apps);
    notifyListeners();
  }

  /// Fetch status for a single app if it isn't fresh. Safe to call from
  /// an `itemBuilder`; duplicate calls are coalesced.
  Future<void> requestEnrichment(String appId) async {
    if (!_showLiveStatus) return;
    if (_inFlight.contains(appId)) return;

    final index = _apps.indexWhere((a) => a.id == appId);
    if (index == -1) return;
    if (!_needsSummary(_apps[index])) return;

    await _refreshSummary(_apps[index]);
    await _cacheService.cacheApps(_apps);
    notifyListeners();
  }

  bool _needsSummary(App app) {
    final summary = _summaryCache[app.id];
    if (summary == null) return true;
    return DateTime.now().millisecondsSinceEpoch - summary.fetchedAtMs >
        _summaryTtl.inMilliseconds;
  }

  /// Fetch and store a single app's dyno summary. Keeps the last known value
  /// on failure (#5) and records freshness so it isn't hammered.
  Future<void> _refreshSummary(App app) async {
    if (!_inFlight.add(app.id)) return;
    try {
      final formation = await _repository.getFormation(app.id);
      final total = formation.fold<int>(0, (sum, f) => sum + f.quantity);
      final running = formation
          .where((f) => f.isScaled)
          .fold<int>(0, (sum, f) => sum + f.quantity);

      _summaryCache[app.id] = _DynoSummary(
        total: total,
        running: running,
        fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
      );

      final index = _apps.indexWhere((a) => a.id == app.id);
      if (index != -1) {
        _apps[index] = _apps[index].copyWith(
          totalDynos: total,
          runningDynos: running,
        );
      }
    } catch (_) {
      // Keep the previous, possibly cached, summary.
    } finally {
      _inFlight.remove(app.id);
    }
  }

  /// Runs [action] over [items] with at most [limit] in flight at once.
  Future<void> _forEachConcurrent<T>(
    List<T> items,
    int limit,
    Future<void> Function(T item) action,
  ) async {
    if (items.isEmpty) return;
    final queue = List<T>.from(items);
    final workers = limit.clamp(1, queue.length);

    Future<void> run() async {
      while (queue.isNotEmpty) {
        final item = queue.removeAt(0);
        await action(item);
      }
    }

    await Future.wait(List.generate(workers, (_) => run()));
  }

  /// Enable/disable live app-status enrichment and persist the choice.
  Future<void> setShowLiveStatus(bool value) async {
    _showLiveStatus = value;
    await _prefs.setBool(_liveStatusKey, value);
    notifyListeners();

    if (value) {
      await _enrichDynoInfo();
    }
  }

  /// Refresh apps (pull to refresh)
  Future<void> refreshApps() async {
    await loadApps(forceRefresh: true);
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Get specific app by ID
  Future<App?> getApp(String appId) async {
    try {
      return await _repository.getApp(appId);
    } catch (e) {
      _error = 'Failed to load app: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Toggle maintenance mode for an app
  Future<bool> toggleMaintenanceMode(String appId, bool enabled) async {
    try {
      final updatedApp = await _repository.setMaintenanceMode(appId, enabled);

      // Update the app in the list
      final index = _apps.indexWhere((app) => app.id == appId);
      if (index != -1) {
        _apps[index] = updatedApp;
        notifyListeners();
      }

      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to toggle maintenance mode: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Sort apps by name
  void sortByName({bool ascending = true}) {
    _apps.sort((a, b) {
      return ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
    });
    notifyListeners();
  }

  /// Sort apps by date
  void sortByDate({bool ascending = false}) {
    _apps.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return ascending
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!);
    });
    notifyListeners();
  }

  /// Delete an app
  Future<bool> deleteApp(String appId) async {
    try {
      await _repository.deleteApp(appId);

      // Remove from local list
      _apps.removeWhere((app) => app.id == appId);

      // Update cache
      await _cacheService.cacheApps(_apps);

      notifyListeners();
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete app: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Rename an app
  Future<bool> renameApp(String appId, String newName) async {
    try {
      final updatedApp = await _repository.updateAppName(appId, newName);

      // Update in local list
      final index = _apps.indexWhere((app) => app.id == appId);
      if (index != -1) {
        _apps[index] = updatedApp;
      }

      // Update cache
      await _cacheService.cacheApps(_apps);

      notifyListeners();
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to rename app: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

/// Cached dyno summary for a single app.
class _DynoSummary {
  const _DynoSummary({
    required this.total,
    required this.running,
    required this.fetchedAtMs,
  });

  final int total;
  final int running;
  final int fetchedAtMs;
}
