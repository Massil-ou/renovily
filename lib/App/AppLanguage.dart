import '../Dashboard/LanguageService.dart';
import 'Manager.dart';

class WinyCar {
  final AppLanguage lang;
  WinyCar(this.lang);

  static WinyCar of(Manager m) => WinyCar(m.languageService.appLanguage);

  String _t(String fr, String en, String ar) {
    switch (lang) {
      case AppLanguage.fr:
        return fr;
      case AppLanguage.en:
        return en;
      case AppLanguage.ar:
        return ar;
    }
  }

  String _tp(String fr, String en, String ar, [Map<String, String>? params]) {
    String raw = _t(fr, en, ar);
    if (params == null || params.isEmpty) return raw;
    var out = raw;
    params.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }



  // =========================
  // COMMON / AUTH UI
  // =========================

  String get appName => _t('Renovily', 'Renovily', 'رينوفيلي');
  String get ok => _t('OK', 'OK', 'حسناً');
  String get yes => _t('Oui', 'Yes', 'نعم');
  String get no => _t('Non', 'No', 'لا');
  String get back => _t('Retour', 'Back', 'رجوع');
  String get close => _t('Fermer', 'Close', 'إغلاق');
  String get cancel => _t('Annuler', 'Cancel', 'إلغاء');
  String get confirm => _t('Confirmer', 'Confirm', 'تأكيد');
  String get save => _t('Enregistrer', 'Save', 'حفظ');
  String get loading => _t('Chargement...', 'Loading...', 'جارٍ التحميل...');
  String get success => _t('Succès', 'Success', 'نجاح');
  String get error => _t('Erreur', 'Error', 'خطأ');
  String get info => _t('Information', 'Information', 'معلومة');
  String get required => _t('Obligatoire', 'Required', 'مطلوب');

  // =========================
  // NAV AUTH
  // =========================

  String get signIn => _t('Connexion', 'Sign in', 'تسجيل الدخول');
  String get signUp => _t('Inscription', 'Sign up', 'إنشاء حساب');
  String get login => _t('Se connecter', 'Log in', 'تسجيل الدخول');
  String get signOut => _t('Déconnexion', 'Sign out', 'تسجيل الخروج');

  String get signInLabel => _t('Se connecter', 'Sign in', 'تسجيل الدخول');
  String get signUpLabel => _t('Créer un compte', 'Sign up', 'إنشاء حساب');
  String get signInOrCreateAccount => _t(
    'Connexion / Inscription',
    'Sign in / Sign up',
    'تسجيل الدخول / إنشاء حساب',
  );
  String get signInSignUpTooltip => _t(
    'Connexion / Inscription',
    'Sign in / Sign up',
    'تسجيل الدخول / التسجيل',
  );

  // =========================
  // LOGIN
  // =========================

  String get welcomeBack =>
      _t('Heureux de vous revoir', 'Welcome back', 'مرحباً بعودتك');

  String get signInToContinue => _t(
    'Connectez-vous pour continuer',
    'Sign in to continue',
    'سجّل الدخول للمتابعة',
  );

  String get rememberMe => _t('Se souvenir de moi', 'Remember me', 'تذكرني');

  String get invalidCredentials => _t(
    'Identifiants invalides.',
    'Invalid credentials.',
    'بيانات اعتماد غير صحيحة.',
  );

  String get loginError =>
      _t('Erreur de connexion.', 'Login error.', 'خطأ في تسجيل الدخول.');

  String get loginSuccess => _t(
    'Connexion réussie.',
    'Logged in successfully.',
    'تم تسجيل الدخول بنجاح.',
  );

  String get forgotPasswordQuestion =>
      _t('Mot de passe oublié ?', 'Forgot password?', 'هل نسيت كلمة المرور؟');

  String get pleaseLogin => _t(
    'Veuillez vous connecter pour continuer',
    'Please log in to continue',
    'يرجى تسجيل الدخول للمتابعة',
  );

  // =========================
  // SIGNUP
  // =========================

  String get createAccount =>
      _t('Créer un compte', 'Create an account', 'إنشاء حساب');

  String get createMyAccount =>
      _t('Créer mon compte', 'Create my account', 'إنشاء حسابي');

  String get step1of2Info => _t(
    'Étape 1 sur 2 : informations',
    'Step 1 of 2: information',
    'الخطوة 1 من 2: المعلومات',
  );

  String get accountVerification =>
      _t('Vérification du compte', 'Account verification', 'تأكيد الحساب');

  String get step2of2Otp => _t(
    'Étape 2 sur 2 : code OTP',
    'Step 2 of 2: OTP code',
    'الخطوة 2 من 2: رمز التحقق',
  );

  String get firstName => _t('Prénom', 'First name', 'الاسم');
  String get firstNameRequired =>
      _t('Prénom requis', 'First name required', 'الاسم مطلوب');
  String get firstNameInvalid =>
      _t('Prénom invalide', 'Invalid first name', 'اسم غير صالح');

  String get lastName => _t('Nom', 'Last name', 'اللقب');
  String get lastNameRequired =>
      _t('Nom requis', 'Last name required', 'اللقب مطلوب');
  String get lastNameInvalid =>
      _t('Nom invalide', 'Invalid last name', 'لقب غير صالح');

  String get email => _t('Email', 'Email', 'البريد الإلكتروني');
  String get emailHint =>
      _t('exemple@mail.com', 'example@mail.com', 'example@mail.com');
  String get emailRequired =>
      _t('Email requis', 'Email required', 'البريد الإلكتروني مطلوب');
  String get emailInvalid =>
      _t('Email invalide', 'Invalid email', 'بريد إلكتروني غير صالح');

  String get password => _t('Mot de passe', 'Password', 'كلمة المرور');
  String get passwordHint => '••••••••';
  String get passwordRequired =>
      _t('Mot de passe requis', 'Password required', 'كلمة المرور مطلوبة');
  String get password6chars =>
      _t('Au moins 6 caractères', 'At least 6 characters', 'على الأقل 6 أحرف');

  String passwordMinChars(int n) => _tp(
    'Au moins {$n} caractères',
    'At least {$n} characters',
    'على الأقل {$n} أحرف',
    {'n': n.toString()},
  );

