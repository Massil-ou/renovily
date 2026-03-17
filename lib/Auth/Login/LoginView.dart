import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../App/AppLanguage.dart';
import '../../App/Manager.dart';
import '../../Dashboard/LanguageService.dart';
import '../../Shared/Forms/GlassFormKit.dart';
import '../Shared/auth_scaffold.dart';
import '../Shared/banners.dart';
import '../Shared/nav.dart';
import '../Shared/validators.dart';
import 'LoginManager.dart';

class LoginView extends StatefulWidget {
  final Manager manager;
  const LoginView({super.key, required this.manager});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _loginKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final _forgotKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _forgotEmailCtrl = TextEditingController();

  final _emailFieldKey = GlobalKey();
  final _passFieldKey = GlobalKey();
  final _otpFieldKey = GlobalKey();
  final _forgotEmailFieldKey = GlobalKey();

  LoginManager get _lm => widget.manager.loginManager;

  @override
  void initState() {
    super.initState();
    _initRemembered();
  }

  Future<void> _initRemembered() async {
    await _lm.initRemembered();
    if (!mounted) return;

    _emailCtrl.text = _lm.email;
    _passCtrl.text = _lm.password;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _otpCtrl.dispose();
    _forgotEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureVisible(GlobalKey key) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    final ctx = key.currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.35,
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

  Future<void> _submitLoginStep1() async {
    FocusScope.of(context).unfocus();
    if (!(_loginKey.currentState?.validate() ?? false)) return;

    final previousStep = _lm.loginStep.value;

    await _lm.submitLoginStep1(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (previousStep != _lm.loginStep.value &&
        _lm.loginStep.value == LoginStepState.otp) {
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => _ensureVisible(_otpFieldKey),
      );
    }
  }

  Future<void> _submitLoginStep2() async {
    FocusScope.of(context).unfocus();
    if (!(_otpKey.currentState?.validate() ?? false)) return;

    final resp = await _lm.submitLoginStep2(
      otp: _otpCtrl.text,
    );

    if (!mounted) return;

    if (resp.success) {
      goAfterFrame(context, '/dashboard');
    }
  }

  Future<void> _submitForgotByLink() async {
    FocusScope.of(context).unfocus();
    if (!(_forgotKey.currentState?.validate() ?? false)) return;

    final wasSent = _lm.forgotStep.value;

    await _lm.submitForgotByLink(
      email: _forgotEmailCtrl.text,
    );

    if (!mounted) return;

    if (wasSent != _lm.forgotStep.value &&
        _lm.forgotStep.value == ForgotStepState.sent) {
      _forgotEmailCtrl.text = _lm.forgotEmail;
    }
  }

  void _openForgot() {
    if (_lm.loading.value) return;

    _lm.openForgot(initialEmail: _emailCtrl.text);
    _forgotEmailCtrl.text = _lm.forgotEmail;

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureVisible(_forgotEmailFieldKey),
    );
  }

