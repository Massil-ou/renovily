import 'package:flutter/foundation.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';
import 'OffersDetailsService.dart';

class OffersDetailsManager extends ChangeNotifier {
  final OffersDetailsService _service;
  final Manager _manager;

  OffersDetailsManager(this._manager, HelperService helper)
      : _service = OffersDetailsService(_manager, helper);

  bool isLoading = false;
  String? lastError;

  Future<OfferModel?> getOfferById(String itemId) async {
    if (isLoading) return null;

    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      final item = await _service.getOfferById(itemId);

      if (item == null) {
        lastError = 'annonce_introuvable';
      }

      return item;
    } catch (_) {
      lastError = 'exception';
      return null;
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