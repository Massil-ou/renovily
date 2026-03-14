class BaseResponse<T> {
  final bool success;
  final String message;
  final int code;
  final T? data;

  BaseResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
  });

  static BaseResponse<R> fromJson<R>(
    Map<String, dynamic> json, {
    R Function(Map<String, dynamic>)? parse,
  }) {
    final success = (json['success'] ?? false) == true;
    final message = (json['message'] ?? '') as String;
    final code = (json['code'] is int)
        ? json['code'] as int
        : int.tryParse('${json['code'] ?? -1}') ?? -1;

    R? data;
    final raw = json['data'];
    if (parse != null && raw is Map<String, dynamic>) {
      try {
        data = parse(raw);
      } catch (_) {
        /* ignore */
      }
    } else {
      data = null;
    }

    return BaseResponse<R>(
      success: success,
      message: message,
      code: code,
      data: data,
    );
  }
}

class ApiCodes {
  // register.php
  static const C_REG_OK_CREATED = 601;
  static const C_REG_OK_UPDATED = 602;
  static const C_REG_EMAIL_EXISTS = 603;
  static const C_REG_INPUT_REQUIRED = 604;
  static const C_REG_EMAIL_INVALID = 605;
  static const C_REG_SIRET_INVALID = 606;
  static const C_REG_HASH_ERROR = 607;
  static const C_REG_TOO_MANY_ATTEMPTS = 608;
  static const C_REG_INTERNAL = 699;
  static const C_REG_DEVICE_REQUIRED = 609;
  static const C_REG_FIRSTNAME_INVALID = 610;
  static const C_REG_LASTNAME_INVALID = 611;
  static const C_REG_NUMBER_INVALID = 612;
  static const C_REG_ADDRESS_TOO_LONG = 613;
  static const C_REG_METHOD_NOT_ALLOWED = 614;
  static const C_REG_PAYLOAD_TOO_LARGE = 615;
  static const C_REG_EMAIL_DAILY_LIMIT = 616;

  // verify_register_otp.php + login codes
  static const C_VRY_OK_ACTIVATED = 351;
  static const C_VRY_EMAIL_AND_OTP_REQUIRED = 352;
  static const C_VRY_USER_NOT_FOUND = 353;
  static const C_VRY_STATUS_NOT_PENDING = 354;
  static const C_VRY_OTP_INVALID = 355;
  static const C_VRY_OTP_EXPIRED = 356;
  static const C_VRY_DEVICE_REQUIRED = 358;
  static const C_VRY_INTERNAL_ERROR = 399;

  static const C_LOG_OK = 501;
  static const C_LOG_EMAIL_PWD_DEVICE_REQUIRED = 502;
  static const C_LOG_INVALID_CREDENTIALS = 503;
  static const C_LOG_ACCOUNT_NOT_ACTIVE = 504;
  static const C_LOG_TOO_MANY_ATTEMPTS = 505;
  static const C_LOG_OTP_REQUIRED = 506;
  static const C_LOG_DB_ERROR = 599;

  // resend_register_otp.php
  static const C_RSN_OK_SENT = 371;
  static const C_RSN_EMAIL_REQUIRED = 372;
  static const C_RSN_USER_NOT_FOUND = 373;
  static const C_RSN_STATUS_NOT_PENDING = 374;
  static const C_RSN_DEVICE_REQUIRED = 375;
  static const C_RSN_INTERNAL_ERROR = 399;

  // refresh.php (auto-login)
  static const C_AUTO_OK = 531;
  static const C_AUTO_REFRESH_REQUIRED = 532;
  static const C_AUTO_DEVICE_REQUIRED = 533;
  static const C_AUTO_REFRESH_INVALID = 534;
  static const C_AUTO_REFRESH_REVOKED = 535;
  static const C_AUTO_REFRESH_EXPIRED = 536;
  static const C_AUTO_DEVICE_MISMATCH = 537;
  static const C_AUTO_USER_NOT_FOUND = 538;
  static const C_AUTO_ACCOUNT_NOT_ACTIVE = 539;
  static const C_AUTO_DB_ERROR = 599;