  String get passwordMustContainUppercase => _t(
    'Le mot de passe doit contenir au moins une majuscule',
    'Password must contain at least one uppercase letter',
    'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل',
  );

  String get passwordMustContainNumber => _t(
    'Le mot de passe doit contenir au moins un chiffre',
    'Password must contain at least one number',
    'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل',
  );

  String get showHidePassword => _t(
    'Afficher/masquer le mot de passe',
    'Show/hide password',
    'إظهار/إخفاء كلمة المرور',
  );

  String get phoneNumber => _t('Numéro', 'Phone number', 'رقم الهاتف');
  String get phoneHint =>
      _t('07 xx xx xx xx', '07 xx xx xx xx', '07 xx xx xx xx');
  String get phoneRequired =>
      _t('Numéro requis', 'Phone required', 'رقم الهاتف مطلوب');
  String get phoneFrInvalid => _t(
    'Commence par 0 et 10 chiffres',
    'Starts with 0 and 10 digits',
    'يبدأ بصفر ويحتوي على 10 أرقام',
  );
  String get phoneDzInvalid => _t(
    'Téléphone DZ invalide',
    'Invalid DZ phone',
    'رقم هاتف جزائري غير صالح',
  );

  String get wilaya => _t('Wilaya', 'Wilaya', 'الولاية');
  String get commune => _t('Commune', 'Commune', 'البلدية');
  String get wilayaRequired =>
      _t('Wilaya requise', 'Wilaya required', 'الولاية مطلوبة');
  String get communeRequired =>
      _t('Commune requise', 'Commune required', 'البلدية مطلوبة');

  String get selectWilayaCommune => _t(
    'Veuillez sélectionner la wilaya et la commune',
    'Please select the wilaya and the commune',
    'يرجى اختيار الولاية والبلدية',
  );

  String get hasReferralCode => _t(
    'Avez-vous un code de parrainage ?',
    'Do you have a referral code?',
    'هل لديك رمز إحالة؟',
  );

  String get referralCode =>
      _t('Code de parrainage', 'Referral code', 'رمز الإحالة');
  String get referralCodeHint => 'WINY-ABC123';
  String get referralCodeRequired => _t(
    'Code de parrainage requis',
    'Referral code required',
    'رمز الإحالة مطلوب',
  );
  String get referralCodeInvalid =>
      _t('Code invalide', 'Invalid code', 'رمز غير صالح');

  String get acceptCGU => _t(
    'J’accepte les Conditions Générales d’Utilisation',
    'I accept the Terms of Use',
    'أوافق على شروط الاستخدام',
  );

  String get acceptCGUError => _t(
    'Veuillez accepter les CGU pour continuer.',
    'Please accept the Terms to continue.',
    'يرجى قبول الشروط للمتابعة.',
  );

  String get signupFailed =>
      _t('Échec de l’inscription.', 'Sign up failed.', 'فشل التسجيل.');

  String get codeSentCheckEmail => _t(
    'Code envoyé. Consultez votre e-mail.',
    'Code sent. Check your email.',
    'تم إرسال الرمز. تحقق من بريدك الإلكتروني.',
  );

  String get accountVerifiedWelcome => _t(
    'Compte vérifié. Bienvenue !',
    'Account verified. Welcome!',
    'تم التحقق من الحساب. أهلاً بك!',
  );

  String get editMyInfo =>
      _t('Modifier mes informations', 'Edit my information', 'تعديل معلوماتي');

  // =========================
  // OTP
  // =========================

  String get codeVerification =>
      _t('Vérification par code', 'Code verification', 'التحقق بواسطة الرمز');

  String get step2EnterOtpPwd => _t(
    'Étape 2 sur 2 : saisissez le code OTP et votre mot de passe',
    'Step 2 of 2: enter the OTP code and your password',
    'الخطوة 2 من 2: أدخل رمز التحقق وكلمة المرور',
  );

  String get otpCode => _t('Code OTP', 'OTP Code', 'رمز التحقق');
  String get otpHint => _t('6 caractères', '6 characters', '6 أحرف');
  String get codeRequired => _t('Code requis', 'Code required', 'الرمز مطلوب');
  String get codeInvalid => _t('Code invalide', 'Invalid code', 'رمز غير صالح');
  String get invalidOtp =>
      _t('Code OTP invalide.', 'Invalid OTP code.', 'رمز التحقق غير صالح.');

  String get validate => _t('Valider', 'Validate', 'تأكيد');
  String get validateAndLogin => _t(
    'Valider et se connecter',
    'Validate and sign in',
    'تأكيد وتسجيل الدخول',
  );

  String get resendCode =>
      _t('Renvoyer le code', 'Resend code', 'إعادة إرسال الرمز');

  String resendIn(int s) => _tp(
    'Renvoyer ({$s}s)',
    'Resend in {$s}s',
    'إعادة الإرسال خلال {$s}ث',
    {'s': s.toString()},
  );

  String get cannotResendCode => _t(
    'Impossible de renvoyer le code.',
    'Unable to resend the code.',
    'تعذر إعادة إرسال الرمز.',
  );

  String get codeResent =>
      _t('Code renvoyé.', 'Code resent.', 'تمت إعادة إرسال الرمز.');

  String get otpSentCheckEmail => _t(
    'Code OTP envoyé, vérifiez votre e-mail.',
    'OTP code sent, check your email.',
    'تم إرسال رمز التحقق، تحقق بريدك.',
  );

  String get otpValidationFailed => _t(
    'Validation OTP impossible.',
    'OTP validation failed.',
    'فشل التحقق من الرمز.',
  );

  String get otpValidationError => _t(
    'Erreur pendant la validation du code.',
    'Error while validating the code.',
    'حدث خطأ أثناء التحقق من الرمز.',
  );

  String codeSentTo(String email) => _tp(
    'Un code a été envoyé à $email. Vérifiez vos spams si vous ne le trouvez pas.',
    'A code was sent to $email. Please check your spam folder if you cannot find it.',
    'تم إرسال رمز إلى $email. يرجى التحقق من البريد غير الهام إذا لم تجده.',
  );

  // =========================
  // FORGOT PASSWORD
  // =========================

  String get forgotPassword =>
      _t('Mot de passe oublié', 'Forgot password', 'نسيت كلمة المرور');

