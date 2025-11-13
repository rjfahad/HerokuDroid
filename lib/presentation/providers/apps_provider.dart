import 'package:flutter/foundation.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/data/repositories/app_repository.dart';
import 'package:herokudroid/data/services/cache_service.dart';

/// Provider for apps state management
class AppsProvider extends ChangeNotifier {
  final AppRepository _repository;
  final CacheService _cacheService;

  AppsProvider({
    required AppRepository repository,
    required CacheService cacheService,
  }) : _repository = repository,
       _cacheService = cacheService;

  List<App> _apps = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<App> get apps => _filteredApps;
  List<App> get allApps => _apps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasApps => _apps.isNotEmpty;

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