  // send_password.php
  static const C_RESET_LINK_OK = 801;
  static const C_RESET_EMAIL_REQUIRED = 802;
  static const C_RESET_DEVICE_REQUIRED = 803;
  static const C_RESET_TOO_MANY_ATTEMPTS = 505;
  static const C_RESET_INTERNAL = 899;

  // cars_create.php
  static const C_CARS_OK_CREATED = 681;
  static const C_CARS_METHOD_NOT_ALLOWED = 682;
  static const C_CARS_INPUT_REQUIRED = 683;
  static const C_CARS_DEVICE_REQUIRED = 684;
  static const C_CARS_USER_NOT_FOUND = 685;
  static const C_CARS_TOO_MANY_ATTEMPTS = 686;
  static const C_CARS_DB_ERROR = 699;
  static const C_CARS_SQL_DUPLICATE = 687;
  static const C_CARS_SQL_FK = 688;
  static const C_CARS_SQL_NOT_NULL = 689;
  static const C_CARS_SQL_ENUM = 690;
  static const C_CARS_INTERNAL = 691;

  static String messageFor(int code) {
    switch (code) {
      case C_REG_OK_CREATED:
        return 'Inscription créée. Vérifiez votre e-mail pour valider votre compte.';
      case C_REG_OK_UPDATED:
        return 'Compte en attente mis à jour. Vérifiez votre e-mail.';
      case C_REG_EMAIL_EXISTS:
        return 'Cette adresse e-mail est déjà utilisée.';
      case C_REG_INPUT_REQUIRED:
        return 'E-mail, mot de passe et téléphone sont requis.';
      case C_REG_EMAIL_INVALID:
        return 'Adresse e-mail invalide.';
      case C_REG_SIRET_INVALID:
        return 'Le SIRET doit contenir 14 chiffres.';
      case C_REG_FIRSTNAME_INVALID:
        return 'Le prénom doit contenir uniquement des lettres (1–30).';
      case C_REG_LASTNAME_INVALID:
        return 'Le nom doit contenir uniquement des lettres (1–30).';
      case C_REG_NUMBER_INVALID:
        return 'Le numéro doit contenir exactement 10 chiffres.';
      case C_REG_ADDRESS_TOO_LONG:
        return 'Adresse trop longue.';
      case C_REG_EMAIL_DAILY_LIMIT:
        return 'Quota de 5 e-mails/24h atteint. Réessayez plus tard.';
      case C_REG_TOO_MANY_ATTEMPTS:
        return 'Trop de tentatives, réessayez plus tard.';
      case C_REG_DEVICE_REQUIRED:
        return 'Identifiant d’appareil requis.';
      case C_REG_METHOD_NOT_ALLOWED:
        return 'Méthode non autorisée.';
      case C_REG_PAYLOAD_TOO_LARGE:
        return 'Requête trop volumineuse.';
      case C_REG_INTERNAL:
        return 'Erreur interne, réessayez plus tard.';
      case C_LOG_OTP_REQUIRED:
        return 'Code OTP envoyé, vérifiez votre e-mail.';
      case C_LOG_EMAIL_PWD_DEVICE_REQUIRED:
        return 'L’e-mail, le mot de passe et le device sont requis.';
      case C_LOG_INVALID_CREDENTIALS:
        return 'Identifiants invalides.';
      case C_LOG_ACCOUNT_NOT_ACTIVE:
        return 'Le compte n’est pas actif.';
      case C_LOG_TOO_MANY_ATTEMPTS:
        return 'Trop de tentatives, réessayez plus tard.';
      case C_LOG_DB_ERROR:
        return 'Erreur interne, réessayez plus tard.';
      case C_LOG_OK:
        return 'Connexion réussie.';
      case C_VRY_OK_ACTIVATED:
        return 'Compte activé.';
      case C_VRY_EMAIL_AND_OTP_REQUIRED:
        return 'E-mail, code OTP et mot de passe sont requis.';
      case C_VRY_USER_NOT_FOUND:
        return 'Utilisateur introuvable.';
      case C_VRY_STATUS_NOT_PENDING:
        return 'Le compte n’est pas en attente de vérification.';
      case C_VRY_OTP_INVALID:
        return 'Code OTP invalide ou mot de passe incorrect.';
      case C_VRY_OTP_EXPIRED:
        return 'Code OTP expiré.';
      case C_VRY_DEVICE_REQUIRED:
        return 'Identifiant d’appareil requis.';
      case C_VRY_INTERNAL_ERROR:
        return 'Erreur interne, réessayez plus tard.';
      case C_RSN_OK_SENT:
        return 'Nouveau code OTP envoyé par e-mail.';
      case C_RSN_EMAIL_REQUIRED:
        return 'E-mail requis et valide.';
      case C_RSN_USER_NOT_FOUND:
        return 'Utilisateur introuvable.';
      case C_RSN_STATUS_NOT_PENDING:
        return 'Le compte n’est pas en attente de vérification.';
      case C_RSN_DEVICE_REQUIRED:
        return 'Identifiant d’appareil requis.';
      case C_RSN_INTERNAL_ERROR:
        return 'Erreur interne, réessayez plus tard.';
      case C_AUTO_OK:
        return 'Connexion automatique réussie.';
      case C_AUTO_REFRESH_REQUIRED:
        return 'Le refresh_token est requis.';
      case C_AUTO_DEVICE_REQUIRED:
        return 'Le device (X-Device-Id) est requis.';
      case C_AUTO_REFRESH_INVALID:
        return 'Refresh token invalide.';
      case C_AUTO_REFRESH_REVOKED:
        return 'Refresh token révoqué.';
      case C_AUTO_REFRESH_EXPIRED:
        return 'Refresh token expiré.';
      case C_AUTO_DEVICE_MISMATCH:
        return 'Le token ne correspond pas au device fourni.';
      case C_AUTO_USER_NOT_FOUND:
        return 'Utilisateur introuvable.';
      case C_AUTO_ACCOUNT_NOT_ACTIVE:
        return 'Le compte n’est pas actif.';
      case C_AUTO_DB_ERROR:
        return 'Erreur interne, réessayez plus tard.';
      case C_RESET_LINK_OK:
        return 'Si un compte existe, un lien de réinitialisation a été envoyé.';
      case C_RESET_EMAIL_REQUIRED:
        return 'E-mail requis ou invalide.';
      case C_RESET_DEVICE_REQUIRED:
        return 'Le device (X-Device-Id) est requis.';
      case C_RESET_TOO_MANY_ATTEMPTS:
        return 'Trop de tentatives, réessayez plus tard.';
      case C_RESET_INTERNAL:
        return 'Erreur interne, réessayez plus tard.';
      case C_CARS_OK_CREATED:
        return 'Voiture insérée avec succès.';
      case C_CARS_METHOD_NOT_ALLOWED:
        return 'Méthode non autorisée.';
      case C_CARS_INPUT_REQUIRED:
        return 'Champs requis: iduser, matricule, wilaya.';
      case C_CARS_DEVICE_REQUIRED:
        return 'Identifiant appareil requis';
      case C_CARS_USER_NOT_FOUND:
        return 'Utilisateur inexistant.';
      case C_CARS_TOO_MANY_ATTEMPTS:
        return 'Trop de tentatives, réessayez plus tard.';
      case C_CARS_SQL_DUPLICATE:
        return 'Conflit: matricule déjà existant.';
      case C_CARS_SQL_FK:
        return 'Utilisateur invalide.';
      case C_CARS_SQL_NOT_NULL:
        return 'Champ obligatoire manquant.';
      case C_CARS_SQL_ENUM:
        return 'Valeur invalide pour un champ.';
      case C_CARS_DB_ERROR:
      case C_CARS_INTERNAL:
        return 'Erreur interne, réessayez plus tard.';
    }
    return '';
  }
}
