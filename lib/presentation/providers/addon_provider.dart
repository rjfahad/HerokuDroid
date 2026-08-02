import 'package:flutter/foundation.dart';
import 'package:herokudroid/data/models/addon.dart';
import 'package:herokudroid/data/repositories/addon_repository.dart';

/// Provider for add-on state management
class AddonProvider extends ChangeNotifier {
  final AddonRepository _repository;

  AddonProvider({required AddonRepository repository})
    : _repository = repository;

  List<Addon> _addons = [];
  bool _isLoading = false;
  String? _error;

  List<Addon> get addons => _addons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load add-ons for an app
  Future<void> loadAddons(String appId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addons = await _repository.getAddons(appId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _addons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single add-on (refresh details)
  Future<Addon?> getAddon(String appId, String addonId) async {
    try {
      return await _repository.getAddon(appId, addonId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _addons = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
