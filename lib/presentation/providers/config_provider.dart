import 'package:flutter/foundation.dart';
import 'package:herokuandroid/data/repositories/config_repository.dart';
import 'package:herokuandroid/data/services/cache_service.dart';

/// Provider for config vars state management
class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _repository;
  final CacheService _cacheService;

  ConfigProvider({
    required ConfigRepository repository,
    required CacheService cacheService,
  }) : _repository = repository,
       _cacheService = cacheService;

  Map<String, String> _configVars = {};
  bool _isLoading = false;
  String? _error;

  Map<String, String> get configVars => _configVars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load config vars for an app
  Future<void> loadConfigVars(String appId, {bool forceRefresh = false}) async {
    // Try to load from cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedVars = _cacheService.getCachedConfigVars(appId);
      if (cachedVars != null) {
        _configVars = cachedVars;
        _error = null;
        notifyListeners();
        // Still fetch fresh data in background
        _loadConfigVarsFromNetwork(appId);
        return;
      }
    }

    // No cache or force refresh - show loading
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _loadConfigVarsFromNetwork(appId);
  }

  /// Load config vars from network and cache them
  Future<void> _loadConfigVarsFromNetwork(String appId) async {
    try {
      _configVars = await _repository.getConfigVars(appId);
      await _cacheService.cacheConfigVars(appId, _configVars);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (_configVars.isEmpty) {
        _configVars = {};
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add or update a config var
  Future<bool> setConfigVar(String appId, String key, String value) async {
    try {
      _configVars = await _repository.setConfigVar(appId, key, value);
      await _cacheService.cacheConfigVars(appId, _configVars);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a config var
  Future<bool> deleteConfigVar(String appId, String key) async {
    try {
      _configVars = await _repository.deleteConfigVar(appId, key);
      await _cacheService.cacheConfigVars(appId, _configVars);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _configVars = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
