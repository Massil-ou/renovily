import '../App/BaseResponse.dart';
import '../App/HelperService.dart';
import '../App/Manager.dart';
import 'DarekModel.dart';

class DarekService {
  final Manager _manager;
  final HelperService _helper;

  DarekService(this._manager, this._helper);

  static const String pathAll = '/renovily/search/list';
  static const String pathSearch = '/renovily/search/search';

  Future<List<OfferModel>> fetchAnnonces({
    int limit = 100,
  }) async {
    final res = await _helper.postTyped<dynamic>(
      pathAll,
      data: {
        'limit': limit,
      },
      parse: null,
    );

    if (!res.success) {
      throw Exception(res.message.isNotEmpty ? res.message : 'fetch_offers_failed');
    }

    final raw = res.data;

    if (raw == null) {
      return <OfferModel>[];
    }

    if (raw is! List) {
      throw Exception('invalid_payload');
    }

    final list = <OfferModel>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        list.add(OfferModel.fromJson(e));
      } else if (e is Map) {
        list.add(OfferModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    return List<OfferModel>.unmodifiable(list);
  }

  Future<List<OfferModel>> searchAnnonces({
    String q = '',
    required List<String> wilayas,
    required List<String> communes,
    List<String> metiers = const [],
    int? prixMin,
    int? prixMax,
    bool? isPro,
    int limit = 100,
  }) async {
    final res = await _helper.postTyped<dynamic>(
      pathSearch,
      data: {
        'q': q.trim(),
        'wilayas': wilayas,
        'communes': communes,
        'metiers': metiers,
        'prix_min': prixMin,
        'prix_max': prixMax,
        'is_pro': isPro == null ? null : (isPro ? 1 : 0),
        'limit': limit,
      },
      parse: null,
    );

    if (!res.success) {
      throw Exception(res.message.isNotEmpty ? res.message : 'search_offers_failed');
    }

    final raw = res.data;

    if (raw == null) {
      return <OfferModel>[];
    }

    if (raw is! List) {
      throw Exception('invalid_payload');
    }

    final list = <OfferModel>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        list.add(OfferModel.fromJson(e));
      } else if (e is Map) {
        list.add(OfferModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    return List<OfferModel>.unmodifiable(list);
  }
}
