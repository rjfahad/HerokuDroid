import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/data/models/release.dart';

/// Service for caching app data to improve performance
class CacheService {
  static const String _appsKey = 'cached_apps';
  static const String _appsTimestampKey = 'cached_apps_timestamp';
  static const String _configVarsKeyPrefix = 'cached_config_';
  static const String _configVarsTimestampPrefix = 'cached_config_timestamp_';
  static const String _releasesKeyPrefix = 'cached_releases_';
  static const String _releasesTimestampPrefix = 'cached_releases_timestamp_';
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Check if cached apps are still valid
  bool get hasValidAppsCache {
    final timestamp = _prefs.getInt(_appsTimestampKey);
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheValidDuration;
  }

  /// Get cached apps
  List<App>? getCachedApps() {
    if (!hasValidAppsCache) return null;

    final jsonString = _prefs.getString(_appsKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => App.fromJson(json)).toList();
    } catch (e) {
      // If deserialization fails, return null
      return null;
    }
  }

  /// Cache apps list
  Future<void> cacheApps(List<App> apps) async {
    final jsonString = jsonEncode(apps.map((app) => app.toJson()).toList());
    await _prefs.setString(_appsKey, jsonString);
    await _prefs.setInt(
      _appsTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Clear apps cache
  Future<void> clearAppsCache() async {
    await _prefs.remove(_appsKey);
    await _prefs.remove(_appsTimestampKey);
  }

  // Config Vars Cache

  /// Check if cached config vars are valid for a specific app
  bool hasValidConfigCache(String appId) {
    final timestamp = _prefs.getInt('$_configVarsTimestampPrefix$appId');
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheValidDuration;
  }

  /// Get cached config vars for a specific app
  Map<String, String>? getCachedConfigVars(String appId) {
    if (!hasValidConfigCache(appId)) return null;

    final jsonString = _prefs.getString('$_configVarsKeyPrefix$appId');
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return json.cast<String, String>();
    } catch (e) {
      return null;
    }
  }

  /// Cache config vars for a specific app
  Future<void> cacheConfigVars(
    String appId,
    Map<String, String> configVars,
  ) async {
    final jsonString = jsonEncode(configVars);
    await _prefs.setString('$_configVarsKeyPrefix$appId', jsonString);
    await _prefs.setInt(
      '$_configVarsTimestampPrefix$appId',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Clear config vars cache for a specific app
  Future<void> clearConfigCache(String appId) async {
    await _prefs.remove('$_configVarsKeyPrefix$appId');
    await _prefs.remove('$_configVarsTimestampPrefix$appId');
  }

  // Releases Cache

  /// Check if cached releases are valid for a specific app
  bool hasValidReleasesCache(String appId) {
    final timestamp = _prefs.getInt('$_releasesTimestampPrefix$appId');
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheValidDuration;
  }

  /// Get cached releases for a specific app
  List<Release>? getCachedReleases(String appId) {
    if (!hasValidReleasesCache(appId)) return null;

    final jsonString = _prefs.getString('$_releasesKeyPrefix$appId');
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Release.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache releases for a specific app
  Future<void> cacheReleases(String appId, List<Release> releases) async {
    final jsonString = jsonEncode(releases.map((r) => r.toJson()).toList());
    await _prefs.setString('$_releasesKeyPrefix$appId', jsonString);
    await _prefs.setInt(
      '$_releasesTimestampPrefix$appId',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Clear releases cache for a specific app
  Future<void> clearReleasesCache(String appId) async {
    await _prefs.remove('$_releasesKeyPrefix$appId');
    await _prefs.remove('$_releasesTimestampPrefix$appId');
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await clearAppsCache();
    // Get all keys and remove cache-related ones
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_configVarsKeyPrefix) ||
          key.startsWith(_configVarsTimestampPrefix) ||
          key.startsWith(_releasesKeyPrefix) ||
          key.startsWith(_releasesTimestampPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
