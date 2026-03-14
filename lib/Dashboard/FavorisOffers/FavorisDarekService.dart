import 'dart:async';

import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';

class FavorisOffersService {
  final Manager _manager;
  final HelperService _auth;

  FavorisOffersService(this._manager, this._auth);

  static const String listEndpoint = '/renovily/favoris/list';
  static const String addEndpoint = '/renovily/favoris/add';
  static const String deleteEndpoint = '/renovily/favoris/delete';
  static const String trimOldEndpoint = '/renovily/favoris/trim';

  Future<BaseResponse<List<OfferModel>>> listFavorisOffers() async {
    final res = await _auth.postTyped<dynamic>(
      listEndpoint,
      data: const {},
      parse: null,
    );

    if (!res.success) {
      return BaseResponse<List<OfferModel>>(
        success: false,
        message: res.message,
        code: res.code,
        data: null,
      );
    }

    final raw = res.data;

    if (raw == null) {
      return BaseResponse<List<OfferModel>>(
        success: true,
        message: res.message,
        code: res.code,
        data: <OfferModel>[],
      );
    }

    if (raw is! List) {
      return BaseResponse<List<OfferModel>>(
        success: false,
        message: 'invalid_payload',
        code: -2,
        data: null,
      );
    }

    final list = <OfferModel>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        list.add(OfferModel.fromJson(e));
      } else if (e is Map) {
        list.add(OfferModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    return BaseResponse<List<OfferModel>>(
      success: true,
      message: res.message,
      code: res.code,
      data: list,
    );
  }

  Future<BaseResponse<String?>> addFavori({
    required String idoffer,
  }) async {
    final res = await _auth.postTyped<dynamic>(
      addEndpoint,
      data: {'idoffer': idoffer},
      parse: null,
    );

    if (!res.success) {
      return BaseResponse<String?>(
        success: false,
        message: res.message,
        code: res.code,
        data: null,
      );
    }

    final raw = res.data;
    String? idfavorite;

    if (raw is Map<String, dynamic>) {
      idfavorite = raw['idfavorite']?.toString();
    } else if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      idfavorite = m['idfavorite']?.toString();
    } else if (raw != null) {
      idfavorite = raw.toString();
    }

    return BaseResponse<String?>(
      success: true,
      message: res.message,
      code: res.code,
      data: idfavorite,
    );
  }

  Future<BaseResponse<void>> deleteFavori({
    required String idfavorite,
  }) async {
    final res = await _auth.postTyped<dynamic>(
      deleteEndpoint,
      data: {'idfavorite': idfavorite},
      parse: null,
    );

    return BaseResponse<void>(
      success: res.success,
      message: res.message,
      code: res.code,
      data: null,
    );
  }

  Future<BaseResponse<void>> trimOldFavoris() async {
    final res = await _auth.postTyped<dynamic>(
      trimOldEndpoint,
      data: const {},
      parse: null,
    );

    return BaseResponse<void>(
      success: res.success,
      message: res.message,
      code: res.code,
      data: null,
    );
  }
}
