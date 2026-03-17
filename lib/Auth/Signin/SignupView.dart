// lib/Auth/Signup/SignupView.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../App/AppLanguage.dart';
import '../../App/Manager.dart';
import '../../Dashboard/LanguageService.dart';
import '../../Shared/Forms/GlassFormKit.dart';
import '../Shared/AuthModels.dart';
import '../Shared/auth_scaffold.dart';
import '../Shared/banners.dart';
import '../Shared/nav.dart';
import '../Shared/steps_bar.dart';
import '../Shared/validators.dart';
import 'RegisterManager.dart';

class SignupView extends StatefulWidget {
  final Manager manager;
  final String? referralCode;

  const SignupView({super.key, required this.manager, this.referralCode});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _infoKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  final _firstNameFieldKey = GlobalKey();
  final _lastNameFieldKey = GlobalKey();
  final _emailFieldKey = GlobalKey();
  final _passFieldKey = GlobalKey();
  final _numberFieldKey = GlobalKey();
  final _wilayaFieldKey = GlobalKey();
  final _communeFieldKey = GlobalKey();
  final _refFieldKey = GlobalKey();
  final _otpFieldKey = GlobalKey();

  bool _hasReferral = false;
  bool _agreeCGU = false;

  String? _wilaya;
  String? _commune;
  late List<String> _wilayasFR;
  List<String> _communesFR = const [];

  RegisterManager get _rm => widget.manager.registerManager;

  @override
  void initState() {
    super.initState();

    _rm.startFlow();

    _wilayasFR = widget.manager.dzLookupService.wilayas(arabic: false).toList();
    _wilaya = _wilayasFR.isNotEmpty ? _wilayasFR.first : null;

    _communesFR = _wilaya == null
        ? const []
        : widget.manager.dzLookupService.getCommunes(_wilaya!, arabic: false);
    _commune = _communesFR.isNotEmpty ? _communesFR.first : null;

    final preset = (widget.referralCode ?? '').trim();
    if (preset.isNotEmpty) {
      _hasReferral = true;
      _refCtrl.text = preset;
    } else {
      _hasReferral = false;
      _refCtrl.text = '';
    }
  }

  @override
  void didUpdateWidget(covariant SignupView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.referralCode != widget.referralCode) {
      final preset = (widget.referralCode ?? '').trim();
      if (preset.isNotEmpty) {
        _hasReferral = true;
        _refCtrl.text = preset;
      } else {
        _hasReferral = false;
        _refCtrl.clear();
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _numberCtrl.dispose();
    _refCtrl.dispose();
    _otpCtrl.dispose();
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

  void _onWilayaChanged(String v) {
    _rm.clearError();

    setState(() {
      _wilaya = v;
      _commune = null;
      _communesFR = const [];
    });

    final list = widget.manager.dzLookupService.getCommunes(v, arabic: false);

    setState(() {
      _communesFR = list;
      _commune = _communesFR.isNotEmpty ? _communesFR.first : null;
    });

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureVisible(_communeFieldKey),
    );
  }

  Future<void> _signupRegister() async {
    FocusScope.of(context).unfocus();

    final s = widget.manager.renovilyTranslation;

    if (!(_infoKey.currentState?.validate() ?? false)) return;

    if (_wilaya == null ||
        _wilaya!.trim().isEmpty ||
        _commune == null ||
        _commune!.trim().isEmpty) {
      _rm.inlineError.value = s.selectWilayaCommune;
      return;
    }

    if (!_agreeCGU) {
      _rm.inlineError.value = s.acceptCGUError;
      return;
    }

    final referral = _hasReferral ? _refCtrl.text.trim() : '';

    final req = RegisterRequest(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      password: _passCtrl.text,
      number: _numberCtrl.text.trim(),
      wilaya: _wilaya!.trim(),
      commune: _commune!.trim(),
      siret: '',
      referralCode: referral,
    );

    final resp = await _rm.submitRegister(req);

    if (!mounted) return;

    if (resp.success) {
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => _ensureVisible(_otpFieldKey),
      );
    }
  }

