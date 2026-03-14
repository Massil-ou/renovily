import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../App/AppLanguage.dart';
import '../../App/Manager.dart';
import '../LanguageService.dart';
import '../PartnerClient/ClientProfileView.dart';
import '../PartnerProfile/PartnerProfileView.dart';

enum PartnerSettingsSection { clientProfile, profile }

class PartnerSettingsView extends StatefulWidget {
  final Manager manager;
  const PartnerSettingsView({super.key, required this.manager});

  @override
  State<PartnerSettingsView> createState() => _PartnerSettingsViewState();
}

class _PartnerSettingsViewState extends State<PartnerSettingsView> {
  PartnerSettingsSection _section = PartnerSettingsSection.clientProfile;

  int get _index {
    switch (_section) {
      case PartnerSettingsSection.clientProfile:
        return 0;
      case PartnerSettingsSection.profile:
        return 1;
    }
  }

  void _set(PartnerSettingsSection s) {
    if (_section == s) return;
    setState(() => _section = s);
  }

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        const Positioned.fill(child: _SettingsBackground()),
        Padding(
          padding: EdgeInsets.fromLTRB(6, topGap, 6, 12),
          child: Column(
            children: [
              ValueListenableBuilder<AppLanguage>(
                valueListenable: widget.manager.languageService.language,
                builder: (_, __, ___) {
                  final s = widget.manager.winyCarTranslation;
                  return _SettingsSwitchBar(
                    selected: _section,
                    labelClient: 'Profile client',
                    labelProfile: s.proProfileTitle,
                    onClient: () => _set(PartnerSettingsSection.clientProfile),
                    onProfile: () => _set(PartnerSettingsSection.profile),
                  );
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                      ),
                      child: IndexedStack(
                        index: _index,
                        children: [
                          ClientProfileView(manager: widget.manager),
                          PartnerProfileView(manager: widget.manager),
                        ],
                      ),
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
}

class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Image.asset(
        'assets/images/back.png',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}

class _SettingsSwitchBar extends StatelessWidget {
  final PartnerSettingsSection selected;
  final String labelClient;
  final String labelProfile;
  final VoidCallback onClient;
  final VoidCallback onProfile;

  const _SettingsSwitchBar({
    required this.selected,
    required this.labelClient,
    required this.labelProfile,
    required this.onClient,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ModeBtn(
                  selected: selected == PartnerSettingsSection.clientProfile,
                  label: labelClient,
                  icon: Icons.person_outline,
                  onTap: onClient,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ModeBtn(
                  selected: selected == PartnerSettingsSection.profile,
                  label: labelProfile,
                  icon: Icons.business_center_outlined,
                  onTap: onProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeBtn({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white.withOpacity(0.22) : Colors.transparent;
    final border = selected
        ? Colors.white.withOpacity(0.55)
        : Colors.white.withOpacity(0.18);
    final txt = selected ? Colors.white : Colors.white.withOpacity(0.85);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 0.9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: txt),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: txt,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}