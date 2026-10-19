import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:herokudroid/core/constants/app_constants.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';
import 'package:local_auth/local_auth.dart';

/// Manages the optional app lock: a locally stored password and, when
/// available, biometric authentication. Nothing here talks to Heroku — the
/// lock only guards access to the already-stored API token.
class AppLockService {
  AppLockService({
    required SecureStorageService storage,
    LocalAuthentication? localAuth,
  }) : _storage = storage,
       _localAuth = localAuth ?? LocalAuthentication();

  final SecureStorageService _storage;
  final LocalAuthentication _localAuth;

  static const int _hashIterations = 10000;

  /// Whether the app lock is enabled.
  Future<bool> isLockEnabled() async {
    try {
      return await _storage.read(AppConstants.appLockEnabledKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Whether biometric unlock is enabled by the user.
  Future<bool> isBiometricsEnabled() async {
    try {
      return await _storage.read(AppConstants.appLockBiometricsKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Whether a lock password has been set.
  Future<bool> hasPassword() async {
    try {
      final hash = await _storage.read(AppConstants.appLockPasswordHashKey);
      return hash != null && hash.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// True when the device can perform a biometric check right now.
  Future<bool> isBiometricsAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Persist the lock settings.
  Future<void> setLockEnabled(bool enabled) => _storage.write(
    AppConstants.appLockEnabledKey,
    enabled ? 'true' : 'false',
  );

  Future<void> setBiometricsEnabled(bool enabled) => _storage.write(
    AppConstants.appLockBiometricsKey,
    enabled ? 'true' : 'false',
  );

  /// Store a salted hash of [password]. The plaintext is never persisted.
  Future<void> setPassword(String password) async {
    final salt = _randomSalt();
    final hash = _hashPassword(password, salt);
    await _storage.write(
      AppConstants.appLockPasswordSaltKey,
      base64Encode(salt),
    );
    await _storage.write(AppConstants.appLockPasswordHashKey, hash);
  }

  /// Verify a password against the stored hash.
  Future<bool> verifyPassword(String password) async {
    try {
      final saltB64 = await _storage.read(AppConstants.appLockPasswordSaltKey);
      final storedHash = await _storage.read(
        AppConstants.appLockPasswordHashKey,
      );
      if (saltB64 == null || storedHash == null) return false;

      final salt = base64Decode(saltB64);
      final candidate = _hashPassword(password, salt);
      return _constantTimeEquals(candidate, storedHash);
    } catch (_) {
      return false;
    }
  }

  /// Remove the stored password (used when disabling the lock).
  Future<void> clearPassword() async {
    await _storage.delete(AppConstants.appLockPasswordHashKey);
    await _storage.delete(AppConstants.appLockPasswordSaltKey);
  }

  /// Show the native biometric prompt. Returns true only on success.
  ///
  /// Failures (including user cancellation) return false; the caller should
  /// surface an error or fall back to the password field.
  Future<bool> authenticateBiometric({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      throw AppLockAuthException(_messageFor(e.code));
    } catch (_) {
      throw const AppLockAuthException(
        'Biometric authentication is unavailable on this device.',
      );
    }
  }

  List<int> _randomSalt([int length = 16]) {
    final rng = Random.secure();
    return List<int>.generate(length, (_) => rng.nextInt(256));
  }

  String _hashPassword(String password, List<int> salt) {
    var digest = sha256.convert([...salt, ...utf8.encode(password)]);
    for (var i = 0; i < _hashIterations; i++) {
      digest = sha256.convert([...salt, ...digest.bytes]);
    }
    return digest.toString();
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  String _messageFor(LocalAuthExceptionCode code) => switch (code) {
    LocalAuthExceptionCode.userCanceled => 'Authentication cancelled.',
    LocalAuthExceptionCode.userRequestedFallback =>
      'Use your app password to unlock.',
    LocalAuthExceptionCode.noCredentialsSet =>
      'No biometrics enrolled. Use your app password.',
    LocalAuthExceptionCode.noBiometricsEnrolled =>
      'No biometrics enrolled. Use your app password.',
    LocalAuthExceptionCode.noBiometricHardware =>
      'This device has no biometric hardware.',
    LocalAuthExceptionCode.temporaryLockout ||
    LocalAuthExceptionCode.biometricLockout =>
      'Biometrics are locked. Unlock your device or use your app password.',
    _ => 'Biometric authentication failed. Use your app password.',
  };
}

/// Thrown when a biometric prompt cannot complete, carrying a user-facing
/// message.
class AppLockAuthException implements Exception {
  const AppLockAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
