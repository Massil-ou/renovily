class UserProProfileData {
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

  const UserProProfileData({
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

  factory UserProProfileData.fromJson(Map<String, dynamic> j) =>
      UserProProfileData(
        siret: j['siret']?.toString() ?? j['siret_user']?.toString(),
        companyName: j['company_name']?.toString(),
        tradeName: j['trade_name']?.toString(),
        companyType: j['company_type']?.toString(),
        rcNumber: j['rc_number']?.toString(),
        nifNumber: j['nif_number']?.toString(),
        nisNumber: j['nis_number']?.toString(),
        taxRegime: j['tax_regime']?.toString(),
        vatNumber: _asNullableVatPercent(j['vat_number']),
        statusPro: j['status_pro']?.toString(),
        verifiedAt: j['verified_at']?.toString(),
        requestedAt: j['requested_at']?.toString(),
        updatedAt: j['updated_at']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'siret': siret,
    'company_name': companyName,
    'trade_name': tradeName,
    'company_type': companyType,
    'rc_number': rcNumber,
    'nif_number': nifNumber,
    'nis_number': nisNumber,
    'tax_regime': taxRegime,
    'vat_number': vatNumber,
    'status_pro': statusPro,
    'verified_at': verifiedAt,
    'requested_at': requestedAt,
    'updated_at': updatedAt,
  };

  static double? _asNullableVatPercent(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble().clamp(0.0, 100.0);
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final cleaned = s.replaceAll('%', '').replaceAll(',', '.').trim();
    final p = double.tryParse(cleaned);
    if (p == null) return null;
    return p.clamp(0.0, 100.0);
  }
}

class UserData {
  final String email;
  final String? firstName;
  final String? lastName;
  final String? number;
  final String? wilaya;
  final String? commune;
  final int? soldeUser;
  final String? role;
  final String? referralCode;
  final String? referredBy;
  final int referralConfirmed;
  // pro
  final bool isPro;
  UserProProfileData? proProfile;

  UserData({
    required this.email,
    this.firstName,
    this.lastName,
    this.number,
    this.wilaya,
    this.commune,
    this.soldeUser,
    this.role,
    this.referralCode,
    this.referredBy,
    this.referralConfirmed = 0,
    this.isPro = false,
    this.proProfile,
  });

  factory UserData.fromJson(Map<String, dynamic> j) {
    final role = j['role']?.toString();
    final isPro =
        (j['is_pro'] == true) || ((role ?? '').toLowerCase() == 'partner');

    final pp = j['pro_profile'];
    UserProProfileData? proProfile;
    if (pp is Map<String, dynamic>) {
      proProfile = UserProProfileData.fromJson(pp);
    } else if (pp is Map) {
      proProfile = UserProProfileData.fromJson(Map<String, dynamic>.from(pp));
    }

    return UserData(
      email: (j['email'] ?? '').toString(),
      firstName: j['first_name']?.toString(),
      lastName: j['last_name']?.toString(),
      number: j['number']?.toString(),
      wilaya: j['wilaya']?.toString(),
      commune: j['commune']?.toString(),
      soldeUser: _asNullableInt(j['solde_user']),
      role: role,
      referralCode: j['referral_code']?.toString(),
      referredBy: j['referred_by']?.toString(),
      referralConfirmed: _asInt(j['referral_confirmed'], 0),
      isPro: isPro,
      proProfile: proProfile,
    );
  }

  static int _asInt(dynamic v, int def) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class SubscriptionData {
  final String? type;
  final String? label;
  final int? priceDa;
  final String? startDate;
  final String? endDate;
  final String? status;

  SubscriptionData({
    this.type,
    this.label,
    this.priceDa,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> j) => SubscriptionData(
    type: j['type']?.toString(),
    label: j['label']?.toString(),
    priceDa: _asNullableInt(j['price_da']),
    startDate: j['start_date']?.toString(),
    endDate: j['end_date']?.toString(),
    status: j['status']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    'price_da': priceDa,
    'start_date': startDate,
    'end_date': endDate,
    'status': status,
  };

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class TokensData {
  final String accessToken;
  final int accessExpiresIn;
  final String refreshToken;
  final String refreshExpiresAt;

  TokensData({
    required this.accessToken,
    required this.accessExpiresIn,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  factory TokensData.fromJson(Map<String, dynamic> j) => TokensData(
    accessToken: (j['access_token'] ?? '').toString(),
    accessExpiresIn: j['access_expires_in'] is int
        ? j['access_expires_in'] as int
        : int.tryParse('${j['access_expires_in'] ?? 0}') ?? 0,
    refreshToken: (j['refresh_token'] ?? '').toString(),
    refreshExpiresAt: (j['refresh_expires_at'] ?? '').toString(),
  );

  Map<String, String> toStorage() => {
    'access': accessToken,
    'refresh': refreshToken,
    'access_expires_in': accessExpiresIn.toString(),
    'refresh_expires_at': refreshExpiresAt,
  };
}

class LoginData {
  final TokensData tokens;
  final UserData user;
  final SubscriptionData? subscription;

  LoginData({required this.tokens, required this.user, this.subscription});

  factory LoginData.fromJson(Map<String, dynamic> j) => LoginData(
    tokens: TokensData.fromJson(j),
    user: UserData.fromJson((j['user'] ?? const {}) as Map<String, dynamic>),
    subscription: (j['subscription'] is Map)
        ? SubscriptionData.fromJson(
            Map<String, dynamic>.from(j['subscription']),
          )
        : null,
  );
}

class LoginStep1Data {
  final String? status;
  final int? attemptsMax;

  LoginStep1Data({this.status, this.attemptsMax});

  factory LoginStep1Data.fromJson(Map<String, dynamic> j) => LoginStep1Data(
    status: j['status']?.toString(),
    attemptsMax: j['attempts_max'] is int
        ? j['attempts_max'] as int
        : int.tryParse('${j['attempts_max'] ?? ''}'),
  );
}

class StatusData {
  final String? status;
  StatusData({this.status});
  factory StatusData.fromJson(Map<String, dynamic> j) =>
      StatusData(status: j['status']?.toString());
}

// Requests inchangés

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String number;
  final String wilaya;
  final String commune;
  final String siret;
  final String referralCode;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.number,
    required this.wilaya,
    required this.commune,
    this.siret = '',
    this.referralCode = '',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'number': number,
      'wilaya': wilaya,
      'commune': commune,
    };

    if (siret.trim().isNotEmpty) map['siret'] = siret.trim();
    if (referralCode.trim().isNotEmpty) {
      map['referral_code'] = referralCode.trim();
    }

    return map;
  }
}

class VerifyRegisterOtpRequest {
  final String email;
  final String otp;
  final String password;

  VerifyRegisterOtpRequest({
    required this.email,
    required this.otp,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'password': password,
  };
}

class EmailOnlyRequest {
  final String email;
  EmailOnlyRequest(this.email);
  Map<String, dynamic> toJson() => {'email': email};
}

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginOtpRequest {
  final String email;
  final String otp;
  final String password;

  LoginOtpRequest({
    required this.email,
    required this.otp,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'password': password,
  };
}

class RefreshRequest {
  final String refreshToken;
  RefreshRequest(this.refreshToken);
  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}
