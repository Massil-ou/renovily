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
    lastError = null;
    notifyListeners();

    try {
      final r = await _service.getProfile();

      if (r.success) {
        payload = r.data;
        _loadedOnce = true;
      } else {
        lastError = r.message.isNotEmpty ? r.message : 'load_failed';
      }
    } catch (_) {
      lastError = 'exception';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _loadedOnce = false;
    await _load();
  }

  Future<BaseResponse<void>> requestPro(PartnerProfileData form) async {
    if (isSaving) {
      return BaseResponse<void>(
        success: false,
        message: 'busy',
        code: -1,
        data: null,
      );
    }

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final r = await _service.requestPro(form);

      if (r.success) {
        if (r.data != null) {
          payload = r.data;
        } else {
          final current = payload?.profile;

          payload = PartnerProfilePayload(
            isPro: false,
            profile: PartnerProfileData(
              companyName: form.companyName,
              tradeName: form.tradeName,
              companyType: form.companyType,
              siret: form.siret,
              rcNumber: form.rcNumber,
              nifNumber: form.nifNumber,
              nisNumber: form.nisNumber,
              taxRegime: form.taxRegime,
              vatNumber: form.vatNumber,
              statusPro: current?.statusPro ?? 'pending',
            ),
          );
        }

        _loadedOnce = true;
      } else {
        lastError = r.message.isNotEmpty ? r.message : 'request_failed';
      }

      return BaseResponse<void>(
        success: r.success,
        message: r.message,
        code: r.code,
        data: null,
      );
    } catch (_) {
      lastError = 'exception';
      return BaseResponse<void>(
        success: false,
        message: 'exception',
        code: -1,
        data: null,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<BaseResponse<void>> updateProfile(Map<String, dynamic> patch) async {
    if (isSaving) {
      return BaseResponse<void>(
        success: false,
        message: 'busy',
        code: -1,
        data: null,
      );
    }

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final r = await _service.updateProfile(patch);

      if (r.success) {
        if (r.data != null) {
          payload = r.data;
        } else if (payload?.profile != null) {
          final p = payload!.profile!;

          payload = PartnerProfilePayload(
            isPro: payload?.isPro ?? false,
            profile: PartnerProfileData(
              companyName: (patch['company_name'] ?? p.companyName).toString(),
              tradeName: patch.containsKey('trade_name')
                  ? patch['trade_name']?.toString()
                  : p.tradeName,
              companyType: patch.containsKey('company_type')
                  ? patch['company_type']?.toString()
                  : p.companyType,
              siret: patch.containsKey('siret')
                  ? patch['siret']?.toString()
                  : p.siret,
              rcNumber: patch.containsKey('rc_number')
                  ? patch['rc_number']?.toString()
                  : p.rcNumber,
              nifNumber: patch.containsKey('nif_number')
                  ? patch['nif_number']?.toString()
                  : p.nifNumber,
              nisNumber: patch.containsKey('nis_number')
                  ? patch['nis_number']?.toString()
                  : p.nisNumber,
              taxRegime: patch.containsKey('tax_regime')
                  ? patch['tax_regime']?.toString()
                  : p.taxRegime,
              vatNumber: patch.containsKey('vat_number')
                  ? (patch['vat_number'] == null
                  ? null
                  : double.tryParse(patch['vat_number'].toString()))
                  : p.vatNumber,
              statusPro: p.statusPro,
            ),
          );
        }

        _loadedOnce = true;
      } else {
        lastError = r.message.isNotEmpty ? r.message : 'update_failed';
      }

      return BaseResponse<void>(
        success: r.success,
        message: r.message,
        code: r.code,
        data: null,
      );
    } catch (_) {
      lastError = 'exception';
      return BaseResponse<void>(
        success: false,
        message: 'exception',
        code: -1,
        data: null,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }

  void clear() {
    payload = null;
    lastError = null;
    _loadedOnce = false;
    notifyListeners();
  }
}