  String get enterEmailResetLink => _t(
    'Saisissez votre e-mail. Un lien de réinitialisation vous sera envoyé.',
    'Enter your email. A reset link will be sent to you.',
    'أدخل بريدك الإلكتروني وسيصلك رابط لإعادة التعيين.',
  );

  String get sendLink => _t('Envoyer le lien', 'Send link', 'إرسال الرابط');

  String get resendLink =>
      _t('Renvoyer le lien', 'Resend link', 'إعادة إرسال الرابط');

  String get cannotSendLink => _t(
    "Impossible d'envoyer le lien.",
    'Unable to send the link.',
    'تعذر إرسال الرابط.',
  );

  String get resetLinkGeneric => _t(
    'Si un compte existe, un lien de réinitialisation a été envoyé.',
    'If an account exists, a reset link has been sent.',
    'إذا كان الحساب موجودًا، فقد تم إرسال رابط إعادة التعيين.',
  );

  String resetLinkSentTo(String email) => _t(
    'Un lien vous a été envoyé par email ($email) pour changer le mot de passe.',
    'A link has been sent by email ($email) to change your password.',
    'تم إرسال رابط عبر البريد الإلكتروني ($email) لتغيير كلمة المرور.',
  );

  String get backToEmailPwd => _t(
    'Revenir à la saisie e-mail / mot de passe',
    'Back to email / password',
    'العودة إلى البريد / كلمة المرور',
  );

  // =========================
  // RESET PASSWORD
  // =========================

  String get resetPassword => _t(
    'Réinitialiser le mot de passe',
    'Reset password',
    'إعادة تعيين كلمة المرور',
  );

  String resetForEmail(String email) =>
      _tp('Pour {$email}', 'For {$email}', 'لـ {$email}', {'email': email});

  String get newPassword =>
      _t('Nouveau mot de passe', 'New password', 'كلمة المرور الجديدة');

  String get confirmPassword =>
      _t('Confirmer le mot de passe', 'Confirm password', 'تأكيد كلمة المرور');

  String get changePassword =>
      _t('Changer le mot de passe', 'Change password', 'تغيير كلمة المرور');

  String get passwordsDontMatch => _t(
    'Les mots de passe ne correspondent pas.',
    'Passwords do not match.',
    'كلمتا المرور غير متطابقتين.',
  );

  String get passwordChangedPleaseLogin => _t(
    'Mot de passe modifié. Veuillez vous reconnecter.',
    'Password changed. Please sign in again.',
    'تم تغيير كلمة المرور. يُرجى تسجيل الدخول مجددًا.',
  );

  String get numberInvalid =>
      _t('Nombre invalide', 'Invalid number', 'رقم غير صالح');
  String get priceInvalid =>
      _t('Prix invalide', 'Invalid price', 'سعر غير صالح');

  String get yearInvalid =>
      _t('Année invalide', 'Invalid year', 'سنة غير صالحة');

  String get myAccount => _t('Mon compte', 'My account', 'حسابي');
  String get clientProfileTitle =>
      _t('Profil client', 'Client profile', 'الملف الشخصي');

  String get edit => _t('Modifier', 'Edit', 'تعديل');


  String get cannotChangePassword => _t(
    'Impossible de changer le mot de passe.',
    'Unable to change password.',
    'تعذّر تغيير كلمة المرور.',
  );

  String get securityNoteResetLinkOrigin => _t(
    'Par sécurité, le lien doit provenir de https://renovily.com.',
    'For security, the link must come from https://renovily.com.',
    'لأسباب أمنية، يجب أن يكون الرابط من https://renovily.com.',
  );

  String get passwordRules8MajMinDigitSpecial => _t(
    '8+ caractères, majuscule, minuscule, chiffre et caractère spécial.',
    '8+ chars, uppercase, lowercase, digit and special character.',
    '٨+ أحرف، حرف كبير وصغير ورقم ورمز خاص.',
  );

  // =========================
  // LANGUAGE
  // =========================

  String get language => _t('Langue', 'Language', 'اللغة');
  String get french => _t('Français', 'French', 'الفرنسية');
  String get english => _t('Anglais', 'English', 'الإنجليزية');
  String get arabic => _t('Arabe', 'Arabic', 'العربية');



  String get proProfileTitle =>
      _t('Profil professionnel', 'Professional profile', 'الملف المهني');

  String get proFieldCompanyName =>
      _t('Raison sociale', 'Company name', 'الاسم القانوني');

  String get proFieldTradeName =>
      _t('Nom commercial', 'Trade name', 'الاسم التجاري');

  String get proFieldCompanyType =>
      _t('Type société', 'Company type', 'نوع الشركة');

  String get proFieldSiret =>
      _t('SIRET', 'SIRET', 'رقم SIRET');

  String get proFieldRc =>
      _t('RC', 'Trade register', 'السجل التجاري');

  String get proFieldNif =>
      _t('NIF', 'Tax ID (NIF)', 'الرقم الجبائي');

  String get proFieldNis =>
      _t('NIS', 'Statistical ID (NIS)', 'الرقم الإحصائي');

  String get proFieldTax =>
      _t('Régime fiscal', 'Tax regime', 'النظام الجبائي');

  String get proFieldVat =>
      _t('TVA', 'VAT', 'الضريبة على القيمة المضافة');

  String get proActionSendRequest =>
      _t('Envoyer la demande', 'Send request', 'إرسال الطلب');

  String get proActionEdit =>
      _t('Modifier', 'Edit', 'تعديل');

  String get proActionSave =>
      _t('Enregistrer', 'Save', 'حفظ');

  String get statusVerified =>
      _t('Vérifié', 'Verified', 'مُعتمد');

  String get statusRejected =>
      _t('Refusé', 'Rejected', 'مرفوض');

  String get statusPending =>
      _t('En attente', 'Pending', 'قيد المراجعة');


  String get termsTitle => _t(
    'Conditions d’utilisation',
    'Terms of Use',
    'شروط الاستخدام',
  );

  String get termsLastUpdate => _t(
    'Dernière mise à jour : 13/03/2026',
    'Last update: 13/03/2026',
    'آخر تحديث: 13/03/2026',
  );

  String get chipSupport => _t(
    'Support',
    'Support',
    'الدعم',
  );

