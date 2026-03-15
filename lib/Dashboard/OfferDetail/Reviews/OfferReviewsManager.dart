import 'package:flutter/foundation.dart';

import '../../../App/HelperService.dart';
import '../../../App/Manager.dart';
import '../../../Offre/DarekModel.dart';
import 'OfferReviewsService.dart';

class OfferReviewsManager extends ChangeNotifier {
  final OfferReviewsService _service;
  final Manager _manager;

  OfferReviewsManager(this._manager, HelperService helper)
      : _service = OfferReviewsService(_manager, helper);

  bool isSaving = false;
  String? lastError;

  Future<OfferReviews?> addReview({
    required String idoffer,
    required String message,
    required int note,
    required double indiceFinition,
  }) async {
    if (isSaving) return null;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final res = await _service.addReview(
        idoffer: idoffer.trim(),
        message: message.trim(),
        note: note,
        indiceFinition: indiceFinition,
      );

      if (!res.success) {
        lastError =
        res.message.trim().isNotEmpty ? res.message : 'add_review_failed';
        return null;
      }

      return res.data;
    } catch (_) {
      lastError = 'exception';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview({
    required String idreview,
  }) async {
    if (isSaving) return false;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final res = await _service.deleteReview(
        idreview: idreview.trim(),
      );

      if (!res.success) {
        lastError = res.message.trim().isNotEmpty
            ? res.message
            : 'delete_review_failed';
        return false;
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

  void clearError() {
    lastError = null;
    notifyListeners();
  }
}