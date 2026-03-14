// lib/Auth/Shared/auth_scaffold.dart
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/AppLanguage.dart';
import '../../App/Manager.dart';
import '../../Dashboard/LanguageService.dart';
import '../../Shared/GlassWidgets.dart';

class AuthScaffold extends StatelessWidget {
  final Manager manager;
  final String title;
  final Widget child;
  final EdgeInsets? padding;

  const AuthScaffold({
    super.key,
    required this.manager,
    required this.title,
    required this.child,
    this.padding,
  });

  Future<bool> _handleWillPop(BuildContext context) async {
    if (kIsWeb) return true;
    if (Navigator.of(context).canPop()) return true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/');
    });
    return false;
  }

  void _handleBackTap(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final statusBar = mq.padding.top;
    final double appBarTop = statusBar + 8;

    // Padding “contenu” sous l’appbar glass
    final double contentTopPadding = statusBar + kToolbarHeight + 32;
    final effectivePadding =
        padding ?? EdgeInsets.fromLTRB(16, contentTopPadding, 16, 24);

    // Hauteur clavier
    final keyboardBottom = mq.viewInsets.bottom;

    return WillPopScope(
      onWillPop: () => _handleWillPop(context),
      child: Scaffold(
        // ✅ on garde false et on gère le clavier via AnimatedPadding
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/backs.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              Container(color: Colors.black.withOpacity(0.35)),

              // ✅ Le scroll + padding clavier (sans “remonter trop”)
              AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: keyboardBottom),
                child: SingleChildScrollView(
                  padding: effectivePadding,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  child: Align(
                    alignment: Alignment
                        .topCenter, // ✅ important (évite les effets Center)
                    child: child,
                  ),
                ),
              ),

              Positioned(
                top: appBarTop,
                left: 16,
                right: 16,
                child: ValueListenableBuilder<AppLanguage>(
                  valueListenable: manager.languageService.language,
                  builder: (_, __, ___) {
                    WinyCar s = manager.winyCarTranslation;
                    return Row(
                      children: [
                        _GlassCircleIconButton(
                          icon: Icons.arrow_back_ios_new,
                          tooltip: s.back,
                          onTap: () => _handleBackTap(context),
                        ),
                        const SizedBox(width: 8),
                        _GlassTitlePill(text: title),
                        const Spacer(),
                        GlassCircleLanguageButton(
                          manager: manager,
                          tooltip: s.language,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTitlePill extends StatelessWidget {
  final String text;
  const _GlassTitlePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.38),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 0.8,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _GlassCircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.38),
        border: Border.all(color: Colors.white.withOpacity(0.32), width: 0.8),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip ?? '',
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
