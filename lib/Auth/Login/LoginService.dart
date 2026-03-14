import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../Shared/AuthModels.dart';

class LoginService {
  final Manager _manager;
  final HelperService _auth;

  LoginService(this._manager, this._auth);

  Future<BaseResponse<LoginStep1Data>> authLogin(LoginRequest req) {
    return _auth.postTyped<LoginStep1Data>(
      '/login/auth_login',
      data: req.toJson(),
      parse: (j) => LoginStep1Data.fromJson(j),
    );
  }

  Future<BaseResponse<LoginData>> authLoginOtp(LoginOtpRequest req) {
    return _auth.postTyped<LoginData>(
      '/login/auth_login_otp',
      data: req.toJson(),
      parse: (j) => LoginData.fromJson(j),
    );
  }

  Future<BaseResponse<StatusData>> sendPasswordResetLink(String email) {
    return _auth.postTyped<StatusData>(
      '/password/auth_forgot_password',
      data: EmailOnlyRequest(email).toJson(),
      parse: (j) => StatusData.fromJson(j),
    );
  }
}