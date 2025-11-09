import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herokuandroid/data/models/app.dart';

/// Service for caching app data to improve performance
class CacheService {
  static const String _appsKey = 'cached_apps';
  static const String _appsTimestampKey = 'cached_apps_timestamp';
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

  /// Clear all cache
  Future<void> clearAllCache() async {
    await clearAppsCache();
  }
}
