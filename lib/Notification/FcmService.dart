import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../Auth/Shared/AuthModels.dart';
import '../App/HelperService.dart';
import '../App/Manager.dart';

class FcmService {
  final Manager manager;
  final HelperService helper;

  FcmService(this.manager, this.helper);

  bool _inited = false;
  StreamSubscription<String>? _tokenRefreshSub;

  static const _kFcmTokenKey = 'fcm_token';

  static const String _webVapidKey =
      'BC7zBIjeoIKUb6rBFXqJ7NYYlmnKcHNpMQrItvZVAFzb3M_ED1zFZVNbuFbE1IBMlJ54eDL1YF0w4wfCdCvqZwM';

  Future<void> _saveLocalToken(String token) async {
    try {
      await manager.storage.write(key: _kFcmTokenKey, value: token);
    } catch (_) {}
  }

  Future<String?> getLocalToken() async {
    try {
      return await manager.storage.read(key: _kFcmTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearLocalToken() async {
    try {
      await manager.storage.delete(key: _kFcmTokenKey);
    } catch (_) {}
  }

  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    try {
      await _requestPermissionBestEffort();
    } catch (_) {}

    try {
      await _tokenRefreshSub?.cancel();
    } catch (_) {}

    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      newToken,
    ) async {
      if (newToken.isEmpty) return;
      await _saveLocalToken(newToken);
      await registerToken(tokenOverride: newToken);
    }, onError: (_) {});
  }

  Future<void> _requestPermissionBestEffort() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _tokenRefreshSub?.cancel();
    } catch (_) {}
    _tokenRefreshSub = null;
    _inited = false;
  }

  Future<void> registerToken({String? tokenOverride}) async {
    if (!manager.isAuthenticated) return;

    String? token;
    try {
      if (tokenOverride != null && tokenOverride.isNotEmpty) {
        token = tokenOverride;
      } else {
        if (kIsWeb) {
          if (_webVapidKey.trim().isEmpty) return;
          token = await FirebaseMessaging.instance.getToken(
            vapidKey: _webVapidKey.trim(),
          );
        } else {
          token = await FirebaseMessaging.instance.getToken();
        }
      }
    } catch (_) {
      return;
    }

    if (token == null || token.isEmpty) return;

    final local = await getLocalToken();
    if (local == token) return;

    final email = manager.currentUserEmail;
    if (email.isEmpty) return;

    try {
      final res = await helper.postTyped<StatusData>(
        '/push/register_fcm',
        data: {'email': email, 'fcm_token': token},
        parse: (j) => StatusData.fromJson(j),
      );

      if (res.success) {
        await _saveLocalToken(token);
      }
    } catch (_) {}
  }

  Future<void> unregisterToken() async {
    final token = await getLocalToken();
    if (token == null || token.isEmpty) return;

    if (!manager.isAuthenticated) {
      await clearLocalToken();
      return;
    }

    try {
      final res = await helper.postTyped<StatusData>(
        '/push/unregister_fcm',
        data: {'fcm_token': token},
        parse: (j) => StatusData.fromJson(j),
      );

      if (res.success) {
        await clearLocalToken();
      }
    } catch (_) {}
  }

  Future<void> onLoginSuccess() async {
    try {
      await init();
      await registerToken();
    } catch (_) {}
  }

  Future<void> onBeforeLogout() async {
    try {
      await unregisterToken();
    } catch (_) {}
  }
}
