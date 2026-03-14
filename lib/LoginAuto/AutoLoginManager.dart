import '../App/HelperService.dart';
import '../App/Manager.dart';
import 'AutoLoginService.dart';

class AutoLoginManager {
  final Manager manager;
  final AutoLoginService _service;
  AutoLoginManager(this.manager, HelperService helper)
    : _service = AutoLoginService(manager, helper);

  Future<void> bootstrap({
    Duration maxWait = const Duration(seconds: 5),
  }) async {
    final helper = manager.helperService;

    try {
      final rt = await helper.getRefreshToken();
      if (rt == null || rt.isEmpty) {
        await _reset(manager);
        return;
      }

      final resp = await _service.serviceAutoLogin(
        refreshToken: rt,
        maxWait: maxWait,
      );

      manager.lastAutoLogin = resp;

      if (resp.success && resp.data != null) {
        manager.tokens = resp.data!.tokens;
        manager.currentUser = resp.data!.user;
        manager.currentSubscription = resp.data!.subscription;

        await helper.saveTokens(resp.data!.tokens);

        manager.dio.options.headers['Authorization'] =
            'Bearer ${resp.data!.tokens.accessToken}';

        return;
      }

      await _reset(manager);
    } catch (_) {
      await _reset(manager);
    }
  }

  Future<void> _reset(Manager manager) async {
    manager.tokens = null;
    manager.currentUser = null;
    manager.currentSubscription = null;

    manager.dio.options.headers.remove('Authorization');
    await manager.helperService.clearTokens();
  }
}
