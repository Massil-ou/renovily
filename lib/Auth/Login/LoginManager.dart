import 'dart:async';
import 'package:flutter/foundation.dart';

import '../Shared/AuthModels.dart';
import 'LoginService.dart';
import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';

enum LoginStepState { form, otp }
enum ForgotStepState { form, sent }

class LoginManager {
  final Manager manager;
  final LoginService _service;

  LoginManager(this.manager, HelperService helper)
      : _service = LoginService(manager, helper);

  final ValueNotifier<LoginStepState> loginStep =
  ValueNotifier<LoginStepState>(LoginStepState.form);

  final ValueNotifier<bool> showForgot = ValueNotifier<bool>(false);

  final ValueNotifier<ForgotStepState> forgotStep =
  ValueNotifier<ForgotStepState>(ForgotStepState.form);

  final ValueNotifier<bool> obscure = ValueNotifier<bool>(true);
  final ValueNotifier<bool> rememberMe = ValueNotifier<bool>(false);
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> inlineError = ValueNotifier<String?>(null);

  String _email = '';
  String _password = '';
  String _forgotEmail = '';

  String get email => _email;
  String get password => _password;
  String get forgotEmail => _forgotEmail;

  String normalizedEmail(String raw) => raw.trim().toLowerCase();

  Future<void> initRemembered() async {
    final creds = await manager.getRememberedCredentials();

    rememberMe.value = creds.remember;
    if (creds.remember) {
      _email = creds.email;
      _password = creds.password;
    } else {
      _email = '';
      _password = '';
    }
  }

  void setEmail(String value) {
    _email = value;
  }

  void setPassword(String value) {
    _password = value;
  }

  void setForgotEmail(String value) {
    _forgotEmail = value;
  }

  void setRememberMe(bool value) {
    rememberMe.value = value;
  }

  void setOtpStep() {
    loginStep.value = LoginStepState.otp;
  }

  void backToStep1() {
    loginStep.value = LoginStepState.form;
    inlineError.value = null;
  }

  void openForgot({String initialEmail = ''}) {
    showForgot.value = true;
    forgotStep.value = ForgotStepState.form;
    _forgotEmail = normalizedEmail(initialEmail);
    inlineError.value = null;
  }

  void backToLogin() {
    showForgot.value = false;
    forgotStep.value = ForgotStepState.form;
    inlineError.value = null;
  }

  void backToForgotForm() {
    forgotStep.value = ForgotStepState.form;
    inlineError.value = null;
  }

  void clearError() {
    inlineError.value = null;
  }

  void toggleObscure() {
    obscure.value = !obscure.value;
  }

  Future<BaseResponse<LoginStep1Data>> authLogin(
      String email,
      String password,
      ) async {
    final res = await _service.authLogin(
      LoginRequest(
        email: normalizedEmail(email),
        password: password,
      ),
    );

    manager.lastAccountStatus = res.data?.status;
    return res;
  }

  Future<BaseResponse<LoginData>> authLoginOtp(
      String email,
      String otp,
      String password,
      ) async {
    final res = await _service.authLoginOtp(
      LoginOtpRequest(
        email: normalizedEmail(email),
        otp: otp.trim(),
        password: password,
      ),
    );

    if (res.success && res.data != null) {
      manager.tokens = res.data!.tokens;
      manager.currentUser = res.data!.user;
      manager.currentSubscription = res.data!.subscription;

      await manager.helperService.saveTokens(res.data!.tokens);

      unawaited(() async {
        try {
          await manager.fcmService.registerToken();
        } catch (_) {}
      }());
    }

    return res;
  }

  Future<BaseResponse<StatusData>> sendPasswordResetLink(String email) {
    return _service.sendPasswordResetLink(normalizedEmail(email));
  }

  Future<BaseResponse<LoginStep1Data>> submitLoginStep1({
    required String email,
    required String password,
  }) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    inlineError.value = null;
    _email = normalizedEmail(email);
    _password = password;

    try {
      final res = await authLogin(_email, _password);

      if (res.success) {
        loginStep.value = LoginStepState.otp;
      } else {
        final msg = manager.readableMessage(res);
        inlineError.value = msg.isNotEmpty ? msg : s.invalidCredentials;
      }

      return res;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.loginError : msg;

      inlineError.value = readable;

      return BaseResponse<LoginStep1Data>(
        success: false,
        message: readable,
        code: -1,
        data: null,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<BaseResponse<LoginData>> submitLoginStep2({
    required String otp,
  }) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    inlineError.value = null;

    try {
      final res = await authLoginOtp(_email, otp.trim(), _password);

      if (res.success) {
        await manager.setRememberedCredentials(
          remember: rememberMe.value,
          email: _email,
          password: _password,
        );
      } else {
        final msg = manager.readableMessage(res);
        inlineError.value = msg.isNotEmpty ? msg : s.invalidOtp;
      }

      return res;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.otpValidationError : msg;

      inlineError.value = readable;

      return BaseResponse<LoginData>(
        success: false,
        message: readable,
        code: -1,
        data: null,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<BaseResponse<StatusData>> submitForgotByLink({
    required String email,
  }) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    inlineError.value = null;
    _forgotEmail = normalizedEmail(email);

    try {
      final res = await sendPasswordResetLink(_forgotEmail);

      if (res.success) {
        showForgot.value = true;
        forgotStep.value = ForgotStepState.sent;
      } else {
        final msg = manager.readableMessage(res);
        inlineError.value = msg.isNotEmpty ? msg : s.cannotSendLink;
      }

      return res;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.cannotSendLink : msg;

      inlineError.value = readable;

      return BaseResponse<StatusData>(
        success: false,
        message: readable,
        code: -1,
        data: null,
      );
    } finally {
      loading.value = false;
    }
  }

  void dispose() {
    loginStep.dispose();
    showForgot.dispose();
    forgotStep.dispose();
    obscure.dispose();
    rememberMe.dispose();
    loading.dispose();
    inlineError.dispose();
  }
}