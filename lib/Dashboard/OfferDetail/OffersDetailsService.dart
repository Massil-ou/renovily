import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';

class OffersDetailsService {
  final Manager _manager;
  final HelperService _helper;

  OffersDetailsService(this._manager, this._helper);

  static const String getByIdEndpoint = '/renovily/serach/getbyid';

  Future<OfferModel?> getOfferById(String itemId) async {
    try {
      final res = await _helper.postTyped<dynamic>(
        getByIdEndpoint,
        data: {
          'id': itemId,
        },
        parse: null,
      );

      if (!res.success) {
        return null;
      }

      final raw = res.data;

      if (raw == null) return null;

      if (raw is Map<String, dynamic>) {
        return OfferModel.fromJson(raw);
      }

      if (raw is Map) {
        return OfferModel.fromJson(Map<String, dynamic>.from(raw));
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}