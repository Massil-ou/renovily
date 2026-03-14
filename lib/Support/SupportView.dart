// lib/Support/SupportView.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../App/AppLanguage.dart';
import '../App/Manager.dart';
import '../Auth/Shared/auth_scaffold.dart';
import '../Auth/Shared/banners.dart';
import '../Auth/Shared/nav.dart';
import '../Auth/Shared/validators.dart';
import '../Dashboard/LanguageService.dart';

class SupportView extends StatefulWidget {
  final Manager manager;
  const SupportView({super.key, required this.manager});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final _formKey = GlobalKey<FormState>();

  final _scrollCtrl = ScrollController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  bool _loading = false;
  String? _inlineError;

  static const String _supportEmail = 'renovily.contact@gmail.com';
  static const String _supportUrl = 'https://renovily.com/support';

  void _setError(String msg) {
    if (!mounted) return;
    setState(() => _inlineError = msg);
  }

  void _clearError() {
    if (!mounted) return;
    setState(() => _inlineError = null);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.redAccent,
  }) async {
    final s = widget.manager.winyCarTranslation;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.92),
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.9),
                  width: 0.8,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.ok),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launch(Uri uri, WinyCar s) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        final msg = s.supportOpenFail.replaceAll('{url}', uri.toString());
        _setError(msg);
        await _showInfoDialog(
          title: s.supportTitle,
          message: msg,
          icon: Icons.public_off,
          iconColor: Colors.redAccent,
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      _setError(msg);
      await _showInfoDialog(
        title: s.supportTitle,
        message: msg,
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
    }
  }

  Future<void> _sendEmail(WinyCar s) async {
    final subject = Uri.encodeComponent(s.supportMailSubject);
    final body = Uri.encodeComponent(
      "Bonjour,\n\n"
          "Nom: ${_nameCtrl.text.trim()}\n"
          "Email: ${_emailCtrl.text.trim()}\n\n"
          "Message:\n${_msgCtrl.text.trim()}\n",
    );

    final uri = Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');
    await _launch(uri, s);
  }

  Future<void> _openSupportWebsite(WinyCar s) async {
    await _launch(Uri.parse(_supportUrl), s);
  }

  Future<void> _submitForm(WinyCar s) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _clearError();
    setState(() => _loading = true);

    try {
      await _sendEmail(s);
      if (!mounted) return;

      await _showInfoDialog(
        title: s.supportTitle,
        message: s.supportSnackEmailReady,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      _setError(msg);

      await _showInfoDialog(
        title: s.supportTitle,
        message: msg,
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader(WinyCar s) {
    return _glassContainer(
      child: Row(
        children: [
          Expanded(
            child: Text(
              s.supportTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          Icon(
            Icons.support_agent,
            color: Colors.white.withOpacity(0.95),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(WinyCar s) {
    return _glassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.supportSubtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.supportInfoTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            _supportEmail,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _loading ? null : () => _sendEmail(s),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.email_outlined),
              label: Text(
                s.supportSendEmail,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(WinyCar s) {
    return _glassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(
              _nameCtrl,
              s.supportNameLabel,
              hint: s.supportNameHint,
              enabled: !_loading,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? s.supportNameRequired : null,
            ),
            const SizedBox(height: 12),
            _field(
              _emailCtrl,
              s.supportEmailLabel,
              hint: s.supportEmailHint,
              enabled: !_loading,
              keyboard: TextInputType.emailAddress,
              formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              validator: (v) => emailValidator(
                widget.manager,
                v,
                msgRequired: s.supportEmailRequired,
                msgInvalid: s.supportEmailInvalid,
              ),
            ),
            const SizedBox(height: 12),
            _field(
              _msgCtrl,
              s.supportMessageLabel,
              hint: s.supportMessageHint,
              enabled: !_loading,
              keyboard: TextInputType.multiline,
              minLines: 7,
              maxLines: 10,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? s.supportMessageRequired
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(WinyCar s, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _loading ? null : () => _submitForm(s),
            child: _loading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
            )
                : Text(
              s.supportPrepareEmail,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_inlineError != null) ...[
          ErrorBanner(message: _inlineError!, onClose: _clearError),
          const SizedBox(height: 12),
        ],
        if (isMobile) ...[
          _secondaryButton(
            icon: Icons.public,
            label: s.supportChipWebsite,
            onTap: () => _openSupportWebsite(s),
          ),
          const SizedBox(height: 10),
          _secondaryButton(
            icon: Icons.rule_outlined,
            label: s.supportChipTerms,
            onTap: () => goNamedAfterFrame(context, 'terms'),
          ),
          const SizedBox(height: 10),
          _secondaryButton(
            icon: Icons.privacy_tip_outlined,
            label: s.supportChipPrivacy,
            onTap: () => goNamedAfterFrame(context, 'privacy'),
          ),
        ] else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionChip(
                icon: Icons.public,
                label: s.supportChipWebsite,
                onTap: () => _openSupportWebsite(s),
              ),
              _actionChip(
                icon: Icons.rule_outlined,
                label: s.supportChipTerms,
                onTap: () => goNamedAfterFrame(context, 'terms'),
              ),
              _actionChip(
                icon: Icons.privacy_tip_outlined,
                label: s.supportChipPrivacy,
                onTap: () => goNamedAfterFrame(context, 'privacy'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _loading ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        String? hint,
        bool enabled = true,
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
        int minLines = 1,
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboard,
      inputFormatters: formatters,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        errorStyle: const TextStyle(fontSize: 12),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.4),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.18),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.only(bottom: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.manager.languageService.language,
      builder: (_, __, ___) {
        final s = widget.manager.winyCarTranslation;
        final isMobile = widget.manager.globalSingleton.isMobile(context);
        final topGap =
            MediaQuery.of(context).padding.top + kToolbarHeight + (isMobile ? 16 : 24);
        final sidePad = isMobile ? 6.0 : 16.0;

        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).maybePop();
            return false;
          },
          child: AuthScaffold(
            manager: widget.manager,
            title: 'WinyCar',
            padding: EdgeInsets.fromLTRB(sidePad, topGap, sidePad, 24),
            child: Directionality(
              textDirection: widget.manager.languageService.textDirection,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(0),
                    children: [
                      _buildHeader(s),
                      const SizedBox(height: 12),
                      _buildIntro(s),
                      const SizedBox(height: 12),
                      _buildForm(s),
                      const SizedBox(height: 16),
                      _buildActions(s, isMobile: isMobile),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}