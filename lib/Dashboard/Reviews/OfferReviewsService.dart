import 'dart:async';

import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';

class OfferReviewsService {
  final Manager _manager;
  final HelperService _helper;

  OfferReviewsService(this._manager, this._helper);

  static const String addEndpoint = '/renovily/offers/reviews/add';
  static const String deleteEndpoint = '/renovily/offers/reviews/delete';

  Future<BaseResponse<OfferReviews?>> addReview({
    required String idoffer,
    required String prenom,
    required String message,
    required int note,
    required double indiceFinition,
  }) async {
    final res = await _helper.postTyped<dynamic>(
      addEndpoint,
      data: {
        'idoffer': idoffer,
        'prenom': prenom,
        'message': message,
        'note': note,
        'indice_finition': indiceFinition,
      },
      parse: null,
    );

    if (!res.success) {
      return BaseResponse<OfferReviews?>(
        success: false,
        message: res.message,
        code: res.code,
        data: null,
      );
    }

    final raw = res.data;
    OfferReviews? review;

    if (raw is Map<String, dynamic>) {
      review = OfferReviews.fromJson(raw);
    } else if (raw is Map) {
      review = OfferReviews.fromJson(Map<String, dynamic>.from(raw));
    }

    return BaseResponse<OfferReviews?>(
      success: true,
      message: res.message,
      code: res.code,
      data: review,
    );
  }

  Future<BaseResponse<void>> deleteReview({
    required String idreview,
  }) async {
    final res = await _helper.postTyped<dynamic>(
      deleteEndpoint,
      data: {
        'idreview': idreview,
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
}
