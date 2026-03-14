// lib/init/HelperService.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../Auth/Shared/AuthModels.dart';
import 'BaseResponse.dart';

class HelperService {
  final Dio dio;
  final FlutterSecureStorage storage;
  final _uuid = const Uuid();
  final String deviceMacKeyB64;

  final bool enableApiLogs;

  /// Callback si on doit forcer un logout (refresh expiré / invalide etc.)
  final Future<void> Function(String reason)? onForceLogout;

  Completer<void>? _refreshCompleter;
  late final Dio _authDio;

  static const _kAccessKey = 'access';
  static const _kRefreshKey = 'refresh';
  static const _kAccessExpiresAtKey = 'access_expires_at';
  static const _kRefreshExpiresAtKey = 'refresh_expires_at';
  static const _kRefreshExpiresAtEpochKey = 'refresh_expires_at_epoch';

  /// On refresh un peu avant l'expiration access token (évite 401)
  static const int _expirySkewSeconds = 60;

  String? _cachedDeviceHeader;
  int? _cachedDeviceHeaderExp;
  static const int _deviceHeaderSkewSeconds = 60;

  // ---- API token error strict match (NO regex, NO contains) ----
  static const int _tokenInvalidCode = 903;
  static const String _tokenInvalidMsg = 'Token invalide ou expiré.';

  // ---- Log settings ----
  static const int _logMaxChars = 6000;
  static const int _logMaxBodyChars = 2500;
  static const int _logMaxHeadersChars = 1200;