  String get chipPrivacy => _t(
    'Confidentialité',
    'Privacy',
    'الخصوصية',
  );

  String get termsIntro => _t(
    'Les présentes Conditions d’utilisation encadrent l’accès et l’utilisation de la plateforme Renovily, une application de mise en relation entre clients recherchant des prestations dans le secteur du BTP et professionnels proposant leurs services.',
    'These Terms of Use govern access to and use of the Renovily platform, an application connecting clients seeking construction and building services with professionals offering their services.',
    'تنظم شروط الاستخدام هذه الوصول إلى منصة Renovily واستخدامها، وهي تطبيق يربط بين العملاء الباحثين عن خدمات في قطاع البناء والأشغال وبين المهنيين الذين يقدمون هذه الخدمات.',
  );

  String get termsS1Title => _t(
    '1. Objet de la plateforme',
    '1. Purpose of the platform',
    '1. هدف المنصة',
  );

  String get termsS1Body => _t(
    'La plateforme permet aux clients de publier des besoins, rechercher des professionnels du BTP, demander des devis et entrer en contact avec des artisans, entreprises ou prestataires spécialisés. Les professionnels peuvent présenter leurs services, répondre aux demandes et proposer des offres.',
    'The platform allows clients to publish their needs, search for construction professionals, request quotes, and contact artisans, companies, or specialized service providers. Professionals may present their services, respond to requests, and submit offers.',
    'تسمح المنصة للعملاء بنشر احتياجاتهم، والبحث عن مهنيي البناء، وطلب عروض أسعار، والتواصل مع الحرفيين أو الشركات أو مقدمي الخدمات المتخصصين. ويمكن للمهنيين عرض خدماتهم والرد على الطلبات وتقديم عروض.',
  );

  String get termsS2Title => _t(
    '2. Comptes utilisateurs',
    '2. User accounts',
    '2. حسابات المستخدمين',
  );

  String get termsS2B1 => _t(
    'Certaines fonctionnalités nécessitent la création d’un compte utilisateur.',
    'Certain features require creating a user account.',
    'تتطلب بعض الميزات إنشاء حساب مستخدم.',
  );

  String get termsS2B2 => _t(
    'Vous vous engagez à fournir des informations exactes, complètes et à jour.',
    'You agree to provide accurate, complete, and up-to-date information.',
    'تتعهد بتقديم معلومات صحيحة وكاملة ومحدثة.',
  );

  String get termsS2B3 => _t(
    'Vous êtes responsable de la confidentialité de vos identifiants et des activités réalisées via votre compte.',
    'You are responsible for the confidentiality of your credentials and all activities carried out through your account.',
    'أنت مسؤول عن سرية بيانات الدخول الخاصة بك وعن جميع الأنشطة التي تتم عبر حسابك.',
  );

  String get termsS2B4 => _t(
    'Les comptes professionnels sont réservés aux artisans, entreprises et prestataires du secteur BTP.',
    'Professional accounts are reserved for artisans, companies, and providers in the construction sector.',
    'الحسابات المهنية مخصصة للحرفيين والشركات ومقدمي الخدمات في قطاع البناء والأشغال.',
  );

  String get termsS3Title => _t(
    '3. Publication des demandes et des offres',
    '3. Requests and offers publication',
    '3. نشر الطلبات والعروض',
  );

  String get termsS3B1 => _t(
    'Les clients doivent décrire leurs besoins de manière claire, sincère et non trompeuse.',
    'Clients must describe their needs clearly, honestly, and without misleading information.',
    'يجب على العملاء وصف احتياجاتهم بوضوح وصدق ودون معلومات مضللة.',
  );

  String get termsS3B2 => _t(
    'Les professionnels doivent présenter leurs services, compétences, disponibilités et tarifs de manière loyale.',
    'Professionals must present their services, skills, availability, and pricing fairly.',
    'يجب على المهنيين عرض خدماتهم ومهاراتهم وتوفرهم وأسعارهم بشكل عادل وواضح.',
  );

  String get termsS3B3 => _t(
    'Il est interdit de publier de fausses annonces, de fausses références, ou tout contenu trompeur, abusif ou frauduleux.',
    'It is forbidden to publish false listings, false references, or any misleading, abusive, or fraudulent content.',
    'يُمنع نشر إعلانات أو مراجع مزيفة أو أي محتوى مضلل أو تعسفي أو احتيالي.',
  );

  String get termsS4Title => _t(
    '4. Mise en relation et devis',
    '4. Matching and quotes',
    '4. الربط وعروض الأسعار',
  );

  String get termsS4Body => _t(
    'La plateforme facilite uniquement la mise en relation entre clients et professionnels. Les devis, prestations, délais, prix et conditions d’exécution sont définis directement entre les parties concernées.',
    'The platform only facilitates connections between clients and professionals. Quotes, services, deadlines, prices, and execution terms are defined directly between the parties involved.',
    'تسهل المنصة فقط الربط بين العملاء والمهنيين. أما عروض الأسعار والخدمات والآجال والأسعار وشروط التنفيذ فتُحدد مباشرة بين الأطراف المعنية.',
  );

  String get termsS5Title => _t(
    '5. Comportements interdits',
    '5. Prohibited conduct',
    '5. السلوكيات المحظورة',
  );

  String get termsS5B1 => _t(
    'Créer de faux comptes ou usurper l’identité d’un tiers.',
    'Creating fake accounts or impersonating a third party.',
    'إنشاء حسابات وهمية أو انتحال هوية الغير.',
  );

  String get termsS5B2 => _t(
    'Publier de faux avis, de faux devis ou de fausses informations professionnelles.',
    'Publishing fake reviews, fake quotes, or false professional information.',
    'نشر تقييمات مزيفة أو عروض أسعار مزيفة أو معلومات مهنية غير صحيحة.',
  );

  String get termsS5B3 => _t(
    'Utiliser la plateforme à des fins illégales, abusives, diffamatoires ou frauduleuses.',
    'Using the platform for illegal, abusive, defamatory, or fraudulent purposes.',
    'استخدام المنصة لأغراض غير قانونية أو تعسفية أو تشهيرية أو احتيالية.',
  );

