import 'package:flutter/foundation.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';
import 'FavorisDarekService.dart';

class FavorisAnnoncesManager extends ChangeNotifier {
  final FavorisAnnoncesService _service;
  final Manager _manager;

  FavorisAnnoncesManager(this._manager, HelperService helper)
      : _service = FavorisAnnoncesService(_manager, helper);

  bool isLoading = false;
  bool isSaving = false;
  String? lastError;

  List<DarekModel> favoris = [];

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      favoris = await _service.getFavoris();
    } catch (_) {
      lastError = 'exception';
      favoris = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<bool> add(DarekModel item) async {
    if (isSaving) return false;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final ok = await _service.addFavori(item);
      if (ok) {
        final exists = favoris.any((e) => e.id == item.id);
        if (!exists) {
          favoris = [...favoris, item];
        }
      } else {
        lastError = 'add_failed';
      }
      return ok;
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
      final ok = await _service.deleteFavori(annonceId);
      if (ok) {
        favoris = favoris.where((e) => e.id != annonceId).toList();
      } else {
        lastError = 'delete_failed';
      }
      return ok;
    } catch (_) {
      lastError = 'exception';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggle(DarekModel item) async {
    final exists = isFavoriLocal(item.id);
    if (exists) {
      return delete(item.id);
    }
    return add(item);
  }

  bool isFavoriLocal(String annonceId) {
    return favoris.any((e) => e.id == annonceId);
  }

  Future<bool> isFavori(String annonceId) async {
    try {
      return await _service.isFavori(annonceId);
    } catch (_) {
      return isFavoriLocal(annonceId);
    }
  }

  void clear() {
    favoris = [];
    notifyListeners();
  }
}
