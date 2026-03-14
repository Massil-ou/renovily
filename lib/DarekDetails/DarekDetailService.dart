import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Darek/DarekModel.dart';

class AddAvisDarekService {
  final Manager _manager;
  final HelperService _helper;

  AddAvisDarekService(this._manager, this._helper);

  static const String endpoint = '/renovily/btp/annonces/add-avis';

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