  String get termsS5B4 => _t(
    'Contourner les mesures de sécurité ou perturber le fonctionnement normal de l’application.',
    'Bypassing security measures or disrupting the normal operation of the application.',
    'تجاوز إجراءات الأمان أو تعطيل التشغيل العادي للتطبيق.',
  );

  String get termsS6Title => _t(
    '6. Responsabilité des utilisateurs',
    '6. User responsibility',
    '6. مسؤولية المستخدمين',
  );

  String get termsS6Body => _t(
    'Chaque utilisateur est seul responsable des informations qu’il publie, des échanges qu’il engage et des engagements qu’il prend avec les autres utilisateurs de la plateforme.',
    'Each user is solely responsible for the information they publish, the communications they initiate, and the commitments they make with other users of the platform.',
    'كل مستخدم مسؤول وحده عن المعلومات التي ينشرها، وعن المحادثات التي يجريها، وعن الالتزامات التي يبرمها مع مستخدمي المنصة الآخرين.',
  );

  String get termsS7Title => _t(
    '7. Limitation du rôle de la plateforme',
    '7. Limitation of the platform’s role',
    '7. حدود دور المنصة',
  );

  String get termsS7Body => _t(
    'La plateforme agit comme intermédiaire technique de mise en relation. Elle n’est pas partie aux contrats conclus entre clients et professionnels et ne garantit ni la qualité, ni l’exécution, ni le résultat des prestations convenues.',
    'The platform acts as a technical intermediary for connecting users. It is not a party to contracts concluded between clients and professionals and does not guarantee the quality, execution, or results of agreed services.',
    'تعمل المنصة كوسيط تقني للربط بين المستخدمين. وهي ليست طرفًا في العقود المبرمة بين العملاء والمهنيين، ولا تضمن جودة الخدمات أو تنفيذها أو نتائجها.',
  );

  String get termsS8Title => _t(
    '8. Disponibilité du service',
    '8. Service availability',
    '8. توفر الخدمة',
  );

  String get termsS8Body => _t(
    'Nous nous efforçons d’assurer l’accessibilité de la plateforme, sans garantie de disponibilité continue. Des interruptions temporaires peuvent survenir pour maintenance, mise à jour ou incident technique.',
    'We strive to ensure access to the platform, without guaranteeing continuous availability. Temporary interruptions may occur for maintenance, updates, or technical incidents.',
    'نسعى لضمان إمكانية الوصول إلى المنصة دون ضمان التوفر المستمر. وقد تحدث انقطاعات مؤقتة بسبب الصيانة أو التحديثات أو الأعطال التقنية.',
  );

  String get termsS9Title => _t(
    '9. Suspension ou suppression de compte',
    '9. Account suspension or deletion',
    '9. تعليق أو حذف الحساب',
  );

  String get termsS9Body => _t(
    'Nous pouvons suspendre ou supprimer tout compte en cas de non-respect des présentes Conditions, de comportement frauduleux ou de signalements sérieux et répétés.',
    'We may suspend or delete any account in case of violation of these Terms, fraudulent behavior, or serious and repeated reports.',
    'يجوز لنا تعليق أو حذف أي حساب في حال مخالفة هذه الشروط أو وجود سلوك احتيالي أو بلاغات جدية ومتكررة.',
  );

  String get termsS10Title => _t(
    '10. Données personnelles',
    '10. Personal data',
    '10. البيانات الشخصية',
  );

  String get termsS10Body => _t(
    'Les données personnelles sont collectées et traitées conformément à notre Politique de confidentialité. En utilisant la plateforme, vous acceptez ce traitement dans les limites prévues par cette politique.',
    'Personal data is collected and processed in accordance with our Privacy Policy. By using the platform, you accept such processing within the limits set by that policy.',
    'تُجمع البيانات الشخصية وتُعالج وفقًا لسياسة الخصوصية الخاصة بنا. وباستخدامك للمنصة فإنك توافق على هذه المعالجة ضمن الحدود المنصوص عليها في تلك السياسة.',
  );

  String get termsContactEmail => _t(
    'Email : contact@votreplateforme.com',
    'Email: contact@yourplatform.com',
    'البريد الإلكتروني: contact@yourplatform.com',
  );

  String get termsContactSupport => _t(
    'Page support : https://votreplateforme.com/support',
    'Support page: https://yourplatform.com/support',
    'صفحة الدعم: https://yourplatform.com/support',
  );

  String get termsS11Title => _t(
    '11. Obligations des professionnels',
    '11. Professionals obligations',
    '11. التزامات المهنيين',
  );

  String get termsS11Body => _t(
    'Les professionnels s’engagent à intervenir dans le respect des lois applicables, à disposer des compétences nécessaires à leurs prestations, et à fournir des informations sincères sur leur activité, leur disponibilité et leurs qualifications.',
    'Professionals undertake to operate in compliance with applicable laws, to have the necessary skills for their services, and to provide truthful information regarding their activity, availability, and qualifications.',
    'يلتزم المهنيون بالعمل وفق القوانين المعمول بها، وبامتلاك المهارات اللازمة لخدماتهم، وبتقديم معلومات صادقة عن نشاطهم وتوفرهم ومؤهلاتهم.',
  );

  String get termsS12Title => _t(
    '12. Obligations des clients',
    '12. Clients obligations',
    '12. التزامات العملاء',
  );

  String get termsS12Body => _t(
    'Les clients s’engagent à formuler des demandes réelles, sérieuses et respectueuses, à communiquer des informations utiles à la bonne compréhension du besoin, et à ne pas détourner la plateforme à des fins abusives.',
    'Clients undertake to submit genuine, serious, and respectful requests, to provide useful information for understanding their needs, and not to misuse the platform for abusive purposes.',
    'يلتزم العملاء بتقديم طلبات حقيقية وجدية ومحترمة، وبإعطاء معلومات مفيدة لفهم الحاجة، وعدم إساءة استخدام المنصة لأغراض تعسفية.',
  );

  String get termsS13Title => _t(
    '13. Propriété intellectuelle',
    '13. Intellectual property',
    '13. الملكية الفكرية',
  );

