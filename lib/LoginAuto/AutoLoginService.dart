import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../Auth/Shared/AuthModels.dart';
import '../App/BaseResponse.dart';
import '../App/HelperService.dart';
import '../App/Manager.dart';

class AutoLoginService {
  final Manager _manager;
  final HelperService _auth;

  AutoLoginService(this._manager, this._auth);

  static const String _endpoint = '/renovily/login/auto_login';

  Future<BaseResponse<LoginData>> serviceAutoLogin({
    required String refreshToken,
    Duration maxWait = const Duration(seconds: 5),
  }) async {
    final Dio authDio = _auth.authDio;

    try {
      final devHeader = await _auth.deviceHeaderValue();

      final res = await authDio
          .post(
            _endpoint,
            data: jsonEncode({'refresh_token': refreshToken}),
            options: Options(
              headers: {'X-Device-Id': devHeader},
              extra: {'skipRefresh': true},
            ),
          )
          .timeout(maxWait);

      final payload = _auth.asJson(res.data);

      return BaseResponse.fromJson<LoginData>(
        payload,
        parse: (j) => LoginData.fromJson(j),
      );
    } on TimeoutException {
      return BaseResponse<LoginData>(
        success: false,
        message: 'timeout',
        code: 408,
        data: null,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      try {
        final payload = _auth.asJson(data);
        return BaseResponse.fromJson<LoginData>(
          payload,
          parse: (j) => LoginData.fromJson(j),
        );
      } catch (_) {
        return BaseResponse<LoginData>(
          success: false,
          message: 'network_error',
          code: e.response?.statusCode ?? -1,
          data: null,
        );
      }
    } catch (_) {
      return BaseResponse<LoginData>(
        success: false,
        message: 'network_error',
        code: -1,
        data: null,
      );
    }
  }
}