  void _backToLogin() {
    if (_lm.loading.value) return;

    _lm.backToLogin();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureVisible(_emailFieldKey),
    );
  }

  void _backToStep1() {
    if (_lm.loading.value) return;

    _lm.backToStep1();
    _otpCtrl.clear();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureVisible(_emailFieldKey),
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

        return AnimatedBuilder(
          animation: Listenable.merge([
            _lm.loginStep,
            _lm.showForgot,
            _lm.forgotStep,
            _lm.obscure,
            _lm.rememberMe,
            _lm.loading,
            _lm.inlineError,
          ]),
          builder: (_, __) {
            final card = ConstrainedBox(
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
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                        child: _lm.showForgot.value
                            ? (_lm.forgotStep.value == ForgotStepState.form
                            ? _buildForgotByLinkCard()
                            : _buildForgotSentCard())
                            : (_lm.loginStep.value == LoginStepState.form
                            ? _buildLoginFormCard()
                            : _buildOtpFormCard()),
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
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: card,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginFormCard() {
    final s = widget.manager.renovilyTranslation;

    return Column(
      key: const ValueKey('login_form_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          s.welcomeBack,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.signInToContinue,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildLoginForm(),
      ],
    );
  }

  Widget _buildOtpFormCard() {
    final s = widget.manager.renovilyTranslation;

    return Column(
      key: const ValueKey('login_otp_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          s.codeVerification,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.step2EnterOtpPwd,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildOtpForm(),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _lm.loading.value ? null : _backToStep1,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: Text(
            s.backToEmailPwd,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotByLinkCard() {
    final s = widget.manager.renovilyTranslation;

    return Column(
      key: const ValueKey('forgot_link_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          s.forgotPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.enterEmailResetLink,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildForgotByLinkForm(),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _lm.loading.value ? null : _backToLogin,
          icon: const Icon(Icons.login, color: Colors.white),
          label: Text(
            s.signIn,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotSentCard() {
    final s = widget.manager.renovilyTranslation;
    final email = _lm.forgotEmail;

    return Column(
      key: const ValueKey('forgot_sent_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Icon(
          Icons.mark_email_read_outlined,
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
          s.resetLinkSentTo(email),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _lm.loading.value ? null : _backToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              s.signIn,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _lm.loading.value
              ? null
              : () {
            _lm.backToForgotForm();
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _ensureVisible(_forgotEmailFieldKey),
            );
          },
          child: Text(
            s.resendLink,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final s = widget.manager.renovilyTranslation;

    return Form(
      key: _loginKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassInputField(
            key: _emailFieldKey,
            controller: _emailCtrl,
            label: s.email,
            hint: s.emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onTap: () => _ensureVisible(_emailFieldKey),
            onChanged: _lm.setEmail,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            validator: (v) => emailValidator(
              widget.manager,
              v,
              msgRequired: s.emailRequired,
              msgInvalid: s.emailInvalid,
            ),
          ),
          const SizedBox(height: 14),
          GlassInputField(
            key: _passFieldKey,
            controller: _passCtrl,
            label: s.password,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: _lm.obscure.value,
            onTap: () => _ensureVisible(_passFieldKey),
            onChanged: _lm.setPassword,
            validator: (v) => passwordValidator(
              widget.manager,
              v,
              min: 8,
              msgRequired: s.passwordRequired,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _lm.obscure.value ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: _lm.loading.value ? null : _lm.toggleObscure,
              tooltip: s.showHidePassword,
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                side: const BorderSide(color: Colors.white70),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.blue
                      : Colors.transparent;
                }),
                checkColor: WidgetStateProperty.all(Colors.white),
              ),
            ),
            child: CheckboxListTile(
              value: _lm.rememberMe.value,
              onChanged: _lm.loading.value
                  ? null
                  : (v) => _lm.setRememberMe(v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(
                s.rememberMe,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _lm.loading.value ? null : _openForgot,
              child: Text(s.forgotPasswordQuestion),
            ),
          ),
          const SizedBox(height: 12),
          if (_lm.inlineError.value != null) ...[
            ErrorBanner(message: _lm.inlineError.value!, onClose: _lm.clearError),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _lm.loading.value ? null : _submitLoginStep1,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _lm.loading.value
                  ? _btnLoader()
                  : Text(
                s.signIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _lm.loading.value
                ? null
                : () => goNamedAfterFrame(context, 'signup'),
            child: Text(
              s.createAccount,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    final s = widget.manager.renovilyTranslation;

    return Form(
      key: _otpKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.codeSentTo(_lm.email),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 12),
          GlassInputField(
            key: _otpFieldKey,
            controller: _otpCtrl,
            label: s.otpCode,
            hint: s.otpHint,
            icon: Icons.verified_outlined,
            keyboardType: TextInputType.text,
            onTap: () => _ensureVisible(_otpFieldKey),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            maxLength: 6,
            validator: (v) =>
                otpValidator(widget.manager, v, len: 6, msg: s.codeInvalid),
          ),
          const SizedBox(height: 12),
          if (_lm.inlineError.value != null) ...[
            ErrorBanner(message: _lm.inlineError.value!, onClose: _lm.clearError),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _lm.loading.value ? null : _submitLoginStep2,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _lm.loading.value
                  ? _btnLoader()
                  : Text(
                s.validateAndLogin,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotByLinkForm() {
    final s = widget.manager.renovilyTranslation;

    return Form(
      key: _forgotKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassInputField(
            key: _forgotEmailFieldKey,
            controller: _forgotEmailCtrl,
            label: s.email,
            hint: s.emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onTap: () => _ensureVisible(_forgotEmailFieldKey),
            onChanged: _lm.setForgotEmail,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            validator: (v) => emailValidator(
              widget.manager,
              v,
              msgRequired: s.emailRequired,
              msgInvalid: s.emailInvalid,
            ),
          ),
          const SizedBox(height: 12),
          if (_lm.inlineError.value != null) ...[
            ErrorBanner(message: _lm.inlineError.value!, onClose: _lm.clearError),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _lm.loading.value ? null : _submitForgotByLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _lm.loading.value
                  ? _btnLoader()
                  : Text(
                s.sendLink,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}