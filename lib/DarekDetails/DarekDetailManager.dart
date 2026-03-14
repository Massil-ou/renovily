import 'package:flutter/foundation.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Darek/DarekModel.dart';
import 'DarekDetailService.dart';

class OffersDetailsManager extends ChangeNotifier {
  final OffersDetailsService _service;
  final Manager _manager;

  OffersDetailsManager(this._manager, HelperService helper)
      : _service = OffersDetailsService(_manager, helper);

  bool isLoading = false;
  String? lastError;

  Future<bool> sendAvis({
    required String annonceId,
    required OfferReviews avis,
  }) async {
    if (isLoading) return false;

    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      final ok = await _service.sendAvis(
        annonceId: annonceId,
        avis: avis,
      );

      if (!ok) {
        lastError = 'send_failed';
      }

      return ok;
    } catch (_) {
      lastError = 'exception';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }
}
