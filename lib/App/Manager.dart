import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Adresse/dz_lookup.dart';
import '../Auth/Login/LoginManager.dart';
import '../Auth/NewPassword/PasswordManager.dart';
import '../Auth/Shared/AuthModels.dart';
import '../Auth/Signin/RegisterManager.dart';
import '../Darek/DarekManager.dart';
import '../DarekDetails/DarekDetailManager.dart';
import '../Dashboard/FavorisOffers/FavorisDarekManager.dart';
import '../Dashboard/Reviews/OfferReviewsManager.dart';
import '../LoginAuto/AutoLoginManager.dart';
import '../Logout/LogoutManager.dart';
import '../Dashboard/AddDarek/AddDarekManager.dart';
import 'AppLanguage.dart';
import 'BaseResponse.dart';
import '../Notification/FcmService.dart';
import 'GlobalSingleton.dart';
import 'HelperService.dart';
import '../Dashboard/LanguageService.dart';
import '../Dashboard/ListDarek/MesAnnoncesManager.dart';
import '../Dashboard/PartnerClient/ClientProfileManager.dart';
import '../Dashboard/PartnerProfile/PartnerProfileManager.dart';

class Manager {
  static final Manager _instance = Manager._internal();
  factory Manager() => _instance;
  Manager._internal();

  // ---------------- Language ----------------

  LanguageService? _languageService;
  LanguageService get languageService => _languageService ??= LanguageService();

  WinyCar get winyCarTranslation => WinyCar(languageService.appLanguage);

  // ---------------- Global ----------------

  // ---------------- Core singletons ----------------

  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.winycar.fr',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));


  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // ---------------- HelperService (Auth + refresh + force logout) ----------------

  HelperService? _helperService;

  HelperService get helperService {
    return _helperService ??= HelperService(
      dio,
      storage,
      deviceMacKeyB64: "u4InvlLCuedXt67EaUZHS1cWzJjc54K8Gj3jQ8IhAcI=",
      onForceLogout: (reason) async {
        // 1) Logout complet (reset state + FCM + server logout best effort)
        try {
          await logoutManager.logout();
        } catch (_) {}

        // 2) Déclencher navigation côté UI (Dashboard écoute ce flag)
        try {
          await storage.write(key: 'force_logout', value: '1');
          await storage.write(key: 'force_logout_reason', value: reason);
        } catch (_) {}
      },
    );
  }

  AddAvisDarekManager? _addAvisDarekManager;
  AddAvisDarekManager get addAvisDarekManager =>
      _addAvisDarekManager ??= AddAvisDarekManager(this, helperService);

  FavorisOffersManager? _favorisAnnoncesManager;
  FavorisOffersManager get favorisAnnoncesManager =>
      _favorisAnnoncesManager ??= FavorisOffersManager(this, helperService);

  MesAnnoncesManager? _mesAnnoncesManager;
  MesAnnoncesManager get mesAnnoncesManager =>
      _mesAnnoncesManager ??= MesAnnoncesManager(this, helperService);

  DzLookupService? _dzLookupService;
  DzLookupService get dzLookupService => _dzLookupService ??= DzLookupService();

  AddOfferManager? _addOffersManager;
  AddOfferManager get addOfferManager =>
      _addOffersManager ??= AddOfferManager(this, helperService);

  PartnerProfileManager? _partnerProfileManager;
  PartnerProfileManager get partnerProfileManager =>
      _partnerProfileManager ??= PartnerProfileManager(this, helperService);

  ClientProfileManager? _clientProfileManager;
  ClientProfileManager get clientProfileManager =>
      _clientProfileManager ??= ClientProfileManager(this, helperService);

  DarekManager? _darekManager;
  DarekManager get homeManager => _darekManager ??= DarekManager(this, helperService);

  GlobalSingleton? _globalSingleton;
  GlobalSingleton get globalSingleton => _globalSingleton ??= GlobalSingleton();


  LoginManager? _loginManager;
  LoginManager get loginManager =>
      _loginManager ??= LoginManager(this, helperService);

  PasswordManager? _passwordManager;
  PasswordManager get passwordManager =>
      _passwordManager ??= PasswordManager(this, helperService);

  RegisterManager? _registerManager;
  RegisterManager get registerManager =>
      _registerManager ??= RegisterManager(this, helperService);

  LogoutManager? _logoutManager;
  LogoutManager get logoutManager =>
      _logoutManager ??= LogoutManager(this, helperService);

  OfferReviewsManager? _offerReviewsManager;
  OfferReviewsManager get offerReviewsManager =>
      _offerReviewsManager ??= OfferReviewsManager(this, helperService);

  AutoLoginManager? _autoLoginManager;
  AutoLoginManager get autoLoginManager =>
      _autoLoginManager ??= AutoLoginManager(this, helperService);

  // services

  FcmService? _fcmService;
  FcmService get fcmService => _fcmService ??= FcmService(this, helperService);

  // ---------------- Auth state ----------------

  TokensData? tokens;
  UserData? currentUser;
  SubscriptionData? currentSubscription;

  String get currentUserEmail =>
      (currentUser?.email ?? '').toLowerCase().trim();

  bool get isAuthenticated => tokens?.accessToken.isNotEmpty == true;

  String? lastAccountStatus;
  int? attemptsMax;
  BaseResponse<LoginData>? lastAutoLogin;

  // ---------------- Helpers UI ----------------

  String readableMessage(BaseResponse resp) {
    final custom = ApiCodes.messageFor(resp.code);
    return custom.isNotEmpty
        ? custom
        : (resp.message.isNotEmpty ? resp.message : 'Une erreur est survenue.');
  }

  // ============ Remember me ============

  static const _kRememberKey = 'auth_remember';
  static const _kRememberEmailKey = 'auth_email';
  static const _kRememberPasswordKey = 'auth_password';

  Future<void> setRememberedCredentials({
    required bool remember,
    String? email,
    String? password,
  }) async {
    if (!remember) {
      await storage.delete(key: _kRememberKey);
      await storage.delete(key: _kRememberEmailKey);
      await storage.delete(key: _kRememberPasswordKey);
      return;
    }

    await storage.write(key: _kRememberKey, value: '1');

    if ((email?.isNotEmpty ?? false)) {
      await storage.write(key: _kRememberEmailKey, value: email);
    }
    if ((password?.isNotEmpty ?? false)) {
      await storage.write(key: _kRememberPasswordKey, value: password);
    }
  }

  Future<({bool remember, String email, String password})>
  getRememberedCredentials() async {
    final r = await storage.read(key: _kRememberKey);
    final em = await storage.read(key: _kRememberEmailKey) ?? '';
    final pw = await storage.read(key: _kRememberPasswordKey) ?? '';

    return (remember: r == '1', email: em, password: pw);
  }

  // ============ Force logout flag helpers (optional) ============

  Future<bool> consumeForceLogoutFlag() async {
    final v = await storage.read(key: 'force_logout');
    if (v == '1') {
      await storage.delete(key: 'force_logout');
      return true;
    }
    return false;
  }

  Future<String?> readForceLogoutReason() async {
    final r = await storage.read(key: 'force_logout_reason');
    if (r == null || r.isEmpty) return null;
    return r;
  }

  Future<void> clearForceLogoutReason() async {
    await storage.delete(key: 'force_logout_reason');
  }
}
