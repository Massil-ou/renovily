import '../../../Auth/Shared/AuthModels.dart';
import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import 'ClientProfileData.dart';

class ClientProfileService {
  final Manager _manager;
  final HelperService _auth;

  ClientProfileService(this._manager, this._auth);

  static const String pathUpdate = '/renovily/client/profile/update';

  Future<BaseResponse<void>> updateProfile(ClientProfileData data) async {
    final r = await _auth.postTyped<dynamic>(
      pathUpdate,
      data: data.toJson(),
      parse: null,
    );

    return BaseResponse<void>(
      success: r.success,
      message: r.message,
      code: r.code,
      data: null,
    );
  }
}