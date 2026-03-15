import 'dart:async';

import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';

class OfferListService {
  final Manager _manager;
  final HelperService _helper;

  OfferListService(this._manager, this._helper);

  static const String listEndpoint = '/renovily/offers/list';
  static const String updateEndpoint = '/renovily/offers/update';
  static const String deleteEndpoint = '/renovily/offers/delete';

  Future<BaseResponse<List<OfferModel>>> getMesAnnonces() async {
    final res = await _helper.postTyped<dynamic>(
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

  Future<BaseResponse<void>> updateAnnonce(OfferModel item) async {
    final res = await _helper.postTyped<dynamic>(
      updateEndpoint,
      data: {
        'id': item.id,
        'titre': item.titre,
        'description': item.description,
        'wilaya': item.wilaya,
        'commune': item.commune,
        'metier': item.metier,
        'name_pro': item.namePro,
        'phone': item.phone,
        'status': item.status.value,
        'experience_annees': item.experienceAnnees,
        'prix': item.prix,
        'unite_prix': item.unitePrix?.value,
      },
      parse: null,
    );

    return BaseResponse<void>(
      success: res.success,
      message: res.message,
      code: res.code,
      data: null,
    );
  }

  Future<BaseResponse<void>> deleteAnnonce(String annonceId) async {
    final res = await _helper.postTyped<dynamic>(
      deleteEndpoint,
      data: {'id': annonceId},
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