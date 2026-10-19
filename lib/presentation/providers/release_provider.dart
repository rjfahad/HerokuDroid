import 'package:flutter/foundation.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/models/release.dart';
import 'package:herokudroid/data/repositories/app_repository.dart';
import 'package:herokudroid/data/services/cache_service.dart';

/// Provider for release/deploy history state management
class ReleaseProvider extends ChangeNotifier {
  final AppRepository _repository;
  final CacheService _cacheService;

  ReleaseProvider({
    required AppRepository repository,
    required CacheService cacheService,
  }) : _repository = repository,
       _cacheService = cacheService;

  List<Release> _releases = [];
  bool _isLoading = false;
  String? _error;

  List<Release> get releases => _releases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasReleases => _releases.isNotEmpty;

  /// Load releases for an app
  Future<void> loadReleases(String appId) async {
    // Try to load from cache first
    final cachedReleases = await _cacheService.getCachedReleases(appId);
    if (cachedReleases != null) {
      _releases = cachedReleases;
      // Sort by version descending (newest first)
      _releases.sort((a, b) => b.version.compareTo(a.version));
      _isLoading = false;
      _error = null;
      notifyListeners();

      // Load from network in background to refresh
      _loadReleasesFromNetwork(appId);
      return;
    }

    // No cache, load from network with loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _loadReleasesFromNetwork(appId);
  }

  /// Load releases from network and update cache
  Future<void> _loadReleasesFromNetwork(String appId) async {
    try {
      _releases = await _repository.getReleases(appId);
      // Sort by version descending (newest first)
      _releases.sort((a, b) => b.version.compareTo(a.version));
      _error = null;

      // Cache the results
      await _cacheService.cacheReleases(appId, _releases);
    } on HerokuException catch (e) {
      _error = e.message;
      _releases = [];
    } catch (e) {
      _error = 'Failed to load releases: ${e.toString()}';
      _releases = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh releases
  Future<void> refreshReleases(String appId) async {
    await loadReleases(appId);
  }

  /// Roll back to a previous release, then reload the deploy history
  Future<bool> rollbackRelease(String appId, String releaseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.rollbackRelease(appId, releaseId);
      await _loadReleasesFromNetwork(appId);
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to roll back: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
