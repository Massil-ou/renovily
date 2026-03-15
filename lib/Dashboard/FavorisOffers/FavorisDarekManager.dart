import 'package:flutter/foundation.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';
import 'FavorisDarekService.dart';

class FavorisOffersManager extends ChangeNotifier {
  final FavorisOffersService _service;
  final Manager _manager;

  FavorisOffersManager(this._manager, HelperService helper)
      : _service = FavorisOffersService(_manager, helper);

  bool isLoading = false;
  bool isSaving = false;
  String? lastError;

  List<OfferModel> favoris = [];

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      final res = await _service.listFavorisOffers();

      if (res.success) {
        favoris = res.data ?? <OfferModel>[];
      } else {
        lastError = res.message;
        favoris = <OfferModel>[];
      }
    } catch (_) {
      lastError = 'exception';
      favoris = <OfferModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<bool> add(OfferModel item) async {
    if (isSaving) return false;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final res = await _service.addFavori(idoffer: item.id);

      if (!res.success) {
        lastError = res.message.isNotEmpty ? res.message : 'add_failed';
        return false;
      }

      final existsIndex = favoris.indexWhere((e) => e.id == item.id);

      if (existsIndex >= 0) {
        final updated = favoris[existsIndex].copyWith(
          idfavorite: res.data,
        );
        final copy = [...favoris];
        copy[existsIndex] = updated;
        favoris = copy;
      } else {
        favoris = [
          ...favoris,
          item.copyWith(idfavorite: res.data),
        ];
      }

      return true;
    } catch (_) {
      lastError = 'exception';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteByFavoriteId(String idfavorite) async {
    if (isSaving) return false;

    final fid = idfavorite.trim();
    if (fid.isEmpty) {
      lastError = 'missing_idfavorite';
      notifyListeners();
      return false;
    }

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final res = await _service.deleteFavori(idfavorite: fid);

      if (!res.success) {
        lastError = res.message.isNotEmpty ? res.message : 'delete_failed';
        return false;
      }

      favoris = favoris.where((e) => e.idfavorite != fid).toList();
      return true;
    } catch (_) {
      lastError = 'exception';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteByOfferId(String offerId) async {
    final item = favoris.where((e) => e.id == offerId).cast<OfferModel?>().isEmpty
        ? null
        : favoris.firstWhere((e) => e.id == offerId);

    final idfavorite = item?.idfavorite?.trim() ?? '';
    if (idfavorite.isEmpty) {
      lastError = 'missing_idfavorite';
      notifyListeners();
      return false;
    }

    return deleteByFavoriteId(idfavorite);
  }

  Future<bool> delete(String offerId) async {
    return deleteByOfferId(offerId);
  }

  Future<bool> toggle(OfferModel item) async {
    final existing = favoris.where((e) => e.id == item.id).cast<OfferModel?>().isEmpty
        ? null
        : favoris.firstWhere((e) => e.id == item.id);

    if (existing != null) {
      final idfavorite = existing.idfavorite?.trim() ?? '';
      if (idfavorite.isEmpty) {
        lastError = 'missing_idfavorite';
        notifyListeners();
        return false;
      }
      return deleteByFavoriteId(idfavorite);
    }

    return add(item);
  }

  bool isFavoriLocal(String offerId) {
    return favoris.any((e) => e.id == offerId);
  }

  String? favoriteIdByOfferId(String offerId) {
    for (final item in favoris) {
      if (item.id == offerId) {
        return item.idfavorite;
      }
    }
    return null;
  }

  Future<bool> isFavori(String offerId) async {
    return isFavoriLocal(offerId);
  }

  Future<void> trimOldFavoris() async {
    try {
      final res = await _service.trimOldFavoris();
      if (!res.success) {
        lastError = res.message.isNotEmpty ? res.message : 'trim_failed';
      }
    } catch (_) {
      lastError = 'exception';
    } finally {
      notifyListeners();
    }
  }

  void clear() {
    favoris = [];
    lastError = null;
    notifyListeners();
  }
}
