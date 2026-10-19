import 'package:flutter/foundation.dart';
import 'package:herokudroid/core/constants/app_constants.dart';
import 'package:herokudroid/data/services/app_lock_service.dart';

/// State for the optional app lock. The app is locked on cold start (and
/// whenever it is backgrounded) until the user unlocks with their password or
/// biometrics.
class AppLockProvider extends ChangeNotifier {
  AppLockProvider({required AppLockService service}) : _service = service;

  final AppLockService _service;

  bool _isReady = false;
  bool _lockEnabled = false;
  bool _biometricsEnabled = false;
  bool _biometricsAvailable = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  String? _error;

  bool get isReady => _isReady;
  bool get lockEnabled => _lockEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get biometricsAvailable => _biometricsAvailable;
  bool get isLocked => _isLocked;
  bool get isAuthenticating => _isAuthenticating;
  String? get error => _error;

  /// Load persisted settings and decide whether to show the lock screen.
  Future<void> init() async {
    _isReady = false;
    _error = null;
    notifyListeners();

    try {
      _lockEnabled = await _service.isLockEnabled();
      _biometricsEnabled = await _service.isBiometricsEnabled();
      _biometricsAvailable = await _service.isBiometricsAvailable();
      _isLocked = _lockEnabled;
    } catch (_) {
      _error = 'Could not load security settings.';
      _lockEnabled = false;
      _isLocked = false;
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  /// Re-lock the app. No-op while a biometric prompt is in flight.
  void lock() {
    if (!_lockEnabled || _isAuthenticating) return;
    _isLocked = true;
    notifyListeners();
  }

  /// Attempt to unlock with the app password. Returns true on success.
  Future<bool> unlockWithPassword(String password) async {
    _error = null;
    _isAuthenticating = true;
    notifyListeners();

    try {
      final ok = await _service.verifyPassword(password);
      if (ok) {
        _isLocked = false;
      } else {
        _error = 'Incorrect password.';
      }
      return ok;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  /// Attempt to unlock with biometrics. Returns true on success.
  Future<bool> unlockWithBiometrics() async {
    _error = null;
    _isAuthenticating = true;
    notifyListeners();

    try {
      final ok = await _service.authenticateBiometric(
        reason: 'Unlock HerokuDroid',
      );
      if (ok) _isLocked = false;
      return ok;
    } on AppLockAuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  /// Enable the lock, storing [password]. Returns false if the password is
  /// too short.
  Future<bool> enableLock(String password) async {
    if (password.length < AppConstants.appLockMinPasswordLength) {
      _error =
          'Password must be at least '
          '${AppConstants.appLockMinPasswordLength} characters.';
      notifyListeners();
      return false;
    }

    await _service.setPassword(password);
    await _service.setLockEnabled(true);
    _lockEnabled = true;
    _isLocked = false;
    _biometricsAvailable = await _service.isBiometricsAvailable();
    _error = null;
    notifyListeners();
    return true;
  }

  /// Disable the lock and forget the stored password.
  Future<void> disableLock() async {
    await _service.setBiometricsEnabled(false);
    await _service.setLockEnabled(false);
    await _service.clearPassword();
    _lockEnabled = false;
    _biometricsEnabled = false;
    _isLocked = false;
    _error = null;
    notifyListeners();
  }

  /// Replace the lock password.
  Future<bool> changePassword(String password) async {
    if (password.length < AppConstants.appLockMinPasswordLength) {
      _error =
          'Password must be at least '
          '${AppConstants.appLockMinPasswordLength} characters.';
      notifyListeners();
      return false;
    }

    await _service.setPassword(password);
    _error = null;
    notifyListeners();
    return true;
  }

  /// Toggle biometric unlock. Only meaningful while the lock is enabled.
  Future<void> setBiometricsEnabled(bool enabled) async {
    if (enabled && !_biometricsAvailable) return;
    await _service.setBiometricsEnabled(enabled);
    _biometricsEnabled = enabled;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
