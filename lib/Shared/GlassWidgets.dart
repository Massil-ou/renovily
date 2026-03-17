import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../App/Manager.dart';
import '../Dashboard/LanguageService.dart';


class GlassTitlePill extends StatelessWidget {
  final String text;
  const GlassTitlePill({super.key, required this.text});

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

class GlassCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const GlassCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final content = Container(
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
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );

    // iOS: éviter Tooltip overlay si tu veux ultra stable
    if (_isIOS) return content;

    return Tooltip(message: tooltip ?? '', child: content);
  }
}

class GlassCircleLanguageButton extends StatelessWidget {
  final Manager manager;
  final String? tooltip;

  const GlassCircleLanguageButton({
    super.key,
    required this.manager,
    this.tooltip,
  });

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  String _short(AppLanguage l) {
    switch (l) {
      case AppLanguage.fr:
        return 'FR';
      case AppLanguage.ar:
        return 'AR';
      case AppLanguage.en:
      default:
        return 'EN';
    }
  }

  String _label(AppLanguage l) {
    switch (l) {
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.ar:
      default:
        return 'العربية';
    }
  }

  Future<void> _openLanguageDialog(
    BuildContext context,
    AppLanguage current,
  ) async {
    // ✅ Trick iOS: attendre la fin du tap (sinon tap-up tombe sur la barrière)
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!context.mounted) return;

    final selected = await showDialog<AppLanguage>(
      context: context,
      barrierDismissible: false, // ✅ évite fermeture instant
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        final maxW = mq.size.width >= 600 ? 520.0 : double.infinity;

        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
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
                              color: Colors.blueAccent.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.language,
                              color: Colors.blueAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (tooltip?.trim().isNotEmpty ?? false)
                                  ? tooltip!.trim()
                                  : 'Language',
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
                        'Choisissez votre langue',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _LangChoiceTile(
                        code: 'FR',
                        label: _label(AppLanguage.fr),
                        selected: current == AppLanguage.fr,
                        onTap: () => Navigator.pop(ctx, AppLanguage.fr),
                      ),
                      const SizedBox(height: 8),
                      _LangChoiceTile(
                        code: 'AR',
                        label: _label(AppLanguage.ar),
                        selected: current == AppLanguage.ar,
                        onTap: () => Navigator.pop(ctx, AppLanguage.ar),
                      ),
                      const SizedBox(height: 8),
                      _LangChoiceTile(
                        code: 'EN',
                        label: _label(AppLanguage.en),
                        selected: current == AppLanguage.en,
                        onTap: () => Navigator.pop(ctx, AppLanguage.en),
                      ),

                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.15),
                            ),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selected != null && selected != current) {
      manager.languageService.setLanguage(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: manager.languageService.language,
      builder: (_, lang, __) {
        final button = SizedBox(
          height: 38,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => _openLanguageDialog(context, lang),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.38),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.32),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _short(lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // iOS: évite Tooltip overlay pour stabilité
        if (_isIOS) return button;

        return Tooltip(message: tooltip ?? '', child: button);
      },
    );
  }
}

/// Tile de choix (style “favoris dialog”)
class _LangChoiceTile extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChoiceTile({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Colors.green.withOpacity(0.45)
        : Colors.black.withOpacity(0.12);
    final bg = selected ? Colors.green.withOpacity(0.08) : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
