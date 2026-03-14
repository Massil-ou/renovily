import 'PartnerProfileModel.dart';
import '../../App/BaseResponse.dart';
import '../../App/Manager.dart';
import '../../App/HelperService.dart';

class PartnerProfileService {
  final Manager _manager;
  final HelperService _auth;

  PartnerProfileService(this._manager, this._auth);

  static const _get = '/partner/profile/get';
  static const _req = '/partner/profile/request';
  static const _upd = '/partner/profile/update';

  Map<String, dynamic>? _m(dynamic d) =>
      d is Map ? Map<String, dynamic>.from(d) : null;

  BaseResponse<PartnerProfilePayload?> _wrap(BaseResponse<dynamic> r) {
    if (!r.success) {
      return BaseResponse(
        success: false,
        message: r.message,
        code: r.code,
        data: null,
      );
    }

    final m = _m(r.data);

    return BaseResponse(
      success: true,
      message: r.message,
      code: r.code,
      data: m == null ? null : PartnerProfilePayload.fromJson(m),
    );
  }

  Future<BaseResponse<PartnerProfilePayload?>> getProfile() async {
    final r = await _auth.postTyped<dynamic>(_get, data: const {}, parse: null);
    return _wrap(r);
  }

  Future<BaseResponse<PartnerProfilePayload?>> requestPro(
      PartnerProfileData f) async {
    final r = await _auth.postTyped<dynamic>(
      _req,
      data: f.toRequestJson(),
      parse: null,
    );

    return _wrap(r);
  }

  Future<BaseResponse<PartnerProfilePayload?>> updateProfile(
      Map<String, dynamic> p) async {
    final r = await _auth.postTyped<dynamic>(_upd, data: p, parse: null);
    return _wrap(r);
  }
}