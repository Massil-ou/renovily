import 'PartnerProfileModel.dart';
import '../../App/BaseResponse.dart';
import '../../App/Manager.dart';
import '../../App/HelperService.dart';

class PartnerProfileService {
  final Manager _manager;
  final HelperService _auth;

  PartnerProfileService(this._manager, this._auth);

  static const _get = '/renovily/partner/profile/get';
  static const _req = '/renovily/partner/profile/request';
  static const _upd = '/renovily/partner/profile/update';

  Map<String, dynamic>? _m(dynamic d) =>
      d is Map ? Map<String, dynamic>.from(d) : null;

  PartnerProfileData? _currentLocalProfile() {
    final p = _manager.partnerProfileManager.profile;
    if (p == null) return null;

    return PartnerProfileData(
      companyName: p.companyName,
      tradeName: p.tradeName,
      companyType: p.companyType,
      siret: p.siret,
      rcNumber: p.rcNumber,
      nifNumber: p.nifNumber,
      nisNumber: p.nisNumber,
      taxRegime: p.taxRegime,
      vatNumber: p.vatNumber,
      statusPro: p.statusPro,
    );
  }

  PartnerProfilePayload _payloadFromForm(
      PartnerProfileData form, {
        bool isPro = false,
        String status = 'pending',
      }) {
    return PartnerProfilePayload(
      isPro: isPro,
      profile: PartnerProfileData(
        companyName: form.companyName,
        tradeName: form.tradeName,
        companyType: form.companyType,
        siret: form.siret,
        rcNumber: form.rcNumber,
        nifNumber: form.nifNumber,
        nisNumber: form.nisNumber,
        taxRegime: form.taxRegime,
        vatNumber: form.vatNumber,
        statusPro: status,
      ),
    );
  }

  PartnerProfilePayload _payloadFromPatch(
      Map<String, dynamic> patch, {
        required PartnerProfileData base,
        bool isPro = false,
      }) {
    return PartnerProfilePayload(
      isPro: isPro,
      profile: PartnerProfileData(
        companyName:
        (patch['company_name'] ?? base.companyName).toString().trim(),
        tradeName: patch.containsKey('trade_name')
            ? patch['trade_name']?.toString().trim()
            : base.tradeName,
        companyType: patch.containsKey('company_type')
            ? patch['company_type']?.toString().trim()
            : base.companyType,
        siret: patch.containsKey('siret')
            ? patch['siret']?.toString().trim()
            : base.siret,
        rcNumber: patch.containsKey('rc_number')
            ? patch['rc_number']?.toString().trim()
            : base.rcNumber,
        nifNumber: patch.containsKey('nif_number')
            ? patch['nif_number']?.toString().trim()
            : base.nifNumber,
        nisNumber: patch.containsKey('nis_number')
            ? patch['nis_number']?.toString().trim()
            : base.nisNumber,
        taxRegime: patch.containsKey('tax_regime')
            ? patch['tax_regime']?.toString().trim()
            : base.taxRegime,
        vatNumber: patch.containsKey('vat_number')
            ? (patch['vat_number'] == null
            ? null
            : double.tryParse(patch['vat_number'].toString()))
            : base.vatNumber,
        statusPro: base.statusPro,
      ),
    );
  }

  BaseResponse<PartnerProfilePayload?> _wrap(BaseResponse<dynamic> r) {
    if (!r.success) {
      return BaseResponse<PartnerProfilePayload?>(
        success: false,
        message: r.message,
        code: r.code,
        data: null,
      );
    }

    final m = _m(r.data);

    return BaseResponse<PartnerProfilePayload?>(
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
      PartnerProfileData f,
      ) async {
    final r = await _auth.postTyped<dynamic>(
      _req,
      data: f.toRequestJson(),
      parse: null,
    );

    if (!r.success) {
      return BaseResponse<PartnerProfilePayload?>(
        success: false,
        message: r.message,
        code: r.code,
        data: null,
      );
    }

    final parsed = _m(r.data);
    if (parsed != null) {
      return BaseResponse<PartnerProfilePayload?>(
        success: true,
        message: r.message,
        code: r.code,
        data: PartnerProfilePayload.fromJson(parsed),
      );
    }

    final localPayload = _payloadFromForm(
      f,
      isPro: false,
      status: 'pending',
    );

    return BaseResponse<PartnerProfilePayload?>(
      success: true,
      message: r.message,
      code: r.code,
      data: localPayload,
    );
  }

  Future<BaseResponse<PartnerProfilePayload?>> updateProfile(
      Map<String, dynamic> p,
      ) async {
    final r = await _auth.postTyped<dynamic>(_upd, data: p, parse: null);

    if (!r.success) {
      return BaseResponse<PartnerProfilePayload?>(
        success: false,
        message: r.message,
        code: r.code,
        data: null,
      );
    }

    final parsed = _m(r.data);
    if (parsed != null) {
      return BaseResponse<PartnerProfilePayload?>(
        success: true,
        message: r.message,
        code: r.code,
        data: PartnerProfilePayload.fromJson(parsed),
      );
    }

    final base = _currentLocalProfile();
    if (base == null) {
      return BaseResponse<PartnerProfilePayload?>(
        success: true,
        message: r.message,
        code: r.code,
        data: null,
      );
    }

    final merged = _payloadFromPatch(
      p,
      base: base,
      isPro: false,
    );

    return BaseResponse<PartnerProfilePayload?>(
      success: true,
      message: r.message,
      code: r.code,
      data: merged,
    );
  }
}