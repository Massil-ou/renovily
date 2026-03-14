import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Darek/DarekModel.dart';

class OffersDetailsService {
  final Manager _manager;
  final HelperService _helper;

  OffersDetailsService(this._manager, this._helper);

  static const String endpoint = '/renovily/offers/getbyid';

  Future<bool> sendAvis({
    required String annonceId,
    required OfferReviews avis,
  }) async {
    try {
      final res = await _helper.postTyped<dynamic>(
        endpoint,
        data: {
          'annonce_id': annonceId,
          'avis': avis.toJson(),
        },
        parse: null,
      );

      return res.success == true;
    } catch (_) {
      return false;
    }
  }
}
