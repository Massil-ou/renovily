// PartnerProfileModel.dart
class PartnerProfileData {
  final String? siret;
  final String? companyName;
  final String? tradeName;
  final String? companyType;
  final String? rcNumber;
  final String? nifNumber;
  final String? nisNumber;
  final String? taxRegime;
  final double? vatNumber;

  final String? statusPro;
  final String? verifiedAt;
  final String? requestedAt;
  final String? updatedAt;

  const PartnerProfileData({
    this.siret,
    this.companyName,
    this.tradeName,
    this.companyType,
    this.rcNumber,
    this.nifNumber,
    this.nisNumber,
    this.taxRegime,
    this.vatNumber,
    this.statusPro,
    this.verifiedAt,
    this.requestedAt,
    this.updatedAt,
  });

  static String? _s(dynamic v) {
    if (v == null) return null;
    final t = v.toString().trim();
    return t.isEmpty ? null : t;
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll(',', '.');
    return double.tryParse(s);
  }

  factory PartnerProfileData.fromJson(Map<String, dynamic> j) {
    return PartnerProfileData(
      siret: _s(j['siret']) ?? _s(j['siret_user']),
      companyName: _s(j['company_name']),
      tradeName: _s(j['trade_name']),
      companyType: _s(j['company_type']),
      rcNumber: _s(j['rc_number']),
      nifNumber: _s(j['nif_number']),
      nisNumber: _s(j['nis_number']),
      taxRegime: _s(j['tax_regime']),
      vatNumber: _d(j['vat_number']),
      statusPro: _s(j['status_pro']),
      verifiedAt: _s(j['verified_at']),
      requestedAt: _s(j['requested_at']),
      updatedAt: _s(j['updated_at']),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'siret': siret,
      'company_name': companyName,
      'trade_name': tradeName,
      'company_type': companyType,
      'rc_number': rcNumber,
      'nif_number': nifNumber,
      'nis_number': nisNumber,
      'tax_regime': taxRegime,
      'vat_number': vatNumber?.toStringAsFixed(2),
    };
  }

  PartnerProfileData copyWithFromPatch(Map<String, dynamic> patch) {
    String? s(String k) => patch.containsKey(k) ? patch[k]?.toString() : null;
    double? d(String k) {
      if (!patch.containsKey(k)) return null;
      final v = patch[k];
      if (v == null) return null;
      return double.tryParse(v.toString().replaceAll(',', '.'));
    }

    return PartnerProfileData(
      siret: s('siret') ?? siret,
      companyName: s('company_name') ?? companyName,
      tradeName: s('trade_name') ?? tradeName,
      companyType: s('company_type') ?? companyType,
      rcNumber: s('rc_number') ?? rcNumber,
      nifNumber: s('nif_number') ?? nifNumber,
      nisNumber: s('nis_number') ?? nisNumber,
      taxRegime: s('tax_regime') ?? taxRegime,
      vatNumber: d('vat_number') ?? vatNumber,
      statusPro: statusPro,
      verifiedAt: verifiedAt,
      requestedAt: requestedAt,
      updatedAt: updatedAt,
    );
  }
}

class PartnerProfilePayload {
  final bool isPro;
  final PartnerProfileData? profile;

  const PartnerProfilePayload({required this.isPro, required this.profile});

  factory PartnerProfilePayload.empty() =>
      const PartnerProfilePayload(isPro: false, profile: null);

  static bool _b(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    return v?.toString() == '1';
  }

  factory PartnerProfilePayload.fromJson(Map<String, dynamic> j) {
    final p = j['profile'];
    return PartnerProfilePayload(
      isPro: _b(j['is_pro']),
      profile: p is Map
          ? PartnerProfileData.fromJson(Map<String, dynamic>.from(p))
          : null,
    );
  }
}
