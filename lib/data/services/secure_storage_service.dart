import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:herokudroid/core/constants/app_constants.dart';

/// Service for securely storing sensitive data like API tokens
class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  /// FlutterSecureStorage instance with platform-specific options
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Save API token securely
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  /// Retrieve API token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw Exception('Failed to read token: $e');
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    try {
      return await _storage.containsKey(key: AppConstants.tokenKey);
    } catch (e) {
      throw Exception('Failed to check token: $e');
    }
  }

  /// Delete API token (for logout)
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Generic write method for other keys
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to write $key: $e');
    }
  }

  /// Generic read method for other keys
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw Exception('Failed to read $key: $e');
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete $key: $e');
    }
  }
}
