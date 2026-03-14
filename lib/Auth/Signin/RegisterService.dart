// lib/Auth/Signup/RegisterService.dart
import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../Shared/AuthModels.dart';

class RegisterService {
  final HelperService _auth;

  RegisterService(this._auth);

  Future<BaseResponse<StatusData>> register(RegisterRequest req) {
    return _auth.postTyped<StatusData>(
      '/register/auth_register',
      data: req.toJson(),
      parse: (j) => StatusData.fromJson(j),
    );
  }

  Future<BaseResponse<LoginData>> verifyRegisterOtp(
      VerifyRegisterOtpRequest req,
      ) {
    return _auth.postTyped<LoginData>(
      '/register/auth_register_verify_otp',
      data: req.toJson(),
      parse: (j) => LoginData.fromJson(j),
    );
  }

  Future<BaseResponse<StatusData>> resendRegisterOtp(String email) {
    return _auth.postTyped<StatusData>(
      '/register/auth_register_resend_otp',
      data: EmailOnlyRequest(email).toJson(),
      parse: (j) => StatusData.fromJson(j),
    );
  }
}