  String get termsS13Body => _t(
    'Les contenus, éléments graphiques, textes, logos, marques et fonctionnalités de la plateforme sont protégés. Toute reproduction, diffusion ou utilisation non autorisée est interdite.',
    'The platform’s content, graphic elements, texts, logos, trademarks, and features are protected. Any unauthorized reproduction, distribution, or use is prohibited.',
    'محتويات المنصة وعناصرها الرسومية ونصوصها وشعاراتها وعلاماتها وميزاتها محمية. ويُمنع أي نسخ أو نشر أو استخدام غير مصرح به.',
  );

  String get termsS14Title => _t(
    '14. Droit applicable et contact',
    '14. Governing law and contact',
    '14. القانون المطبق والتواصل',
  );

  String get termsS14Body => _t(
    'Les présentes Conditions sont soumises au droit applicable dans le pays d’exploitation de la plateforme. Pour toute question relative à leur interprétation ou à leur application, vous pouvez contacter le support.',
    'These Terms are governed by the law applicable in the country where the platform operates. For any question regarding their interpretation or application, you may contact support.',
    'تخضع هذه الشروط للقانون المعمول به في بلد تشغيل المنصة. ولأي سؤال يتعلق بتفسيرها أو تطبيقها، يمكنكم التواصل مع الدعم.',
  );

  String get supportTitle => _t(
    'Support',
    'Support',
    'الدعم',
  );

  String get supportSubtitle => _t(
    'Contactez notre équipe pour toute question liée à la mise en relation, aux demandes de devis ou à l’utilisation de la plateforme.',
    'Contact our team for any question related to matchmaking, quote requests, or use of the platform.',
    'تواصل مع فريقنا لأي سؤال يتعلق بالربط بين الأطراف أو طلبات عروض الأسعار أو استخدام المنصة.',
  );

  String get supportInfoTitle => _t(
    'Contact support',
    'Support contact',
    'الاتصال بالدعم',
  );

  String get supportSendEmail => _t(
    'Envoyer un email',
    'Send an email',
    'إرسال بريد إلكتروني',
  );

  String get supportMailSubject => _t(
    'Support plateforme BTP',
    'BTP platform support',
    'دعم منصة خدمات البناء',
  );

  String get supportSnackEmailReady => _t(
    'Votre email est prêt à être envoyé.',
    'Your email is ready to be sent.',
    'رسالتك جاهزة للإرسال.',
  );

  String get supportOpenFail => _t(
    "Impossible d'ouvrir {url}",
    'Unable to open {url}',
    'تعذر فتح {url}',
  );

  String get supportNameLabel => _t(
    'Nom',
    'Name',
    'الاسم',
  );

  String get supportNameHint => _t(
    'Votre nom complet',
    'Your full name',
    'اسمك الكامل',
  );

  String get supportNameRequired => _t(
    'Le nom est requis',
    'Name is required',
    'الاسم مطلوب',
  );

  String get supportEmailLabel => _t(
    'Email',
    'Email',
    'البريد الإلكتروني',
  );

  String get supportEmailHint => _t(
    'ex: client@plateforme.com',
    'e.g. client@platform.com',
    'مثال: client@platform.com',
  );

  String get supportEmailRequired => _t(
    'Email requis',
    'Email required',
    'البريد الإلكتروني مطلوب',
  );

  String get supportEmailInvalid => _t(
    'Email invalide',
    'Invalid email',
    'بريد إلكتروني غير صالح',
  );

  String get supportMessageLabel => _t(
    'Message',
    'Message',
    'الرسالة',
  );

  String get supportMessageHint => _t(
    'Expliquez votre besoin, votre problème ou votre demande de support…',
    'Describe your need, issue, or support request…',
    'اشرح حاجتك أو مشكلتك أو طلب الدعم الخاص بك…',
  );

  String get supportMessageRequired => _t(
    'Message requis',
    'Message is required',
    'الرسالة مطلوبة',
  );

  String get supportPrepareEmail => _t(
    'Préparer l’email',
    'Prepare email',
    'تحضير البريد',
  );

  String get supportChipWebsite => _t(
    'Site web',
    'Website',
    'الموقع الإلكتروني',
  );

  String get supportChipTerms => _t(
    'Conditions d’utilisation',
    'Terms of use',
    'شروط الاستخدام',
  );

  String get supportChipPrivacy => _t(
    'Confidentialité',
    'Privacy',
    'الخصوصية',
  );
  String get privacyTitle => _t(
    'Politique de confidentialité',
    'Privacy Policy',
    'سياسة الخصوصية',
  );

  String get privacyLastUpdate => _t(
    'Dernière mise à jour : 13/03/2026',
    'Last update: 13/03/2026',
    'آخر تحديث: 13/03/2026',
  );

  String get privacyIntro => _t(
    'La présente Politique de confidentialité explique comment la plateforme collecte, utilise, protège et conserve les données personnelles des clients et des professionnels du BTP utilisant le service.',
    'This Privacy Policy explains how the platform collects, uses, protects, and retains the personal data of clients and construction professionals using the service.',
    'توضح سياسة الخصوصية هذه كيفية جمع المنصة للبيانات الشخصية الخاصة بالعملاء والمهنيين في قطاع البناء واستخدامها وحمايتها والاحتفاظ بها.',
  );

// 1
  String get privacySection1Title => _t(
    '1. Données collectées',
    '1. Collected data',
    '1. البيانات التي يتم جمعها',
  );

  String get privacySection1Bullet1 => _t(
    'Données d’identification : nom, prénom, email, numéro de téléphone.',
    'Identification data: name, email, phone number.',
    'بيانات التعريف: الاسم، البريد الإلكتروني، رقم الهاتف.',
  );

  String get privacySection1Bullet2 => _t(
    'Données de compte professionnel : activité, spécialité, zone d’intervention, informations d’entreprise.',
    'Professional account data: activity, specialty, service area, company information.',
    'بيانات الحساب المهني: النشاط، التخصص، منطقة التدخل، معلومات الشركة.',
  );

  String get privacySection1Bullet3 => _t(
    'Données liées aux demandes, devis, échanges et mises en relation entre clients et professionnels.',
    'Data related to requests, quotes, communications, and matchmaking between clients and professionals.',
    'البيانات المتعلقة بالطلبات وعروض الأسعار والمحادثات وعمليات الربط بين العملاء والمهنيين.',
  );

