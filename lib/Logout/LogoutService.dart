// lib/Auth/Logout/LogoutService.dart
import '../../../Auth/Shared/AuthModels.dart';
import '../App/BaseResponse.dart';
import '../App/HelperService.dart';
import '../App/Manager.dart';

class LogoutService {
  final Manager _manager;
  final HelperService _auth;

  LogoutService(this._manager, this._auth);

  Future<BaseResponse<StatusData>> logoutWithRefresh({
    required String refreshToken,
    String? fcmToken,
  }) {
    return _auth.postTyped<StatusData>(
      '/auth/logout',
      data: {
        'refresh_token': refreshToken,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      },
      parse: (j) => StatusData.fromJson(j),
    );
  }
}
