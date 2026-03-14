// lib/Auth/Logout/LogoutManager.dart
import 'dart:async';

import '../App/HelperService.dart';
import '../App/Manager.dart';
import 'LogoutService.dart';

class LogoutManager {
  final Manager manager;
  final LogoutService _service;
  LogoutManager(this.manager, HelperService helper)
    : _service = LogoutService(manager, helper);

  Future<void> logout() async {
    String? refresh;
    try {
      refresh = await manager.helperService.getRefreshToken();
    } catch (_) {
      refresh = null;
    }

    String? fcmToken;
    try {
      fcmToken = await manager.fcmService.getLocalToken();
    } catch (_) {
      fcmToken = null;
    }

    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _service.logoutWithRefresh(
          refreshToken: refresh,
          fcmToken: fcmToken,
        );
      } catch (_) {}
    }

    try {
      await manager.helperService.clearTokens();
    } catch (_) {}

    manager.tokens = null;
    manager.currentUser = null;
    manager.lastAccountStatus = null;
    manager.attemptsMax = null;

    manager.dio.options.headers.remove('Authorization');

    unawaited(() async {
      try {
        await manager.fcmService.clearLocalToken();
      } catch (_) {}
    }());
  }
}
