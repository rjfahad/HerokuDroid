import 'package:flutter/foundation.dart';
import 'package:herokudroid/core/constants/app_constants.dart';
import 'package:herokudroid/data/models/app_update.dart';
import 'package:herokudroid/data/services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Checks the GitHub update manifest and exposes the installed version.
class UpdateProvider extends ChangeNotifier {
  UpdateProvider({
    required UpdateService service,
    required SharedPreferences prefs,
  }) : _service = service,
       _prefs = prefs;

  static const String _dismissedKey = 'dismissed_update_version';

  final UpdateService _service;
  final SharedPreferences _prefs;

  String _currentVersion = '';
  AppUpdate? _availableUpdate;
  bool _isChecking = false;
  String? _error;

  /// Installed version, e.g. `1.0.0`.
  String get currentVersion => _currentVersion;

  /// A newer release, or null when up to date.
  AppUpdate? get availableUpdate => _availableUpdate;

  bool get hasUpdate => _availableUpdate != null;
  bool get isChecking => _isChecking;
  String? get error => _error;

  /// Whether the launch prompt should be shown (not dismissed for this
  /// version).
  bool get shouldPrompt =>
      _availableUpdate != null &&
      _prefs.getString(_dismissedKey) != _availableUpdate!.version;

  /// Read the installed version from the platform package metadata.
  Future<void> init() async {
    if (_currentVersion.isNotEmpty) return;

    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
    } catch (_) {
      _currentVersion = AppConstants.version;
    }
    notifyListeners();
  }

  /// Check the manifest for a newer release.
  ///
  /// When [silent] is true, failures are swallowed (a launch check should not
  /// nag). Returns true when a newer version is available.
  Future<bool> checkForUpdates({bool silent = false}) async {
    _isChecking = true;
    if (!silent) _error = null;
    notifyListeners();

    try {
      await init();

      final latest = await _service.fetchLatest();
      if (latest != null && latest.isNewerThan(_currentVersion)) {
        _availableUpdate = latest;
      } else {
        _availableUpdate = null;
      }
      _error = null;
      return _availableUpdate != null;
    } catch (_) {
      if (!silent) {
        _error = 'Could not check for updates. Check your connection.';
      }
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Remember that the user dismissed the prompt for the current version.
  Future<void> dismissPrompt() async {
    final version = _availableUpdate?.version;
    if (version == null) return;
    await _prefs.setString(_dismissedKey, version);
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
