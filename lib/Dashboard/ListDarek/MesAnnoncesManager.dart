import 'package:flutter/foundation.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';
import 'MesAnnoncesService.dart';

class MesAnnoncesManager extends ChangeNotifier {
  final MesAnnoncesService _service;
  final Manager _manager;

  MesAnnoncesManager(this._manager, HelperService helper)
      : _service = MesAnnoncesService(_manager, helper);

  bool isLoading = false;
  bool isSaving = false;
  String? lastError;

  List<DarekModel> annonces = [];

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      annonces = await _service.getMesAnnonces();
    } catch (_) {
      lastError = 'exception';
      annonces = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<bool> update(DarekModel item) async {
    if (isSaving) return false;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final updated = await _service.updateAnnonce(item);
      if (updated == null) {
        lastError = 'update_failed';
        return false;
      }

      annonces = annonces.map((e) {
        if (e.id == updated.id) return updated;
        return e;
      }).toList();

      return true;
    } catch (_) {
      lastError = 'exception';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String annonceId) async {
    if (isSaving) return false;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final ok = await _service.deleteAnnonce(annonceId);
      if (!ok) {
        lastError = 'delete_failed';
        return false;
      }

      annonces = annonces.where((e) => e.id != annonceId).toList();
      return true;
    } catch (_) {
      lastError = 'exception';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }

  void clear() {
    annonces = [];
    lastError = null;
    notifyListeners();
  }
}
