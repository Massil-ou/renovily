import 'dart:ui';
import 'package:flutter/material.dart';

import '../AddDarek/AddOffersView.dart';
import '../FavorisOffers/FavorisDarekView.dart';
import '../LanguageService.dart';
import '../ListDarek/ListDarekView.dart';
import '../../App/Manager.dart';

enum AnnonceSettingsSection {
  mesAnnonces,
  ajouter,
  favoris,
}

class AnnonceSettingView extends StatefulWidget {
  final Manager manager;

  const AnnonceSettingView({
    super.key,
    required this.manager,
  });

  @override
  State<AnnonceSettingView> createState() => _AnnonceSettingViewState();
}

class _AnnonceSettingViewState extends State<AnnonceSettingView> {
  AnnonceSettingsSection _section = AnnonceSettingsSection.mesAnnonces;

  int get _index {
    switch (_section) {
      case AnnonceSettingsSection.mesAnnonces:
        return 0;
      case AnnonceSettingsSection.ajouter:
        return 1;
      case AnnonceSettingsSection.favoris:
        return 2;
    }
  }

  void _set(AnnonceSettingsSection s) {
    if (_section == s) return;
    setState(() => _section = s);
  }

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        const Positioned.fill(child: _AnnonceBackground()),
        Padding(
          padding: EdgeInsets.fromLTRB(6, topGap, 6, 12),
          child: Column(
            children: [
              ValueListenableBuilder<AppLanguage>(
                valueListenable: widget.manager.languageService.language,
                builder: (_, __, ___) {
                  return _AnnonceSwitchBar(
                    selected: _section,
                    labelMesAnnonces: 'Mes annonces',
                    labelAjouter: 'Ajouter',
                    labelFavoris: 'Favoris',
                    onMesAnnonces: () => _set(AnnonceSettingsSection.mesAnnonces),
                    onAjouter: () => _set(AnnonceSettingsSection.ajouter),
                    onFavoris: () => _set(AnnonceSettingsSection.favoris),
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
                          MesAnnoncesPage(manager: widget.manager),
                          AddOffersView(manager: widget.manager),
                          FavorisOffersView(manager: widget.manager),
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

class _AnnonceBackground extends StatelessWidget {
  const _AnnonceBackground();

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

class _AnnonceSwitchBar extends StatelessWidget {
  final AnnonceSettingsSection selected;
  final String labelMesAnnonces;
  final String labelAjouter;
  final String labelFavoris;
  final VoidCallback onMesAnnonces;
  final VoidCallback onAjouter;
  final VoidCallback onFavoris;

  const _AnnonceSwitchBar({
    required this.selected,
    required this.labelMesAnnonces,
    required this.labelAjouter,
    required this.labelFavoris,
    required this.onMesAnnonces,
    required this.onAjouter,
    required this.onFavoris,
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
                  selected: selected == AnnonceSettingsSection.mesAnnonces,
                  label: labelMesAnnonces,
                  icon: Icons.list_alt_outlined,
                  onTap: onMesAnnonces,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ModeBtn(
                  selected: selected == AnnonceSettingsSection.ajouter,
                  label: labelAjouter,
                  icon: Icons.add_box_outlined,
                  onTap: onAjouter,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ModeBtn(
                  selected: selected == AnnonceSettingsSection.favoris,
                  label: labelFavoris,
                  icon: Icons.favorite_border,
                  onTap: onFavoris,
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

class GlassSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const GlassSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(16),
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