  Future<void> _signupVerify() async {
    FocusScope.of(context).unfocus();

    if (!(_otpKey.currentState?.validate() ?? false)) return;

    final resp = await _rm.submitVerifyOtp(
      email: _emailCtrl.text.trim().toLowerCase(),
      otp: _otpCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (resp.success) {
      goAfterFrame(context, '/dashboard');
    }
  }

  Future<void> _resendOtp() async {
    await _rm.submitResendOtp(_emailCtrl.text.trim().toLowerCase());
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

        return AnimatedBuilder(
          animation: Listenable.merge([
            _rm.loading,
            _rm.inlineError,
            _rm.obscurePassword,
            _rm.step,
            _rm.cooldownLeft,
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
                        child: _rm.step.value == SignupStep.info
                            ? _buildInfoCard()
                            : _buildOtpCard(),
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

  Widget _buildInfoCard() {
    final s = widget.manager.renovilyTranslation;

    return Column(
      key: const ValueKey('signup_info_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          s.createAccount,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.step1of2Info,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 12),
        StepsBar(steps: 2, activeIndex: 0, loading: _rm.loading.value),
        const SizedBox(height: 12),
        _buildInfoForm(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildOtpCard() {
    final s = widget.manager.renovilyTranslation;

    return Column(
      key: const ValueKey('signup_otp_card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          s.accountVerification,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.step2of2Otp,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        const SizedBox(height: 12),
        StepsBar(steps: 2, activeIndex: 1, loading: _rm.loading.value),
        const SizedBox(height: 12),
        _buildOtpForm(),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _rm.loading.value
              ? null
              : () {
            _rm.goToInfoStep();
            _rm.clearError();
            _rm.stopCooldown();
            _otpCtrl.clear();

            WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _ensureVisible(_firstNameFieldKey),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: Text(
            s.editMyInfo,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoForm() {
    final s = widget.manager.renovilyTranslation;

    final String? communeValue =
    (_commune != null && _communesFR.contains(_commune)) ? _commune : null;

    return Form(
      key: _infoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassInputField(
            key: _firstNameFieldKey,
            controller: _firstNameCtrl,
            label: s.firstName,
            hint: null,
            icon: Icons.person_outline,
            onTap: () => _ensureVisible(_firstNameFieldKey),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ\s'-]"),
              ),
            ],
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return s.firstNameRequired;
              if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' \-]{1,30}$").hasMatch(t)) {
                return s.firstNameInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          GlassInputField(
            key: _lastNameFieldKey,
            controller: _lastNameCtrl,
            label: s.lastName,
            hint: null,
            icon: Icons.person,
            onTap: () => _ensureVisible(_lastNameFieldKey),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ\s'-]"),
              ),
            ],
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return s.lastNameRequired;
              if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' \-]{1,30}$").hasMatch(t)) {
                return s.lastNameInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          GlassInputField(
            key: _emailFieldKey,
            controller: _emailCtrl,
            label: s.email,
            hint: s.emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onTap: () => _ensureVisible(_emailFieldKey),
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            validator: (v) => emailValidator(
              widget.manager,
              v,
              msgRequired: s.emailRequired,
              msgInvalid: s.emailInvalid,
            ),
          ),
          const SizedBox(height: 12),
          GlassInputField(
            key: _passFieldKey,
            controller: _passCtrl,
            label: s.password,
            hint: s.passwordHint,
            icon: Icons.lock_outline,
            obscureText: _rm.obscurePassword.value,
            onTap: () => _ensureVisible(_passFieldKey),
            validator: (v) => passwordValidator(
              widget.manager,
              v,
              min: 8,
              msgRequired: s.passwordRequired,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _rm.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: _rm.loading.value ? null : _rm.toggleObscurePassword,
              tooltip: s.showHidePassword,
            ),
          ),
          const SizedBox(height: 12),
          GlassInputField(
            key: _numberFieldKey,
            controller: _numberCtrl,
            label: s.phoneNumber,
            hint: s.phoneHint,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onTap: () => _ensureVisible(_numberFieldKey),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            validator: (v) => phoneFrValidator(widget.manager, v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassDropdownField<String>(
                  key: _wilayaFieldKey,
                  label: s.wilaya,
                  value: _wilaya,
                  hint: null,
                  icon: Icons.location_on_outlined,
                  items: _wilayasFR
                      .map(
                        (w) => DropdownMenuItem<String>(
                      value: w,
                      child: Text(
                        w,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: _rm.loading.value
                      ? null
                      : (v) => v == null ? null : _onWilayaChanged(v),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? s.selectWilayaCommune
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassDropdownField<String>(
                  key: ValueKey('commune_${_wilaya ?? ''}'),
                  label: s.commune,
                  value: communeValue,
                  hint: null,
                  icon: Icons.place_outlined,
                  items: _communesFR
                      .map(
                        (c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(
                        c,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: _rm.loading.value
                      ? null
                      : (v) => setState(() => _commune = v),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? s.selectWilayaCommune
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            value: _hasReferral,
            onChanged: _rm.loading.value
                ? null
                : (v) {
              setState(() {
                _hasReferral = v;
                if (!_hasReferral) _refCtrl.clear();
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_hasReferral) _ensureVisible(_refFieldKey);
              });
            },
            activeColor: Colors.white,
            title: Text(
              s.hasReferralCode,
              style: const TextStyle(color: Colors.white),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          if (_hasReferral) ...[
            const SizedBox(height: 12),
            GlassInputField(
              key: _refFieldKey,
              controller: _refCtrl,
              label: s.referralCode,
              hint: s.referralCodeHint,
              icon: Icons.card_giftcard_outlined,
              keyboardType: TextInputType.text,
              onTap: () => _ensureVisible(_refFieldKey),
              inputFormatters: [
                UpperCaseTextFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-]')),
              ],
              maxLength: 20,
              validator: (v) {
                if (!_hasReferral) return null;
                final t = (v ?? '').trim().toUpperCase();
                if (t.isEmpty) return s.referralCodeRequired;
                if (!RegExp(r'^[A-Z0-9\-]{4,20}$').hasMatch(t)) {
                  return s.referralCodeInvalid;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.white,
            ),
            child: CheckboxListTile(
              value: _agreeCGU,
              onChanged: _rm.loading.value
                  ? null
                  : (v) => setState(() => _agreeCGU = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              checkColor: Colors.black,
              activeColor: Colors.white,
              title: Text(
                s.acceptCGU,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_rm.inlineError.value != null) ...[
            ErrorBanner(
              message: _rm.inlineError.value!,
              onClose: _rm.clearError,
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _rm.loading.value ? null : _signupRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _rm.loading.value
                  ? _btnLoader()
                  : Text(
                s.createMyAccount,
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

  Widget _buildOtpForm() {
    final s = widget.manager.renovilyTranslation;

    return Form(
      key: _otpKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.codeSentTo(_emailCtrl.text.trim().toLowerCase()),
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
              UpperCaseTextFormatter(),
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            ],
            maxLength: 6,
            validator: (v) =>
                otpValidator(widget.manager, v, len: 6, msg: s.codeInvalid),
          ),
          const SizedBox(height: 12),
          if (_rm.inlineError.value != null) ...[
            ErrorBanner(
              message: _rm.inlineError.value!,
              onClose: _rm.clearError,
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _rm.loading.value ? null : _signupVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _rm.loading.value
                  ? _btnLoader()
                  : Text(
                s.validate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: (_rm.loading.value || _rm.cooldownLeft.value > 0)
                ? null
                : _resendOtp,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              _rm.cooldownLeft.value > 0
                  ? s.resendIn(_rm.cooldownLeft.value)
                  : s.resendCode,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}