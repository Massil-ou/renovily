// lib/Auth/Services/PasswordService.dart
import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Shared/AuthModels.dart';

class PasswordService {
  final Manager _manager;
  final HelperService _auth;

  PasswordService(this._manager, this._auth);

  Future<BaseResponse<StatusData>> changePasswordWithToken({
    required String email,
    required String token,
    required String newPassword,
  }) {
    return _auth.postTyped<StatusData>(
      '/renovily/password/auth_change_password',
      data: {'email': email, 'token': token, 'new_password': newPassword},
      parse: (j) => StatusData.fromJson(j),
    );
  }
}
