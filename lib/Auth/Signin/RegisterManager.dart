// lib/Auth/Signup/RegisterManager.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Shared/AuthModels.dart';
import 'RegisterService.dart';

enum SignupStep { info, otp }

class RegisterManager {
  final Manager manager;
  final RegisterService _service;

  RegisterManager(this.manager, HelperService helper)
      : _service = RegisterService(helper);

  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<String?> inlineError = ValueNotifier<String?>(null);
  final ValueNotifier<SignupStep> step =
  ValueNotifier<SignupStep>(SignupStep.info);
  final ValueNotifier<int> cooldownLeft = ValueNotifier<int>(0);

  BaseResponse<StatusData>? lastRegister;
  BaseResponse<LoginData>? lastVerifyRegisterOtp;
  BaseResponse<StatusData>? lastResendRegisterOtp;
  String? lastAccountStatus;

  Timer? _cooldownTimer;

  static const Duration otpCooldown = Duration(seconds: 120);

  void startFlow() {
    loading.value = false;
    obscurePassword.value = true;
    inlineError.value = null;
    step.value = SignupStep.info;
    lastRegister = null;
    lastVerifyRegisterOtp = null;
    lastResendRegisterOtp = null;
    lastAccountStatus = null;
    stopCooldown();
  }

  void clearError() {
    inlineError.value = null;
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void goToOtpStep() {
    step.value = SignupStep.otp;
  }

  void goToInfoStep() {
    step.value = SignupStep.info;
  }

  void startCooldown() {
    _cooldownTimer?.cancel();
    cooldownLeft.value = otpCooldown.inSeconds;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = cooldownLeft.value - 1;
      if (next <= 0) {
        cooldownLeft.value = 0;
        t.cancel();
      } else {
        cooldownLeft.value = next;
      }
    });
  }

  void stopCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    cooldownLeft.value = 0;
  }

  Future<BaseResponse<StatusData>> register(RegisterRequest req) async {
    final res = await _service.register(req);
    lastRegister = res;
    lastAccountStatus = res.data?.status;
    return res;
  }

  Future<BaseResponse<LoginData>> verifyRegisterOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    final res = await _service.verifyRegisterOtp(
      VerifyRegisterOtpRequest(
        email: email.trim().toLowerCase(),
        otp: otp.trim(),
        password: password,
      ),
    );

    lastVerifyRegisterOtp = res;

    if (res.success && res.data != null) {
      final login = res.data!;

      await manager.helperService.saveTokens(login.tokens);
      manager.tokens = login.tokens;
      manager.currentUser = login.user;
      manager.currentSubscription = login.subscription;
      lastAccountStatus = 'active';

      unawaited(() async {
        try {
          final fcm = manager.fcmService;
          await fcm.init();
          await fcm.registerToken();
        } catch (_) {}
      }());
    }

    return res;
  }

  Future<BaseResponse<StatusData>> resendRegisterOtp(String email) async {
    final res = await _service.resendRegisterOtp(email.trim().toLowerCase());
    lastResendRegisterOtp = res;
    lastAccountStatus = res.data?.status;
    return res;
  }

  Future<BaseResponse<StatusData>> submitRegister(RegisterRequest req) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    inlineError.value = null;

    try {
      final resp = await register(req);

      if (resp.success) {
        inlineError.value = null;
        goToOtpStep();
        startCooldown();
      } else {
        final msg = manager.readableMessage(resp);
        inlineError.value = msg.isNotEmpty ? msg : s.signupFailed;
      }

      return resp;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.signupFailed : msg;
      inlineError.value = readable;

      return BaseResponse<StatusData>(
        success: false,
        message: readable,
        code: 2,
        data: null,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<BaseResponse<LoginData>> submitVerifyOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    inlineError.value = null;

    try {
      final resp = await verifyRegisterOtp(
        email: email,
        otp: otp,
        password: password,
      );

      if (resp.success) {
        inlineError.value = null;
      } else {
        final msg = manager.readableMessage(resp);
        inlineError.value = msg.isNotEmpty ? msg : s.otpValidationFailed;
      }

      return resp;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.otpValidationFailed : msg;
      inlineError.value = readable;

      return BaseResponse<LoginData>(
        success: false,
        message: readable,
        code: 2,
        data: null,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<BaseResponse<StatusData>> submitResendOtp(String email) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    inlineError.value = null;

    try {
      final resp = await resendRegisterOtp(email);

      if (resp.success) {
        inlineError.value = null;
        startCooldown();
      } else {
        final msg = manager.readableMessage(resp);
        inlineError.value = msg.isNotEmpty ? msg : s.cannotResendCode;
      }

      return resp;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.cannotResendCode : msg;
      inlineError.value = readable;

      return BaseResponse<StatusData>(
        success: false,
        message: readable,
        code: 2,
        data: null,
      );
    } finally {
      loading.value = false;
    }
  }

  void clear() {
    lastRegister = null;
    lastVerifyRegisterOtp = null;
    lastResendRegisterOtp = null;
    lastAccountStatus = null;
    inlineError.value = null;
  }

  void dispose() {
    _cooldownTimer?.cancel();
    loading.dispose();
    obscurePassword.dispose();
    inlineError.dispose();
    step.dispose();
    cooldownLeft.dispose();
  }
}