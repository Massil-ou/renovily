import 'package:flutter/foundation.dart';

import '../../../Auth/Shared/AuthModels.dart';
import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import 'ClientProfileData.dart';
import 'ClientProfileService.dart';

class ClientProfileManager extends ChangeNotifier {
  final ClientProfileService _service;
  final Manager _manager;

  ClientProfileManager(this._manager, HelperService helper)
      : _service = ClientProfileService(_manager, helper);

  bool isSaving = false;

  String? lastError;

  UserData? get user => _manager.currentUser;

  ClientProfileData get profile =>
      ClientProfileData.fromUser(_manager.currentUser!);

  Future<BaseResponse<void>> updateProfile(ClientProfileData data) async {
    final patch = data.toJson();

    if (isSaving || patch.isEmpty) {
      return BaseResponse(
        success: false,
        message: 'invalid',
        code: -1,
        data: null,
      );
    }

    isSaving = true;
    lastError = null;

    notifyListeners();

    try {
      final r = await _service.updateProfile(data);

      if (!r.success) {
        lastError = r.message.isNotEmpty ? r.message : 'error_${r.code}';

        return BaseResponse(
          success: false,
          message: lastError!,
          code: r.code,
          data: null,
        );
      }

      _syncUser(data);

      return BaseResponse(
        success: true,
        message: r.message,
        code: r.code,
        data: null,
      );
    } catch (_) {
      lastError = 'exception';

      return BaseResponse(
        success: false,
        message: lastError!,
        code: -2,
        data: null,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void _syncUser(ClientProfileData data) {
    final u = _manager.currentUser;

    if (u == null) return;

    _manager.currentUser = UserData(
      email: u.email,
      firstName: data.firstName ?? u.firstName,
      lastName: data.lastName ?? u.lastName,
      number: data.number ?? u.number,
      wilaya: data.wilaya ?? u.wilaya,
      commune: data.commune ?? u.commune,
      soldeUser: u.soldeUser,
      role: u.role,
      referralCode: u.referralCode,
      referredBy: u.referredBy,
      referralConfirmed: u.referralConfirmed,
      isPro: u.isPro,
      proProfile: u.proProfile,
    );
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }
}