  HelperService(
      this.dio,
      this.storage, {
        required this.deviceMacKeyB64,
        this.onForceLogout,
        this.enableApiLogs = true,
      }) {
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.validateStatus = (s) => s != null && s >= 200 && s < 600;

    _authDio = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        sendTimeout: dio.options.sendTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (s) => s != null && s >= 200 && s < 600,
      ),
    );

    _installAuthInterceptor();
  }

  Dio get authDio => _authDio;

  // ---------------- LOG helpers ----------------

  void _apiLog(String msg, {String rid = '-', String tag = 'API'}) {
    if (!enableApiLogs) return;

    final safe = msg.length > _logMaxChars
        ? '${msg.substring(0, _logMaxChars)}…(truncated)'
        : msg;

    dev.log(safe, name: '$tag#$rid');
  }

  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;

  Map<String, dynamic> _maskHeaders(Map<String, dynamic> h) {
    final out = <String, dynamic>{};
    h.forEach((k, v) {
      final key = k.toLowerCase();
      if (key == 'authorization') {
        out[k] = 'Bearer ***';
      } else if (key == 'x-device-id') {
        out[k] = '***';
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  dynamic _maskBody(dynamic data) {
    try {
      if (data == null) return null;

      dynamic decoded = data;
      if (data is String) decoded = jsonDecode(data);

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        if (map.containsKey('refresh_token')) map['refresh_token'] = '***';
        if (map.containsKey('password')) map['password'] = '***';
        if (map.containsKey('otp')) map['otp'] = '***';
        if (map.containsKey('token')) map['token'] = '***';
        return map;
      }

      return decoded;
    } catch (_) {
      return data is String ? _truncate(data, _logMaxBodyChars) : data;
    }
  }

  String _pretty(dynamic v) {
    try {
      if (v == null) return 'null';
      if (v is String) {
        final decoded = jsonDecode(v);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return v.toString();
    }
  }

  // ---------------- JSON helpers ----------------

  Map<String, dynamic> asJson(dynamic data, {String ctx = ''}) {
    if (data == null) return <String, dynamic>{};

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  bool _isTokenInvalid903(Map<String, dynamic> payload) {
    final success = (payload['success'] ?? false) == true;

    final code = (payload['code'] is int)
        ? payload['code'] as int
        : int.tryParse('${payload['code'] ?? -1}') ?? -1;

    final msg = (payload['message'] ?? '').toString();

    return !success && code == _tokenInvalidCode && msg == _tokenInvalidMsg;
  }

  // ---------------- Tokens storage ----------------

  Future<String?> getAccessToken() async => storage.read(key: _kAccessKey);
  Future<String?> getRefreshToken() async => storage.read(key: _kRefreshKey);

  Future<void> saveTokens(TokensData t) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final accessExpiresAt = now + t.accessExpiresIn;

    await storage.write(key: _kAccessKey, value: t.accessToken);
    await storage.write(key: _kRefreshKey, value: t.refreshToken);

    await storage.write(
      key: _kAccessExpiresAtKey,
      value: accessExpiresAt.toString(),
    );

    await storage.write(key: _kRefreshExpiresAtKey, value: t.refreshExpiresAt);

    final epoch = _tryParseMysqlUtcToEpoch(t.refreshExpiresAt);
    if (epoch != null) {
      await storage.write(
        key: _kRefreshExpiresAtEpochKey,
        value: epoch.toString(),
      );
    } else {
      await storage.delete(key: _kRefreshExpiresAtEpochKey);
    }
  }

  Future<void> clearTokens() async {
    await storage.delete(key: _kAccessKey);
    await storage.delete(key: _kRefreshKey);
    await storage.delete(key: _kAccessExpiresAtKey);
    await storage.delete(key: _kRefreshExpiresAtKey);
    await storage.delete(key: _kRefreshExpiresAtEpochKey);
  }

  int? _tryParseMysqlUtcToEpoch(String v) {
    try {
      final s = v.trim();
      if (s.isEmpty) return null;
      final iso = '${s.replaceFirst(' ', 'T')}Z';
      return DateTime.parse(iso).toUtc().millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return null;
    }
  }

  Future<int?> _getAccessExpiresAt() async {
    final v = await storage.read(key: _kAccessExpiresAtKey);
    if (v == null || v.isEmpty) return null;
    return int.tryParse(v);
  }

  /// ✅ refresh si:
  /// - access manquant
  /// - exp manquante
  /// - ou access expire bientôt
  Future<bool> _shouldRefreshNow() async {
    final rt = await getRefreshToken();
    if (rt == null || rt.isEmpty) return false;

    final at = await getAccessToken();
    final expAt = await _getAccessExpiresAt();

    if (at == null || at.isEmpty) return true;
    if (expAt == null) return true;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return (expAt - now) <= _expirySkewSeconds;
  }

  Future<bool> _isRefreshExpiredOrMissing() async {
    final rt = await getRefreshToken();
    if (rt == null || rt.isEmpty) return true;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final v = await storage.read(key: _kRefreshExpiresAtEpochKey);
    final exp = v == null ? null : int.tryParse(v);

    if (exp == null) return false; // si inconnu, on tente quand même
    return (exp - now) <= 0;
  }

  // ---------------- Device header ----------------

  Future<String> _getOrCreateDeviceId() async {
    const key = 'device_id';
    var id = await storage.read(key: key);
    if (id == null || id.isEmpty) {
      id = _uuid.v4();
      await storage.write(key: key, value: id);
    }
    return id;
  }

  Future<String> deviceHeaderValue() async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    if (_cachedDeviceHeader != null && _cachedDeviceHeaderExp != null) {
      final exp = _cachedDeviceHeaderExp!;
      if ((exp - now) > _deviceHeaderSkewSeconds) {
        return _cachedDeviceHeader!;
      }
    }

    final deviceId = await _getOrCreateDeviceId();
    final exp = now + 86400;

    final payload = '$deviceId|$now|$exp';
    final key = base64Decode(deviceMacKeyB64);
    final macBytes = Hmac(sha256, key).convert(utf8.encode(payload)).bytes;

    final map = {
      'device_id': deviceId,
      'iat': now,
      'exp': exp,
      'mac': base64Encode(macBytes),
    };

    final header = base64Encode(utf8.encode(jsonEncode(map)));

    _cachedDeviceHeader = header;
    _cachedDeviceHeaderExp = exp;

    return header;
  }

  bool _isAuthRoute(String p) {
    final path = p.toLowerCase();
    return path.contains('/login/auth_login') ||
        path.contains('/login/auth_login_otp') ||
        path.contains('/login/refresh');
  }

  // ---------------- Force logout ----------------

  Future<void> _forceLogout(String reason, {required String rid}) async {
    _apiLog('FORCE LOGOUT: $reason', rid: rid, tag: 'AUTH');
    await clearTokens();
    if (onForceLogout != null) {
      try {
        await onForceLogout!(reason);
      } catch (_) {}
    }
  }

  // ---------------- Interceptor ----------------

  void _installAuthInterceptor() {
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final rid = options.extra['rid']?.toString() ??
              '${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
          options.extra['rid'] = rid;

          options.extra['t0'] = DateTime.now().millisecondsSinceEpoch;

          try {
            final devHeader = await deviceHeaderValue();
            options.headers['X-Device-Id'] = devHeader;

            final skipRefresh = options.extra['skipRefresh'] == true;
            final isAuthRoute = _isAuthRoute(options.path);

            if (!skipRefresh && !isAuthRoute) {
              await _refreshIfNeeded(rid: rid);
            }

            final at = await getAccessToken();
            if (at != null && at.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $at';
            } else {
              options.headers.remove('Authorization');
            }

            // LOG REQUEST
            final maskedHeaders = _maskHeaders(
              options.headers.map((k, v) => MapEntry(k.toString(), v)),
            );
            final bodyMasked = _maskBody(options.data);

            _apiLog(
              [
                '➡️ ${options.method} ${options.baseUrl}${options.path}',
                if (options.queryParameters.isNotEmpty)
                  'Query: ${_pretty(options.queryParameters)}',
                'Headers: ${_truncate(_pretty(maskedHeaders), _logMaxHeadersChars)}',
                if (bodyMasked != null)
                  'Body: ${_truncate(_pretty(bodyMasked), _logMaxBodyChars)}',
              ].join('\n'),
              rid: rid,
            );

            handler.next(options);
          } catch (e) {
            _apiLog('❌ onRequest error: $e', rid: rid);
            handler.reject(
              DioException(
                requestOptions: options,
                error: e,
                type: DioExceptionType.unknown,
              ),
            );
          }
        },
        onResponse: (response, handler) async {
          final rid = response.requestOptions.extra['rid']?.toString() ?? '-';
          final t0 = response.requestOptions.extra['t0'];
          final ms = (t0 is int)
              ? (DateTime.now().millisecondsSinceEpoch - t0)
              : -1;

          final status = response.statusCode ?? -1;
          final payloadPreview = _truncate(
            _pretty(_maskBody(response.data)),
            _logMaxChars,
          );

          _apiLog(
            [
              '⬅️ ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
              'Status: $status   Duration: ${ms}ms',
              'Response: $payloadPreview',
            ].join('\n'),
            rid: rid,
          );

          handler.next(response);
        },
        onError: (err, handler) async {
          final rid = err.requestOptions.extra['rid']?.toString() ?? '-';
          final status = err.response?.statusCode ?? -1;
          final alreadyRetried = err.requestOptions.extra['retried'] == true;
          final isAuthRoute = _isAuthRoute(err.requestOptions.path);

          final t0 = err.requestOptions.extra['t0'];
          final ms = (t0 is int)
              ? (DateTime.now().millisecondsSinceEpoch - t0)
              : -1;

          _apiLog(
            [
              '🧨 ERROR ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}',
              'Status: $status   Duration: ${ms}ms   Retried: $alreadyRetried',
              if (err.message != null) 'Message: ${err.message}',
              if (err.response?.data != null)
                'ErrorBody: ${_truncate(_pretty(_maskBody(err.response?.data)), _logMaxChars)}',
            ].join('\n'),
            rid: rid,
          );

          // 903 strict => logout
          try {
            final payload = asJson(err.response?.data, ctx: 'onError#$rid');
            if (_isTokenInvalid903(payload)) {
              await _forceLogout('API code=903 token invalid/expired', rid: rid);
              return handler.next(err);
            }
          } catch (_) {}

          // ✅ 401 -> refresh + retry (1 fois)
          if (status == 401 && !alreadyRetried && !isAuthRoute) {
            try {
              _apiLog('🔁 401 -> try refresh then retry request', rid: rid);
              await _refreshTokens(rid: rid);

              final req = err.requestOptions;
              req.extra['retried'] = true;

              final devHeader = await deviceHeaderValue();
              final at = await getAccessToken();

              req.headers['X-Device-Id'] = devHeader;
              if (at != null && at.isNotEmpty) {
                req.headers['Authorization'] = 'Bearer $at';
              } else {
                req.headers.remove('Authorization');
              }

              final response = await dio.fetch(req);

              final map = asJson(response.data, ctx: 'retry#$rid');
              if (_isTokenInvalid903(map)) {
                await _forceLogout('Retry got 903 token invalid', rid: rid);
              }

              _apiLog('✅ Retry OK (status=${response.statusCode})', rid: rid);
              return handler.resolve(response);
            } catch (e) {
              _apiLog('❌ Retry failed after refresh: $e', rid: rid);
              return handler.next(err);
            }
          }

          handler.next(err);
        },
      ),
    );
  }

  Future<void> _refreshIfNeeded({required String rid}) async {
    final need = await _shouldRefreshNow();
    if (!need) return;

    final badRefresh = await _isRefreshExpiredOrMissing();
    if (badRefresh) {
      await _forceLogout('Refresh token missing/expired', rid: rid);
      return;
    }

    await _refreshTokens(rid: rid);
  }

  /// ✅ Refresh = /login/refresh avec refresh_token
  Future<void> _refreshTokens({required String rid}) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();

    try {
      final rt = await getRefreshToken();
      if (rt == null || rt.isEmpty) throw StateError('No refresh token');

      final devHeader = await deviceHeaderValue();

      _apiLog('♻️ Refresh tokens via /login/refresh', rid: rid, tag: 'AUTH');

      final res = await _authDio.post(
        '/login/refresh',
        data: jsonEncode({'refresh_token': rt}),
        options: Options(
          headers: {'X-Device-Id': devHeader},
          extra: {'skipRefresh': true, 'rid': 'refresh-$rid'},
        ),
      );

      final payload = asJson(res.data, ctx: 'refresh#$rid');

      if (_isTokenInvalid903(payload)) {
        await _forceLogout('Refresh returned 903 token invalid', rid: rid);
        throw StateError('Refresh returned 903');
      }

      final base = BaseResponse.fromJson<TokensData>(
        payload,
        parse: (j) => TokensData.fromJson(j),
      );

      if (!base.success || base.data == null) {
        throw StateError('Refresh failed: ${base.message} (${base.code})');
      }

      await saveTokens(base.data!);

      _apiLog('✅ Refresh OK (new tokens saved)', rid: rid, tag: 'AUTH');
      _refreshCompleter!.complete();
    } catch (e) {
      _apiLog('❌ Refresh failed: $e', rid: rid, tag: 'AUTH');

      await _forceLogout('Refresh failed', rid: rid);

      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  // ----------------------- HTTP helpers -----------------------

  Future<BaseResponse<R>> postTyped<R>(
      String path, {
        Map<String, dynamic>? data,
        R Function(Map<String, dynamic>)? parse,
        Options? options,
      }) async {
    final rid =
        '${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
    final opt = (options ?? Options()).copyWith(
      extra: <String, dynamic>{...?(options?.extra), 'rid': rid},
    );

    try {
      final res = await dio.post(
        path,
        data: jsonEncode(data ?? {}),
        options: opt,
      );

      final payload = asJson(res.data, ctx: 'post#$rid $path');

      if (_isTokenInvalid903(payload)) {
        await _forceLogout('postTyped got 903 token invalid', rid: rid);
      }

      if (parse == null) {
        final success = (payload['success'] ?? false) == true;
        final message = (payload['message'] ?? '').toString();
        final code = (payload['code'] is int)
            ? payload['code'] as int
            : int.tryParse('${payload['code'] ?? -1}') ?? -1;

        return BaseResponse<R>(
          success: success,
          message: message,
          code: code,
          data: (payload['data'] as R?),
        );
      }

      return BaseResponse.fromJson<R>(payload, parse: parse);
    } on DioException catch (e) {
      return _handleError<R>(e, parse, rid: rid, path: path);
    } catch (e) {
      _apiLog('❌ postTyped unexpected: $e', rid: rid);
      return BaseResponse<R>(
        success: false,
        message: 'unexpected_error',
        code: -1,
        data: null,
      );
    }
  }

  Future<BaseResponse<R>> getTyped<R>(
      String path, {
        Map<String, dynamic>? queryParameters,
        R Function(Map<String, dynamic>)? parse,
        Options? options,
      }) async {
    final rid =
        '${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
    final opt = (options ?? Options()).copyWith(
      extra: <String, dynamic>{...?(options?.extra), 'rid': rid},
    );

    try {
      final res = await dio.get(
        path,
        queryParameters: queryParameters,
        options: opt,
      );

      final payload = asJson(res.data, ctx: 'get#$rid $path');

      if (_isTokenInvalid903(payload)) {
        await _forceLogout('getTyped got 903 token invalid', rid: rid);
      }

      if (parse == null) {
        final success = (payload['success'] ?? false) == true;
        final message = (payload['message'] ?? '').toString();
        final code = (payload['code'] is int)
            ? payload['code'] as int
            : int.tryParse('${payload['code'] ?? -1}') ?? -1;

        return BaseResponse<R>(
          success: success,
          message: message,
          code: code,
          data: (payload['data'] as R?),
        );
      }

      return BaseResponse.fromJson<R>(payload, parse: parse);
    } on DioException catch (e) {
      return _handleError<R>(e, parse, rid: rid, path: path);
    } catch (e) {
      _apiLog('❌ getTyped unexpected: $e', rid: rid);
      return BaseResponse<R>(
        success: false,
        message: 'unexpected_error',
        code: -1,
        data: null,
      );
    }
  }

  BaseResponse<R> _handleError<R>(
      DioException e,
      R Function(Map<String, dynamic>)? parse, {
        required String rid,
        required String path,
      }) {
    final data = e.response?.data;

    try {
      Map<String, dynamic> map;

      if (data is Map<String, dynamic>) {
        map = data;
      } else if (data is Map) {
        map = Map<String, dynamic>.from(data);
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        } else if (decoded is Map) {
          map = Map<String, dynamic>.from(decoded);
        } else {
          map = <String, dynamic>{};
        }
      } else {
        map = <String, dynamic>{};
      }

      if (_isTokenInvalid903(map)) {
        unawaited(_forceLogout('handleError got 903 token invalid', rid: rid));
      }

      if (parse == null) {
        final success = (map['success'] ?? false) == true;
        final message = (map['message'] ?? '').toString();
        final code = (map['code'] is int)
            ? map['code'] as int
            : int.tryParse('${map['code'] ?? -1}') ?? -1;

        return BaseResponse<R>(
          success: success,
          message: message,
          code: code,
          data: (map['data'] as R?),
        );
      }

      return BaseResponse.fromJson<R>(map, parse: parse);
    } catch (_) {
      return BaseResponse<R>(
        success: false,
        message: 'network_error',
        code: e.response?.statusCode ?? -1,
        data: null,
      );
    }
  }
}