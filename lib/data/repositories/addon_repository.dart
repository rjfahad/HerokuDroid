import 'package:herokudroid/core/constants/api_constants.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/models/addon.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';

/// Repository for add-on operations
class AddonRepository {
  final HerokuApiService _apiService;

  AddonRepository({required HerokuApiService apiService})
    : _apiService = apiService;

  /// Get all add-ons for an app
  Future<List<Addon>> getAddons(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.addons(appId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Addon.fromJson(json as Map<String, dynamic>))
          .toList();
    } on HerokuException {
      rethrow;
    } catch (e) {
      throw HerokuException(
        message: 'Failed to fetch add-ons',
        originalError: e,
      );
    }
  }

  /// Get single add-on details
  Future<Addon> getAddon(String appId, String addonId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.addon(appId, addonId),
      );
      return Addon.fromJson(response.data as Map<String, dynamic>);
    } on HerokuException {
      rethrow;
    } catch (e) {
      throw HerokuException(
        message: 'Failed to fetch add-on details',
        originalError: e,
      );
    }
  }
}