  String get privacySection1Bullet4 => _t(
    'Données techniques : appareil, système, adresse IP, journaux techniques et informations de sécurité.',
    'Technical data: device, system, IP address, technical logs, and security-related information.',
    'البيانات التقنية: الجهاز، النظام، عنوان IP، السجلات التقنية، ومعلومات الأمان.',
  );

// 2
  String get privacySection2Title => _t(
    '2. Utilisation des données',
    '2. Use of data',
    '2. استخدام البيانات',
  );

  String get privacySection2Bullet1 => _t(
    'Permettre la mise en relation entre clients et professionnels.',
    'Enable connections between clients and professionals.',
    'تمكين الربط بين العملاء والمهنيين.',
  );

  String get privacySection2Bullet2 => _t(
    'Gérer les comptes, les demandes de prestations, les devis et les échanges.',
    'Manage accounts, service requests, quotes, and communications.',
    'إدارة الحسابات وطلبات الخدمات وعروض الأسعار والمحادثات.',
  );

  String get privacySection2Bullet3 => _t(
    'Améliorer la qualité du service, la pertinence des mises en relation et l’expérience utilisateur.',
    'Improve service quality, matching relevance, and user experience.',
    'تحسين جودة الخدمة وفعالية الربط وتجربة المستخدم.',
  );

  String get privacySection2Bullet4 => _t(
    'Assurer la sécurité, prévenir la fraude et respecter les obligations légales.',
    'Ensure security, prevent fraud, and comply with legal obligations.',
    'ضمان الأمان ومنع الاحتيال والامتثال للالتزامات القانونية.',
  );

// 3
  String get privacySection3Title => _t(
    '3. Partage des données',
    '3. Data sharing',
    '3. مشاركة البيانات',
  );

  String get privacySection3Intro => _t(
    'Les données personnelles ne sont pas vendues. Elles peuvent être partagées uniquement lorsque cela est nécessaire au fonctionnement du service, notamment avec :',
    'Personal data is not sold. It may only be shared when necessary for operating the service, including with:',
    'لا يتم بيع البيانات الشخصية. وقد تتم مشاركتها فقط عند الضرورة لتشغيل الخدمة، وخاصة مع:',
  );

  String get privacySection3Bullet1 => _t(
    'Les utilisateurs impliqués dans une mise en relation, dans la limite nécessaire à l’échange et au traitement de la demande.',
    'Users involved in a match, only to the extent necessary for communication and handling the request.',
    'المستخدمين المعنيين بعملية الربط، في حدود ما يلزم للتواصل ومعالجة الطلب.',
  );

  String get privacySection3Bullet2 => _t(
    'Les prestataires techniques participant à l’hébergement, la maintenance, la sécurité ou l’envoi de communications.',
    'Technical service providers involved in hosting, maintenance, security, or communications.',
    'مقدمي الخدمات التقنية المشاركين في الاستضافة أو الصيانة أو الأمان أو إرسال المراسلات.',
  );

  String get privacySection3Bullet3 => _t(
    'Les autorités compétentes lorsque la loi l’exige ou en cas de demande légitime.',
    'Competent authorities when required by law or in case of a legitimate request.',
    'الجهات المختصة عندما يفرض القانون ذلك أو عند وجود طلب مشروع.',
  );

// 4
  String get privacySection4Title => _t(
    '4. Sécurité',
    '4. Security',
    '4. الأمان',
  );

  String get privacySection4Body => _t(
    'La plateforme met en œuvre des mesures techniques et organisationnelles raisonnables pour protéger les données personnelles contre l’accès non autorisé, la perte, l’altération ou la divulgation abusive.',
    'The platform implements reasonable technical and organizational measures to protect personal data against unauthorized access, loss, alteration, or improper disclosure.',
    'تعتمد المنصة تدابير تقنية وتنظيمية معقولة لحماية البيانات الشخصية من الوصول غير المصرح به أو الفقدان أو التعديل أو الإفصاح غير المشروع.',
  );

// 5
  String get privacySection5Title => _t(
    '5. Durée de conservation',
    '5. Data retention',
    '5. مدة الاحتفاظ بالبيانات',
  );

  String get privacySection5Body => _t(
    'Les données sont conservées uniquement pendant la durée nécessaire à la fourniture du service, à la gestion de la relation entre utilisateurs et au respect des obligations légales et réglementaires.',
    'Data is retained only for as long as necessary to provide the service, manage user relationships, and comply with legal and regulatory obligations.',
    'يتم الاحتفاظ بالبيانات فقط للمدة اللازمة لتقديم الخدمة وإدارة العلاقة بين المستخدمين والامتثال للالتزامات القانونية والتنظيمية.',
  );

// 6
  String get privacySection6Title => _t(
    '6. Droits des utilisateurs',
    '6. User rights',
    '6. حقوق المستخدمين',
  );

  String get privacySection6Bullet1 => _t(
    'Accéder à leurs données personnelles.',
    'Access their personal data.',
    'الوصول إلى بياناتهم الشخصية.',
  );

  String get privacySection6Bullet2 => _t(
    'Demander la correction, la mise à jour ou la suppression de leurs données, dans les limites prévues par la loi.',
    'Request correction, updating, or deletion of their data, within legal limits.',
    'طلب تصحيح أو تحديث أو حذف بياناتهم ضمن الحدود التي يسمح بها القانون.',
  );

  String get privacySection6Bullet3 => _t(
    'S’opposer à certains traitements ou en demander la limitation lorsque cela est applicable.',
    'Object to certain processing activities or request their restriction when applicable.',
    'الاعتراض على بعض عمليات المعالجة أو طلب تقييدها عندما يكون ذلك ممكنًا.',
  );

// 7
  String get privacySection7Title => _t(
    '7. Cookies et technologies similaires',
    '7. Cookies and similar technologies',
    '7. ملفات تعريف الارتباط والتقنيات المشابهة',
  );

  String get privacySection7Body => _t(
    'La plateforme peut utiliser des cookies ou technologies similaires afin d’améliorer l’expérience utilisateur, mémoriser certaines préférences, mesurer l’usage du service et renforcer la sécurité.',
    'The platform may use cookies or similar technologies to improve user experience, remember preferences, measure service usage, and strengthen security.',
    'قد تستخدم المنصة ملفات تعريف الارتباط أو تقنيات مشابهة لتحسين تجربة المستخدم وحفظ بعض التفضيلات وقياس استخدام الخدمة وتعزيز الأمان.',
  );

// 8
  String get privacySection8Title => _t(
    '8. Modifications de la politique',
    '8. Changes to the policy',
    '8. تعديل السياسة',
  );

