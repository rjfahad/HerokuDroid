import 'package:herokudroid/core/constants/api_constants.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';

/// Repository for config vars operations
class ConfigRepository {
  final HerokuApiService _apiService;

  ConfigRepository({required HerokuApiService apiService})
    : _apiService = apiService;

  /// Get all config vars for an app
  Future<Map<String, String>> getConfigVars(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.configVars(appId));
      return Map<String, String>.from(response.data as Map);
    } on HerokuException {
      rethrow;
    } catch (e) {
      throw HerokuException(
        message: 'Failed to fetch config vars',
        originalError: e,
      );
    }
  }

  /// Update config vars (also creates new vars)
  /// To delete a var, pass null as the value
  Future<Map<String, String>> updateConfigVars(
    String appId,
    Map<String, String?> updates,
  ) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.configVars(appId),
        data: updates,
      );
      return Map<String, String>.from(response.data as Map);
    } on HerokuException {
      rethrow;
    } catch (e) {
      throw HerokuException(
        message: 'Failed to update config vars',
        originalError: e,
      );
    }
  }

  /// Delete a config var (sends key with null value)
  Future<Map<String, String>> deleteConfigVar(String appId, String key) async {
    return updateConfigVars(appId, {key: null});
  }

  /// Set a single config var (create or update)
  Future<Map<String, String>> setConfigVar(
    String appId,
    String key,
    String value,
  ) async {
    return updateConfigVars(appId, {key: value});
  }
}
