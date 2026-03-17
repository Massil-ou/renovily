import 'dart:ui';

import 'package:flutter/material.dart';
import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';
import '../OfferDetail/OfferDetailView.dart';
import '../OfferSetting/OfferSettingView.dart';
import 'FavorisDarekManager.dart';

class FavorisOffersView extends StatefulWidget {
  final Manager manager;

  const FavorisOffersView({
    super.key,
    required this.manager,
  });

  @override
  State<FavorisOffersView> createState() => _FavorisOffersViewState();
}

class _FavorisOffersViewState extends State<FavorisOffersView> {
  late final FavorisOffersManager m = widget.manager.favorisAnnoncesManager;

  @override
  void initState() {
    super.initState();
    m.addListener(_listener);
    m.load();
  }

  void _listener() {
    if (!mounted) return;

    setState(() {});

    final s = widget.manager.renovilyTranslation;

    if (m.lastError != null) {
      final err = m.lastError!;
      m.lastError = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showGlassDialog(
          title: s.error,
          message: _mapErrorMessage(err),
          icon: Icons.error_outline,
          iconBg: const Color(0xFFFFE5E5),
          iconColor: Colors.redAccent,
        );
      });
    }
  }

  @override
  void dispose() {
    m.removeListener(_listener);
    super.dispose();
  }

  String _mapErrorMessage(String code) {
    final s = widget.manager.renovilyTranslation;

    switch (code) {
      case 'add_failed':
        return s.addFavoriteFailed;
      case 'delete_failed':
        return s.removeFavoriteFailed;
      case 'exception':
        return s.serverCommunicationError;
      default:
        return code;
    }
  }

  Future<void> _showGlassDialog({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    Color iconBg = const Color(0xFFEAF3FF),
    Color iconColor = Colors.blueAccent,
  }) async {
    final s = widget.manager.renovilyTranslation;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _GlassInfoDialog(
        title: title,
        message: message,
        okText: s.ok,
        icon: icon,
        iconBg: iconBg,
        iconColor: iconColor,
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _DeleteFavoriDialog(
        manager: widget.manager,
      ),
    );

    return result == true;
  }

  String _price(OfferModel a) {
    final s = widget.manager.renovilyTranslation;

    if (a.prix == null) return s.priceNegotiable;
    final unit = (a.unitePrix?.value ?? '').trim();
    if (unit.isEmpty) return "${a.prix!.toStringAsFixed(0)} DA";
    return "${a.prix!.toStringAsFixed(0)} DA / $unit";
  }

  String _subtitle(OfferModel a) {
    final s = widget.manager.renovilyTranslation;

    final parts = <String>[
      if (a.metier.trim().isNotEmpty) a.metier.trim(),
      if (a.wilaya.trim().isNotEmpty) a.wilaya.trim(),
      if (a.commune.trim().isNotEmpty) a.commune.trim(),
    ];
    return parts.isEmpty ? s.notAvailableShort : parts.join(' • ');
  }

  Future<void> _deleteFavori(OfferModel item) async {
    final confirm = await _showDeleteConfirmDialog();
    if (!confirm) return;

    await m.delete(item.id);
  }

  void _openDetails(OfferModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfferDetailView(
          manager: widget.manager,
          item: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.manager.renovilyTranslation;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        PageHeader(
          title: s.favorites,
          subtitle: s.savedOffersSubtitle,
        ),
        if (m.isLoading)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (m.favoris.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: _EmptyFavorisCard(),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 14, 6, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: List.generate(m.favoris.length, (index) {
                      final a = m.favoris[index];

                      return Column(
                        children: [
                          AnnonceCardItem(
                            imageUrl:
                            a.images.isNotEmpty ? a.images.first.url : null,
                            title: a.titre,
                            subtitle: _subtitle(a),
                            price: _price(a),
                            onTap: () => _openDetails(a),
                            onDelete: () => _deleteFavori(a),
                          ),
                          if (index != m.favoris.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.white.withOpacity(0.14),
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AnnonceCardItem extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AnnonceCardItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _AnnonceImage(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 10),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnonceImage extends StatelessWidget {
  final String? imageUrl;

  const _AnnonceImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        height: 52,
        color: Colors.white.withOpacity(0.12),
        child: url.isEmpty
            ? const Icon(
          Icons.construction_outlined,
          color: Colors.white,
          size: 26,
        )
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorisCard extends StatelessWidget {
  const _EmptyFavorisCard();

  @override
  Widget build(BuildContext context) {
    final s = (context.findAncestorStateOfType<_FavorisOffersViewState>()!)
        .widget
        .manager
        .renovilyTranslation;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                s.noFavorites,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.savedOffersAppearHere,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteFavoriDialog extends StatelessWidget {
  final Manager manager;

  const _DeleteFavoriDialog({
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final s = manager.renovilyTranslation;

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
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE5E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.removeFromFavorites,
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
                  s.confirmRemoveFavorite,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.15),
                          ),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassInfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String okText;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _GlassInfoDialog({
    required this.title,
    required this.message,
    required this.okText,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
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
                        color: iconBg,
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(okText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}