import 'package:flutter/foundation.dart';

import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Shared/AuthModels.dart';
import '../Shared/validators.dart';
import 'PasswordService.dart';

class PasswordManager {
  final Manager manager;
  final PasswordService _service;

  PasswordManager(this.manager, HelperService helper)
      : _service = PasswordService(manager, helper);

  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> success = ValueNotifier<bool>(false);
  final ValueNotifier<bool> obscure = ValueNotifier<bool>(true);
  final ValueNotifier<String?> inlineError = ValueNotifier<String?>(null);

  String _email = '';
  String _token = '';

  String get email => _email;
  String get token => _token;

  void startFlow({
    required String email,
    required String token,
  }) {
    _email = email.trim().toLowerCase();
    _token = token.trim();

    loading.value = false;
    success.value = false;
    obscure.value = true;
    inlineError.value = null;
  }

  void clearError() {
    inlineError.value = null;
  }

  void toggleObscure() {
    obscure.value = !obscure.value;
  }

  String? validatePassword(String? value) {
    final s = manager.winyCarTranslation;
    return passwordValidator(
      manager,
      value,
      min: 8,
      msgRequired: s.passwordRequired,
    );
  }

  String? validateConfirmPassword(String? value, String passwordValue) {
    final s = manager.winyCarTranslation;
    final base = validatePassword(value);
    if (base != null) return base;

    if ((value ?? '').trim() != passwordValue.trim()) {
      return s.passwordsDontMatch;
    }
    return null;
  }

  Future<BaseResponse<StatusData>> changePassword({
    required String email,
    required String token,
    required String newPassword,
  }) {
    return _service.changePasswordWithToken(
      email: email.trim().toLowerCase(),
      token: token.trim(),
      newPassword: newPassword.trim(),
    );
  }

  Future<BaseResponse<StatusData>> submit({
    required String newPassword,
  }) async {
    final s = manager.winyCarTranslation;

    loading.value = true;
    success.value = false;
    inlineError.value = null;

    try {
      final res = await changePassword(
        email: _email,
        token: _token,
        newPassword: newPassword,
      );

      if (res.success) {
        success.value = true;
        inlineError.value = null;
      } else {
        final msg = manager.readableMessage(res);
        inlineError.value = msg.isNotEmpty ? msg : s.cannotChangePassword;
      }

      return res;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      final readable = msg.isEmpty ? s.cannotChangePassword : msg;

      inlineError.value = readable;
      success.value = false;

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

  void dispose() {
    loading.dispose();
    success.dispose();
    obscure.dispose();
    inlineError.dispose();
  }
}