  String get privacySection8Body => _t(
    'Cette Politique de confidentialité peut être mise à jour à tout moment. En cas de modification importante, les utilisateurs seront informés par les moyens jugés appropriés.',
    'This Privacy Policy may be updated at any time. In case of significant changes, users will be informed through appropriate means.',
    'قد يتم تحديث سياسة الخصوصية هذه في أي وقت. وفي حال حدوث تغييرات جوهرية، سيتم إبلاغ المستخدمين بالوسائل المناسبة.',
  );

// 9
  String get privacySection9Title => _t(
    '9. Contact',
    '9. Contact',
    '9. التواصل',
  );

  String get privacySection9Body => _t(
    'Pour toute question relative à la protection des données ou à l’exercice de vos droits, vous pouvez contacter le support.',
    'For any question related to data protection or the exercise of your rights, you may contact support.',
    'لأي سؤال يتعلق بحماية البيانات أو بممارسة حقوقك، يمكنك التواصل مع الدعم.',
  );

// 10
  String get privacySection10Title => _t(
    '10. Données de profil professionnel',
    '10. Professional profile data',
    '10. بيانات الملف المهني',
  );

  String get privacySection10Body => _t(
    'Les informations renseignées par les professionnels, telles que la spécialité, la description des services, la zone d’intervention et les coordonnées visibles, peuvent être affichées aux clients afin de faciliter la mise en relation.',
    'Information provided by professionals, such as specialty, service description, service area, and visible contact details, may be shown to clients to facilitate matchmaking.',
    'قد يتم عرض المعلومات التي يقدمها المهنيون، مثل التخصص ووصف الخدمات ومنطقة التدخل ووسائل الاتصال الظاهرة، للعملاء بهدف تسهيل عملية الربط.',
  );

// 11
  String get privacySection11Title => _t(
    '11. Communications entre utilisateurs',
    '11. User communications',
    '11. التواصل بين المستخدمين',
  );

  String get privacySection11Body => _t(
    'Les messages, demandes et réponses échangés via la plateforme peuvent être traités afin d’assurer le bon fonctionnement du service, d’améliorer l’assistance et de prévenir les abus.',
    'Messages, requests, and replies exchanged through the platform may be processed to ensure proper service operation, improve support, and prevent abuse.',
    'قد تتم معالجة الرسائل والطلبات والردود المتبادلة عبر المنصة لضمان حسن تشغيل الخدمة وتحسين الدعم ومنع الإساءة.',
  );

// 12
  String get privacySection12Title => _t(
    '12. Prévention de la fraude',
    '12. Fraud prevention',
    '12. منع الاحتيال',
  );

  String get privacySection12Body => _t(
    'Certaines données peuvent être utilisées pour détecter les comportements suspects, protéger les utilisateurs, limiter les faux comptes et préserver la fiabilité de la plateforme.',
    'Certain data may be used to detect suspicious behavior, protect users, limit fake accounts, and preserve platform reliability.',
    'قد تُستخدم بعض البيانات لاكتشاف السلوكيات المشبوهة وحماية المستخدمين والحد من الحسابات المزيفة والحفاظ على موثوقية المنصة.',
  );

// 13
  String get privacySection13Title => _t(
    '13. Hébergement et transfert des données',
    '13. Data hosting and transfer',
    '13. استضافة البيانات ونقلها',
  );

  String get privacySection13Body => _t(
    'Les données peuvent être hébergées ou traitées par des prestataires techniques situés dans d’autres pays, sous réserve de garanties appropriées en matière de sécurité et de confidentialité.',
    'Data may be hosted or processed by technical providers located in other countries, subject to appropriate security and confidentiality safeguards.',
    'قد تتم استضافة البيانات أو معالجتها لدى مزودي خدمات تقنية موجودين في بلدان أخرى، مع مراعاة الضمانات المناسبة المتعلقة بالأمان والسرية.',
  );

// 14
  String get privacySection14Title => _t(
    '14. Utilisation par les mineurs',
    '14. Use by minors',
    '14. استخدام القاصرين',
  );

  String get privacySection14Body => _t(
    'La plateforme est destinée à un public capable de contracter ou de demander des prestations. Si un mineur utilise le service, cela doit se faire sous la responsabilité d’un parent ou représentant légal, conformément au droit applicable.',
    'The platform is intended for users capable of entering into agreements or requesting services. If a minor uses the service, this must be done under the responsibility of a parent or legal representative, in accordance with applicable law.',
    'المنصة مخصصة للمستخدمين القادرين على التعاقد أو طلب الخدمات. وإذا استخدمها قاصر، فيجب أن يكون ذلك تحت مسؤولية أحد الوالدين أو الممثل القانوني، وفقًا للقانون المعمول به.',
  );

// Contact
  String get privacyContactEmail => _t(
    'Email : contact@votreplateforme.com',
    'Email: contact@yourplatform.com',
    'البريد الإلكتروني: contact@yourplatform.com',
  );

  String get privacyContactSupport => _t(
    'Page support : https://votreplateforme.com/support',
    'Support page: https://yourplatform.com/support',
    'صفحة الدعم: https://yourplatform.com/support',
  );

// Navigation chips used in this view
  String get terms => _t(
    'Conditions',
    'Terms',
    'الشروط',
  );

  String get support => _t(
    'Support',
    'Support',
    'الدعم',
  );

  String get profile => _t(
    'Profil',
    'Profile',
    'الملف الشخصي',
  );

  String get menu => _t(
    'Menu',
    'Menu',
    'القائمة',
  );

  String get dashboard => _t(
    'Tableau de bord',
    'Dashboard',
    'لوحة التحكم',
  );

  String get menuHome => _t(
    'Accueil',
    'Home',
    'الرئيسية',
  );

  String get menuMyAds => _t(
    'Mes annonces',
    'My listings',
    'إعلاناتي',
  );


  String get confirmSignOut => _t(
    'Voulez-vous vraiment vous déconnecter ?',
    'Do you really want to sign out?',
    'هل تريد حقًا تسجيل الخروج؟',
  );

}
