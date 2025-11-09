import 'package:flutter/foundation.dart';
import 'package:herokuandroid/data/repositories/config_repository.dart';

/// Provider for config vars state management
class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _repository;

  ConfigProvider({required ConfigRepository repository})
    : _repository = repository;

  Map<String, String> _configVars = {};
  bool _isLoading = false;
  String? _error;

  Map<String, String> get configVars => _configVars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load config vars for an app
  Future<void> loadConfigVars(String appId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _configVars = await _repository.getConfigVars(appId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _configVars = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add or update a config var
  Future<bool> setConfigVar(String appId, String key, String value) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _configVars = await _repository.setConfigVar(appId, key, value);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a config var
  Future<bool> deleteConfigVar(String appId, String key) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _configVars = await _repository.deleteConfigVar(appId, key);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
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
