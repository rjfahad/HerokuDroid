import '../models/formation.dart';
import '../services/heroku_api_service.dart';
import '../../core/constants/api_constants.dart';

class FormationRepository {
  final HerokuApiService _apiService;

  FormationRepository(this._apiService);

  /// Get the formation (process types and dyno configurations) for an app
  Future<List<Formation>> getFormation(String appId) async {
    final response = await _apiService.get(ApiConstants.formation(appId));

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Formation.fromJson(json)).toList();
  }

  /// Update a specific formation (scale dynos)
  Future<Formation> updateFormation({
    required String appId,
    required String formationId,
    int? quantity,
    String? size,
  }) async {
    final Map<String, dynamic> updates = {};

    if (quantity != null) {
      updates['quantity'] = quantity;
    }

    if (size != null) {
      updates['size'] = size;
    }

    final response = await _apiService.patch(
      ApiConstants.formationType(appId, formationId),
      data: updates,
    );

    return Formation.fromJson(response.data as Map<String, dynamic>);
  }

  /// Restart all dynos for an app
  Future<void> restartAllDynos(String appId) async {
    await _apiService.delete(ApiConstants.dynos(appId));
  }

  /// Restart a specific dyno
  Future<void> restartDyno(String appId, String dynoId) async {
    await _apiService.delete(ApiConstants.dyno(appId, dynoId));
  }

  /// Restart all dynos of a specific process type
  Future<void> restartDynosByType(String appId, String processType) async {
    await _apiService.delete('${ApiConstants.dynos(appId)}/$processType');
  }
}
