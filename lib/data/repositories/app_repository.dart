import 'package:herokudroid/core/constants/api_constants.dart';
import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/data/models/dyno.dart';
import 'package:herokudroid/data/models/formation.dart';
import 'package:herokudroid/data/models/release.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';

/// Repository for Heroku app operations
class AppRepository {
  final HerokuApiService _apiService;

  AppRepository({required HerokuApiService apiService})
    : _apiService = apiService;

  /// Get all apps
  Future<List<App>> getApps() async {
    try {
      final response = await _apiService.get(ApiConstants.apps);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => App.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific app by ID or name
  Future<App> getApp(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.app(appId));
      return App.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an app
  Future<void> deleteApp(String appId) async {
    try {
      await _apiService.delete(ApiConstants.deleteApp(appId));
    } catch (e) {
      rethrow;
    }
  }

  /// Get dynos for an app
  Future<List<Dyno>> getDynos(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.dynos(appId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Dyno.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get formation for an app
  Future<List<Formation>> getFormation(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.formation(appId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Formation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Restart all dynos for an app
  Future<void> restartDynos(String appId) async {
    try {
      await _apiService.delete(ApiConstants.restartDynos(appId));
    } catch (e) {
      rethrow;
    }
  }

  /// Restart specific dyno
  Future<void> restartDyno(String appId, String dynoId) async {
    try {
      await _apiService.delete(ApiConstants.dyno(appId, dynoId));
    } catch (e) {
      rethrow;
    }
  }

  /// Scale formation
  Future<Formation> scaleFormation({
    required String appId,
    required String type,
    required int quantity,
    String? size,
  }) async {
    try {
      final data = {'quantity': quantity, if (size != null) 'size': size};

      final response = await _apiService.patch(
        ApiConstants.formationType(appId, type),
        data: data,
      );

      return Formation.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Set maintenance mode
  Future<App> setMaintenanceMode(String appId, bool enabled) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.app(appId),
        data: {'maintenance': enabled},
      );

      return App.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update app name
  Future<App> updateAppName(String appId, String newName) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.app(appId),
        data: {'name': newName},
      );

      return App.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get releases (deploy history) for an app
  Future<List<Release>> getReleases(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.releases(appId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Release.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
