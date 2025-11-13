import 'package:flutter/foundation.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/repositories/auth_repository.dart';

/// Provider for authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  /// Check if user is already authenticated on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isAuthenticated = await _repository.isAuthenticated();
      if (_isAuthenticated) {
        _token = await _repository.getToken();

        // Validate the token
        final isValid = await _repository.validateToken();
        if (!isValid) {
          _isAuthenticated = false;
          _token = null;
          await _repository.logout();
        }
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with API token
  Future<Map<String, dynamic>> login(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(token);
      _isAuthenticated = true;
      _token = token;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'data': result};
    } on HerokuException catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      _token = null;
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.message};
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _isAuthenticated = false;
      _token = null;
      _error = null;
    } catch (e) {
      _error = 'Failed to logout: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Validate current token
  Future<bool> validateCurrentToken() async {
    try {
      final isValid = await _repository.validateToken();
      if (!isValid) {
        _isAuthenticated = false;
        _token = null;
        notifyListeners();
      }
      return isValid;
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      notifyListeners();
      return false;
    }
  }
}
