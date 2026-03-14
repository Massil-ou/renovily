import 'package:flutter/foundation.dart';
import 'PartnerProfileModel.dart';
import '../../App/BaseResponse.dart';
import '../../App/Manager.dart';
import '../../App/HelperService.dart';
import 'PartnerProfileService.dart';

class PartnerProfileManager extends ChangeNotifier {
  final PartnerProfileService _service;
  final Manager _manager;

  PartnerProfileManager(this._manager, HelperService helper)
      : _service = PartnerProfileService(_manager, helper);

  bool isLoading = false;
  bool isSaving = false;

  bool _loadedOnce = false;

  String? lastError;

  PartnerProfilePayload? payload;

  bool get hasProfile => payload?.profile != null;

  PartnerProfileData? get profile => payload?.profile;

  Future<void> ensureLoaded() async {
    if (_loadedOnce || isLoading) return;
    await _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    final r = await _service.getProfile();

    if (r.success) {
      payload = r.data;
      _loadedOnce = true;
    } else {
      lastError = r.message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loadedOnce = false;
    await _load();
  }

  Future<BaseResponse<void>> requestPro(PartnerProfileData form) async {
    if (isSaving) {
      return BaseResponse(success: false, message: 'busy', code: -1, data: null);
    }

    isSaving = true;
    notifyListeners();

    final r = await _service.requestPro(form);

    if (r.success) {
      payload = r.data;
    }

    isSaving = false;
    notifyListeners();

    return BaseResponse(
      success: r.success,
      message: r.message,
      code: r.code,
      data: null,
    );
  }

  Future<BaseResponse<void>> updateProfile(Map<String, dynamic> patch) async {
    if (isSaving) {
      return BaseResponse(success: false, message: 'busy', code: -1, data: null);
    }

    isSaving = true;
    notifyListeners();

    final r = await _service.updateProfile(patch);

    if (r.success) {
      payload = r.data ?? payload;
    }

    isSaving = false;
    notifyListeners();

    return BaseResponse(
      success: r.success,
      message: r.message,
      code: r.code,
      data: null,
    );
  }
}