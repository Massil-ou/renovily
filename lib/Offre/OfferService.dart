import '../App/HelperService.dart';
import '../App/Manager.dart';
import 'DarekModel.dart';

class OfferSearchResponse {
  final List<OfferModel> items;
  final int limit;
  final int offset;
  final int count;
  final bool hasMore;
  final int nextOffset;

  const OfferSearchResponse({
    required this.items,
    required this.limit,
    required this.offset,
    required this.count,
    required this.hasMore,
    required this.nextOffset,
  });
}

class OfferService {
  final Manager _manager;
  final HelperService _helper;

  OfferService(this._manager, this._helper);

  static const String pathAll = '/renovily/search/list';
  static const String pathSearch = '/renovily/search/search';

  Future<List<OfferModel>> fetchAnnonces() async {
    final res = await _helper.postTyped<dynamic>(
      pathAll,
      data: const <String, dynamic>{},
      parse: null,
    );

    if (!res.success) {
      throw Exception(
        res.message.isNotEmpty ? res.message : 'fetch_offers_failed',
      );
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

  Future<OfferSearchResponse> searchAnnonces({
    String q = '',
    required List<String> wilayas,
    required List<String> communes,
    List<String> metiers = const [],
    int? prixMin,
    int? prixMax,
    bool? isPro,
    int offset = 0,
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
        'offset': offset,
      },
      parse: null,
    );

    if (!res.success) {
      throw Exception(
        res.message.isNotEmpty ? res.message : 'search_offers_failed',
      );
    }

    final raw = res.data;
    if (raw == null || raw is! Map) {
      throw Exception('invalid_payload');
    }

    final map = Map<String, dynamic>.from(raw);
    final rawItems = map['items'];
    final rawPagination = map['pagination'];

    if (rawItems is! List) {
      throw Exception('invalid_payload_items');
    }

    if (rawPagination is! Map) {
      throw Exception('invalid_payload_pagination');
    }

    final items = <OfferModel>[];
    for (final e in rawItems) {
      if (e is Map<String, dynamic>) {
        items.add(OfferModel.fromJson(e));
      } else if (e is Map) {
        items.add(OfferModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    final pagination = Map<String, dynamic>.from(rawPagination);

    return OfferSearchResponse(
      items: List<OfferModel>.unmodifiable(items),
      limit: _readInt(pagination['limit'], fallback: 50),
      offset: _readInt(pagination['offset'], fallback: offset),
      count: _readInt(pagination['count'], fallback: items.length),
      hasMore: _readBool(pagination['has_more']),
      nextOffset: _readInt(
        pagination['next_offset'],
        fallback: offset + items.length,
      ),
    );
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == '1' || raw == 'true';
  }
}