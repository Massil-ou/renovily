import 'dart:ui';
import 'package:flutter/material.dart';
import '../App/Manager.dart';
import '../Auth/Shared/auth_scaffold.dart';
import '../Auth/Shared/nav.dart';
import '../App/AppLanguage.dart';
import '../Dashboard/LanguageService.dart';

class TermsView extends StatefulWidget {
  final Manager manager;
  const TermsView({super.key, required this.manager});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
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
            title: 'Winycar',
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
              s.termsTitle,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.termsLastUpdate,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),

            _GlassCard(child: SelectionArea(child: _termsBody(s))),

            const SizedBox(height: 12),

            _GlassCard(
              child: isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _mobileActionButton(
                    icon: Icons.support_agent_outlined,
                    label: s.chipSupport,
                    onTap: () => goNamedAfterFrame(context, 'support'),
                  ),
                  const SizedBox(height: 10),
                  _mobileActionButton(
                    icon: Icons.privacy_tip_outlined,
                    label: s.chipPrivacy,
                    onTap: () => goNamedAfterFrame(context, 'privacy'),
                  ),
                ],
              )
                  : Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _pillButton(
                    icon: Icons.support_agent_outlined,
                    label: s.chipSupport,
                    onTap: () => goNamedAfterFrame(context, 'support'),
                  ),
                  _pillButton(
                    icon: Icons.privacy_tip_outlined,
                    label: s.chipPrivacy,
                    onTap: () => goNamedAfterFrame(context, 'privacy'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsBody(WinyCar s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _p(s.termsIntro),

        _sectionTitle(s.termsS1Title),
        _p(s.termsS1Body),

        _sectionTitle(s.termsS2Title),
        _bullet(s.termsS2B1),
        _bullet(s.termsS2B2),
        _bullet(s.termsS2B3),
        _bullet(s.termsS2B4),

        _sectionTitle(s.termsS3Title),
        _bullet(s.termsS3B1),
        _bullet(s.termsS3B2),
        _bullet(s.termsS3B3),

        _sectionTitle(s.termsS4Title),
        _p(s.termsS4Body),

        _sectionTitle(s.termsS5Title),
        _bullet(s.termsS5B1),
        _bullet(s.termsS5B2),
        _bullet(s.termsS5B3),
        _bullet(s.termsS5B4),

        _sectionTitle(s.termsS6Title),
        _p(s.termsS6Body),

        _sectionTitle(s.termsS7Title),
        _p(s.termsS7Body),

        _sectionTitle(s.termsS8Title),
        _p(s.termsS8Body),

        _sectionTitle(s.termsS9Title),
        _p(s.termsS9Body),

        _sectionTitle(s.termsS10Title),
        _p(s.termsS10Body),
        _bullet(s.termsContactEmail),
        _bullet(s.termsContactSupport),

        _sectionTitle(s.termsS11Title),
        _p(s.termsS11Body),

        _sectionTitle(s.termsS12Title),
        _p(s.termsS12Body),

        _sectionTitle(s.termsS13Title),
        _p(s.termsS13Body),

        _sectionTitle(s.termsS14Title),
        _p(s.termsS14Body),
      ],
    );
  }

  // ---------------- Helpers ----------------

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

/* ------------------------------ GLASS CARD ------------------------------ */

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