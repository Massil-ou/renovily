import 'dart:ui';
import 'package:flutter/material.dart';

import '../../App/AppLanguage.dart';
import '../../App/Manager.dart';
import '../../Dashboard/LanguageService.dart';
import '../../Shared/Forms/GlassFormKit.dart';
import '../Shared/auth_scaffold.dart';
import '../Shared/banners.dart';
import '../Shared/nav.dart';
import 'PasswordManager.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({
    super.key,
    required this.manager,
    required this.email,
    required this.token,
  });

  final Manager manager;
  final String email;
  final String token;

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();

  final _pwdFieldKey = GlobalKey();
  final _pwd2FieldKey = GlobalKey();

  PasswordManager get _pm => widget.manager.passwordManager;

  @override
  void initState() {
    super.initState();
    _pm.startFlow(
      email: widget.email,
      token: widget.token,
    );
  }

  @override
  void didUpdateWidget(covariant NewPasswordView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.email != widget.email || oldWidget.token != widget.token) {
      _pm.startFlow(
        email: widget.email,
        token: widget.token,
      );
      _pwdCtrl.clear();
      _pwd2Ctrl.clear();
    }
  }

  @override
  void dispose() {
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _ensureVisible(GlobalKey key) async {
    await Future.delayed(const Duration(milliseconds: 30));
    if (!mounted) return;
    final ctx = key.currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.18,
    );
  }

  Widget _btnLoader() {
    return const SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.manager.languageService.language,
      builder: (_, __, ___) {
        final isMobile = widget.manager.globalSingleton.isMobile(context);
        final topGap =
            MediaQuery.of(context).padding.top +
                kToolbarHeight +
                (isMobile ? 16 : 40);

        final s = widget.manager.renovilyTranslation;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _pm.loading,
            _pm.success,
            _pm.obscure,
            _pm.inlineError,
          ]),
          builder: (_, __) {
            final content = Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            visualDensity: VisualDensity.compact,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _pm.success.value
                                ? _buildSuccessCard(s)
                                : _buildFormCard(s),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

            return AuthScaffold(
              manager: widget.manager,
              title: 'Renovily',
              padding: EdgeInsets.fromLTRB(6, topGap, 6, 24),
              child: content,
            );
          },
        );
      },
    );
  }

  Widget _buildFormCard(Renovily s) {
    return Column(
      key: const ValueKey('new_pwd_form_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          s.resetPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.resetForEmail(_pm.email),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        if (_pm.inlineError.value != null) ...[
          ErrorBanner(
            message: _pm.inlineError.value!,
            onClose: _pm.clearError,
          ),
          const SizedBox(height: 12),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassInputField(
                key: _pwdFieldKey,
                controller: _pwdCtrl,
                label: s.newPassword,
                hint: '••••••••',
                icon: Icons.lock_reset_outlined,
                obscureText: _pm.obscure.value,
                validator: _pm.validatePassword,
                onTap: () => _ensureVisible(_pwdFieldKey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _pm.obscure.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: _pm.loading.value ? null : _pm.toggleObscure,
                ),
              ),
              const SizedBox(height: 14),
              GlassInputField(
                key: _pwd2FieldKey,
                controller: _pwd2Ctrl,
                label: s.confirmPassword,
                hint: '••••••••',
                icon: Icons.verified_user_outlined,
                obscureText: _pm.obscure.value,
                validator: (v) =>
                    _pm.validateConfirmPassword(v, _pwdCtrl.text),
                onTap: () => _ensureVisible(_pwd2FieldKey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _pm.loading.value
                      ? null
                      : () async {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    await _pm.submit(
                      newPassword: _pwdCtrl.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _pm.loading.value
                      ? _btnLoader()
                      : Text(
                    s.changePassword,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard(Renovily s) {
    return Column(
      key: const ValueKey('new_pwd_success_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Colors.white.withOpacity(0.95),
        ),
        const SizedBox(height: 10),
        Text(
          s.success,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.passwordChangedPleaseLogin,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => goNamedAfterFrame(context, 'login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              s.signIn,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}