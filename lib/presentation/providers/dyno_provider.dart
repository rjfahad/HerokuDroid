import 'package:flutter/foundation.dart';
import '../../data/models/formation.dart';
import '../../data/repositories/formation_repository.dart';
import '../../core/errors/heroku_exception.dart';

class DynoProvider with ChangeNotifier {
  final FormationRepository _formationRepository;

  DynoProvider(this._formationRepository);

  // State
  List<Formation> _formations = [];
  bool _isLoading = false;
  String? _error;
  String? _currentAppId;

  // Getters
  List<Formation> get formations => _formations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Load formation data for an app
  Future<void> loadFormation(String appId) async {
    if (_currentAppId == appId && _formations.isNotEmpty && !_isLoading) {
      // Already loaded for this app
      return;
    }

    _currentAppId = appId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _formations = await _formationRepository.getFormation(appId);
      _error = null;
    } on HerokuException catch (e) {
      _error = e.message;
      _formations = [];
    } catch (e) {
      _error = 'Failed to load dyno formation: $e';
      _formations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh formation data
  Future<void> refreshFormation() async {
    if (_currentAppId != null) {
      await loadFormation(_currentAppId!);
    }
  }

  /// Scale a formation (update quantity and/or size)
  Future<bool> scaleFormation({
    required String appId,
    required String formationId,
    int? quantity,
    String? size,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedFormation = await _formationRepository.updateFormation(
        appId: appId,
        formationId: formationId,
        quantity: quantity,
        size: size,
      );

      // Update the formation in the list
      final index = _formations.indexWhere((f) => f.id == formationId);
      if (index != -1) {
        _formations[index] = updatedFormation;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to scale formation: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restart all dynos for an app
  Future<bool> restartAllDynos(String appId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _formationRepository.restartAllDynos(appId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to restart dynos: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restart a specific dyno
  Future<bool> restartDyno(String appId, String dynoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _formationRepository.restartDyno(appId, dynoId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to restart dyno: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restart all dynos of a specific process type
  Future<bool> restartDynosByType(String appId, String processType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _formationRepository.restartDynosByType(appId, processType);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on HerokuException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to restart dynos: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
