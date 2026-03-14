import 'dart:ui';
import 'package:flutter/material.dart';


import '../App/BaseResponse.dart';
import '../App/HelperService.dart';
import '../App/Manager.dart';

import '../Auth/Shared/auth_scaffold.dart';
import '../Auth/Shared/nav.dart';
import '../App/AppLanguage.dart';
import '../Dashboard/LanguageService.dart';

class PrivacyPolicyView extends StatefulWidget {
  final Manager manager;
  const PrivacyPolicyView({super.key, required this.manager});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.manager.languageService.language,
      builder: (_, __, ___) {
        final WinyCar s = widget.manager.winyCarTranslation;

        final isMobile = true;

        final topGap = MediaQuery.of(context).padding.top + kToolbarHeight;
        final double sidePad = isMobile ? 6 : 16;

        return WillPopScope(
          onWillPop: () async {
            goNamedAfterFrame(context, 'dashboard');
            return false;
          },
          child: AuthScaffold(
            manager: widget.manager,
            title: 'WinyCar',
            padding: EdgeInsets.fromLTRB(sidePad, topGap, sidePad, 24),
            child: Directionality(
              textDirection: widget.manager.languageService.textDirection,
              child: _content(s, isMobile: isMobile),
            ),
          ),
        );
      },
    );
  }

  Widget _content(WinyCar s, {required bool isMobile}) {
    return Scrollbar(
      controller: _scrollCtrl,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.privacyTitle,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.privacyLastUpdate,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),

            _GlassCard(child: SelectionArea(child: _privacyBody(s))),

            const SizedBox(height: 12),

            _GlassCard(
              child: isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _mobileActionButton(
                    icon: Icons.rule_outlined,
                    label: s.terms,
                    onTap: () => goNamedAfterFrame(context, 'terms'),
                  ),
                  const SizedBox(height: 10),
                  _mobileActionButton(
                    icon: Icons.support_agent_outlined,
                    label: s.support,
                    onTap: () => goNamedAfterFrame(context, 'support'),
                  ),
                ],
              )
                  : Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _pillButton(
                    icon: Icons.rule_outlined,
                    label: s.terms,
                    onTap: () => goNamedAfterFrame(context, 'terms'),
                  ),
                  _pillButton(
                    icon: Icons.support_agent_outlined,
                    label: s.support,
                    onTap: () => goNamedAfterFrame(context, 'support'),
                  ),
                  // ✅ SUPPRIMÉ : bouton Accueil/Home
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyBody(WinyCar s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _p(s.privacyIntro),

        _sectionTitle(s.privacySection1Title),
        _bullet(s.privacySection1Bullet1),
        _bullet(s.privacySection1Bullet2),
        _bullet(s.privacySection1Bullet3),
        _bullet(s.privacySection1Bullet4),

        _sectionTitle(s.privacySection2Title),
        _bullet(s.privacySection2Bullet1),
        _bullet(s.privacySection2Bullet2),
        _bullet(s.privacySection2Bullet3),
        _bullet(s.privacySection2Bullet4),

        _sectionTitle(s.privacySection3Title),
        _p(s.privacySection3Intro),
        _bullet(s.privacySection3Bullet1),
        _bullet(s.privacySection3Bullet2),
        _bullet(s.privacySection3Bullet3),

        _sectionTitle(s.privacySection4Title),
        _p(s.privacySection4Body),

        _sectionTitle(s.privacySection5Title),
        _p(s.privacySection5Body),

        _sectionTitle(s.privacySection6Title),
        _bullet(s.privacySection6Bullet1),
        _bullet(s.privacySection6Bullet2),
        _bullet(s.privacySection6Bullet3),

        _sectionTitle(s.privacySection7Title),
        _p(s.privacySection7Body),

        _sectionTitle(s.privacySection8Title),
        _p(s.privacySection8Body),

        _sectionTitle(s.privacySection9Title),
        _p(s.privacySection9Body),

        _sectionTitle(s.privacySection10Title),
        _p(s.privacySection10Body),

        _sectionTitle(s.privacySection11Title),
        _p(s.privacySection11Body),

        _sectionTitle(s.privacySection12Title),
        _p(s.privacySection12Body),

        _sectionTitle(s.privacySection13Title),
        _p(s.privacySection13Body),

        _sectionTitle(s.privacySection14Title),
        _p(s.privacySection14Body),

        _bullet(s.privacyContactEmail),
        _bullet(s.privacyContactSupport),
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Text(
      t,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _p(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: Colors.white.withOpacity(0.92),
        height: 1.35,
        fontSize: 14,
      ),
    ),
  );

  Widget _bullet(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            t,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              height: 1.35,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '•',
          style: TextStyle(
            color: Colors.white.withOpacity(0.92),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _mobileActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.08),
          side: BorderSide(color: Colors.white.withOpacity(0.25)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}