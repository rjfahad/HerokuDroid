import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';

/// Repository for authentication operations
class AuthRepository {
  final HerokuApiService _apiService;
  final SecureStorageService _storageService;

  AuthRepository({
    required HerokuApiService apiService,
    required SecureStorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    try {
      return await _storageService.hasToken();
    } catch (e) {
      return false;
    }
  }

  /// Get current auth token
  Future<String?> getToken() async {
    try {
      return await _storageService.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Login with API token
  Future<void> login(String token) async {
    if (token.trim().isEmpty) {
      throw ValidationException(message: 'API token cannot be empty');
    }

    // Save token temporarily
    await _storageService.saveToken(token);

    // Test if token is valid by making a test API call
    try {
      final isValid = await _apiService.testConnection();
      if (!isValid) {
        // Token is invalid, clear it
        await _storageService.deleteToken();
        throw AuthenticationException.invalidToken();
      }
    } catch (e) {
      // If test fails, clear the token
      await _storageService.deleteToken();
      if (e is HerokuException) {
        rethrow;
      }
      throw AuthenticationException(
        message: 'Failed to validate token: ${e.toString()}',
      );
    }
  }

  /// Logout (clear token)
  Future<void> logout() async {
    try {
      await _storageService.deleteToken();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    try {
      final hasToken = await _storageService.hasToken();
      if (!hasToken) return false;

      return await _apiService.testConnection();
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw Exception('Failed to clear auth data: $e');
    }
  }
}
