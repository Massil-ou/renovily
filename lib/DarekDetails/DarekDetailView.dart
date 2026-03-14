import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Darek/DarekModel.dart';
import '../../Shared/GlassWidgets.dart';
import '../App/Manager.dart';
import '../Dashboard/LanguageService.dart';
import '../HorizontalDarek/HorizontalDarek.dart';

class DarekDetailView extends StatefulWidget {
  final OfferModel? item;
  final String? itemId;
  final Manager manager;

  const DarekDetailView({
    super.key,
    this.item,
    this.itemId,
    required this.manager,
  });

  @override
  State<DarekDetailView> createState() => _DarekDetailViewState();
}

class _DarekDetailViewState extends State<DarekDetailView> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  OfferModel? _current;
  bool _loading = false;
  String? _inlineError;
  int _page = 0;

  bool _showFullDescription = false;
  bool _showAllAvis = false;
  bool _isFavorite = false;
  bool _isReviewActionLoading = false;

  bool get _isDesktopLike {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  bool get _isAuthenticated => widget.manager.isAuthenticated;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final provided = widget.item;
    if (provided != null) {
      _current = provided;
      await _initFavoriteState(provided.id);
      if (mounted) setState(() {});
      return;
    }

    await _fetchIfNeeded();
  }

  Future<void> _initFavoriteState(String offerId) async {
    try {
      final local = widget.manager.favorisAnnoncesManager.isFavoriLocal(offerId);
      if (local) {
        _isFavorite = true;
        return;
      }

      final remote = await widget.manager.favorisAnnoncesManager.isFavori(offerId);
      _isFavorite = remote;
    } catch (_) {
      _isFavorite = widget.manager.favorisAnnoncesManager.isFavoriLocal(offerId);
    }
  }

  Future<void> _fetchIfNeeded() async {
    final id = (widget.itemId ?? '').trim();

    if (id.isEmpty) {
      setState(() {
        _inlineError = 'missing_item_id';
        _current = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _inlineError = null;
      _current = null;
    });

    try {
      final all = widget.manager.darekManager.currentList.value;
      OfferModel? found;

      for (final e in all) {
        if (e.id == id) {
          found = e;
          break;
        }
      }

      if (!mounted) return;

      if (found == null) {
        setState(() {
          _current = null;
          _inlineError = 'annonce_introuvable';
          _loading = false;
        });
        return;
      }

      await _initFavoriteState(found.id);

      setState(() {
        _current = found;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _current = null;
        _inlineError = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant DarekDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldId = oldWidget.item?.id ?? (oldWidget.itemId ?? '');
    final newId = widget.item?.id ?? (widget.itemId ?? '');

    if (oldId.trim() != newId.trim()) {
      _current = null;
      _inlineError = null;
      _loading = false;
      _page = 0;
      _showFullDescription = false;
      _showAllAvis = false;
      _isFavorite = false;
      _bootstrap();
      _scrollToTop();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  OfferModel _copyItemWithAvis(OfferModel item, List<OfferReviews> avis) {
    return OfferModel(
      id: item.id,
      titre: item.titre,
      description: item.description,
      wilaya: item.wilaya,
      commune: item.commune,
      metier: item.metier,
      isPro: item.isPro,
      namePro: item.namePro,
      status: item.status,
      experienceAnnees: item.experienceAnnees,
      prix: item.prix,
      unitePrix: item.unitePrix,
      images: item.images,
      createdAt: item.createdAt,
      avis: avis,
    );
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    context.go('/home');
  }

  void _goToLogin() {
    context.go('/login');
  }

  String _shareUrlForItem(String id) {
    return 'https://renovily.com/details/renovily/${Uri.encodeComponent(id)}';
  }

  String _shareMessageForItem(OfferModel item) {
    final parts = <String>[
      item.titre.trim(),
      if (item.metier.trim().isNotEmpty) item.metier.trim(),
      if (item.prix != null)
        '${item.prix} DA${item.unitePrix != null ? ' / ${item.unitePrix!.label}' : ''}',
      _shareUrlForItem(item.id),
    ];
    return parts.where((e) => e.trim().isNotEmpty).join('\n');
  }

  Future<void> _shareItem() async {
    final item = _current;
    if (item == null) return;

    final text = _shareMessageForItem(item);

    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        text,
        sharePositionOrigin:
        box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      await _showGlassDialog(
        message: e.toString().replaceFirst('Exception:', '').trim(),
        icon: Icons.error_outline,
        iconBg: const Color(0xFFFFE5E5),
        iconColor: Colors.redAccent,
      );
    }
  }

  Future<void> _showGlassDialog({
    required String message,
    String title = 'renovily',
    IconData icon = Icons.info_outline,
    Color iconBg = const Color(0xFFEAF3FF),
    Color iconColor = Colors.blueAccent,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _GlassInfoDialog(
        title: title,
        message: message,
        okText: 'OK',
        icon: icon,
        iconBg: iconBg,
        iconColor: iconColor,
      ),
    );
  }

  Future<bool> _showLoginRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const _LoginRequiredDialog(),
    );

    return result == true;
  }

  Future<bool> _ensureAuthenticated() async {
    if (_isAuthenticated) return true;

    final goLogin = await _showLoginRequiredDialog();
    if (!mounted) return false;

    if (goLogin) {
      _goToLogin();
    }
    return false;
  }

  Future<void> _toggleFavorite() async {
    final item = _current;
    if (item == null) return;

    final ok = await _ensureAuthenticated();
    if (!ok) return;

    final done = await widget.manager.favorisAnnoncesManager.toggle(item);

    if (!mounted) return;

    if (done) {
      final isFav =
      widget.manager.favorisAnnoncesManager.isFavoriLocal(item.id);
      setState(() {
        _isFavorite = isFav;
      });

      await _showGlassDialog(
        title: isFav ? 'Favori ajouté' : 'Favori retiré',
        message: isFav
            ? 'Cette annonce a été ajoutée à vos favoris.'
            : 'Cette annonce a été retirée de vos favoris.',
        icon: isFav ? Icons.favorite : Icons.favorite_border,
        iconBg: const Color(0xFFFFEEF3),
        iconColor: Colors.redAccent,
      );
    } else {
      await _showGlassDialog(
        title: 'Erreur',
        message: 'Impossible de modifier le favori.',
        icon: Icons.error_outline,
        iconBg: const Color(0xFFFFE5E5),
        iconColor: Colors.redAccent,
      );
    }
  }

  String? _currentUserId() {
    try {
      final dynamic raw = widget.manager.currentUser;
      final candidates = [raw?.iduser, raw?.id, raw?.uuid];
      for (final v in candidates) {
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty) return s;
        }
      }
    } catch (_) {}
    return null;
  }

  bool _isMyReview(OfferReviews avis) {
    try {
      final dynamic raw = avis;

      if (raw.isMine == true) return true;

      final currentUserId = _currentUserId();
      final reviewUserId = raw.userUuid?.toString().trim();

      if (currentUserId != null &&
          reviewUserId != null &&
          reviewUserId.isNotEmpty &&
          reviewUserId == currentUserId) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  List<OfferReviews> _sortedAvisWithMineFirst(List<OfferReviews> input) {
    final items = [...input];
    items.sort((a, b) {
      final am = _isMyReview(a) ? 1 : 0;
      final bm = _isMyReview(b) ? 1 : 0;
      if (am != bm) return bm.compareTo(am);

      final ad = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bd = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bd.compareTo(ad);
    });
    return items;
  }

  Future<void> _openAvisDialog() async {
    final item = _current;
    if (item == null) return;

    final okAuth = await _ensureAuthenticated();
    if (!okAuth) return;

    final alreadyHasMine = item.avis.any(_isMyReview);
    if (alreadyHasMine) {
      await _showGlassDialog(
        title: 'Avis déjà publié',
        message: 'Vous avez déjà publié un avis pour cette offre.',
        icon: Icons.info_outline,
      );
      return;
    }

    final result = await showDialog<_AddAvisResult>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const _AddAvisDialog(),
    );

    if (result == null || !mounted) return;

    setState(() {
      _isReviewActionLoading = true;
    });

    try {
      final created = await widget.manager.offerReviewsManager.addReview(
        idoffer: item.id,
        prenom: result.prenom,
        message: result.message,
        note: result.note,
        indiceFinition: result.indiceFinition,
      );

      if (!mounted) return;

      if (created != null) {
        final nextAvis = _sortedAvisWithMineFirst([created, ...item.avis]);

        setState(() {
          _current = _copyItemWithAvis(item, nextAvis);
        });

        await _showGlassDialog(
          title: 'Avis envoyé',
          message: 'Merci, votre avis a bien été envoyé.',
          icon: Icons.check_circle_outline,
          iconBg: const Color(0xFFE8F7EC),
          iconColor: Colors.green,
        );
      } else {
        await _showGlassDialog(
          title: 'Erreur',
          message: widget.manager.offerReviewsManager.lastError ??
              'Impossible d’envoyer votre avis.',
          icon: Icons.error_outline,
          iconBg: const Color(0xFFFFE5E5),
          iconColor: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviewActionLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMyReview(OfferReviews avis) async {
    final dynamic raw = avis;
    final String idreview = (raw.idreview ?? '').toString().trim();

    if (idreview.isEmpty) {
      await _showGlassDialog(
        title: 'Erreur',
        message: 'Identifiant de l’avis introuvable.',
        icon: Icons.error_outline,
        iconBg: const Color(0xFFFFE5E5),
        iconColor: Colors.redAccent,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const _ConfirmDeleteAvisDialog(),
    ) ??
        false;

    if (!confirmed || !mounted) return;

    setState(() {
      _isReviewActionLoading = true;
    });

    try {
      final ok = await widget.manager.offerReviewsManager.deleteReview(
        idreview: idreview,
      );

      if (!mounted) return;

      if (ok) {
        final item = _current;
        if (item != null) {
          final nextAvis = item.avis.where((e) {
            final dynamic r = e;
            return (r.idreview ?? '').toString().trim() != idreview;
          }).toList();

          setState(() {
            _current = _copyItemWithAvis(item, _sortedAvisWithMineFirst(nextAvis));
          });
        }

        await _showGlassDialog(
          title: 'Avis supprimé',
          message: 'Votre avis a bien été supprimé.',
          icon: Icons.delete_outline,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: Colors.orange,
        );
      } else {
        await _showGlassDialog(
          title: 'Erreur',
          message: widget.manager.offerReviewsManager.lastError ??
              'Impossible de supprimer votre avis.',
          icon: Icons.error_outline,
          iconBg: const Color(0xFFFFE5E5),
          iconColor: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviewActionLoading = false;
        });
      }
    }
  }

  String _priceText(OfferModel item) {
    if (item.prix == null) return 'Prix à négocier';
    return item.unitePrix != null
        ? '${item.prix} DA / ${item.unitePrix!.label}'
        : '${item.prix} DA';
  }

  String _locationText(OfferModel item) {
    final w = item.wilaya.trim();
    final c = item.commune.trim();
    if (w.isEmpty && c.isEmpty) return '-';
    if (w.isEmpty) return c;
    if (c.isEmpty) return w;
    return '$c, $w';
  }

  String? _phoneText(OfferModel item) {
    try {
      final dynamic raw = item;
      final candidates = [
        raw.phone,
        raw.phonePro,
        raw.telephone,
        raw.telephonePro,
        raw.tel,
        raw.mobile,
        raw.whatsapp,
      ];

      for (final v in candidates) {
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty) return s;
        }
      }
    } catch (_) {}
    return null;
  }

  String _messageBody(OfferModel item) {
    final title =
    item.titre.trim().isEmpty ? 'votre annonce' : item.titre.trim();
    return 'Bonjour, je vous contacte au sujet de "$title".';
  }

  Future<void> _callItem() async {
    final item = _current;
    if (item == null) return;

    final phone = _phoneText(item);
    if (phone == null || phone.isEmpty) {
      await _showGlassDialog(
        message: 'Numéro de téléphone indisponible.',
        icon: Icons.phone_disabled_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: Colors.orange,
      );
      return;
    }

    final uri = Uri.parse('tel:$phone');
    final ok = await launchUrl(uri);

    if (!ok && mounted) {
      await _showGlassDialog(
        message: 'Impossible d’ouvrir l’appel.',
        icon: Icons.error_outline,
        iconBg: const Color(0xFFFFE5E5),
        iconColor: Colors.redAccent,
      );
    }
  }

  Future<void> _messageItem() async {
    final item = _current;
    if (item == null) return;

    final phone = _phoneText(item);
    if (phone == null || phone.isEmpty) {
      await _showGlassDialog(
        message: 'Numéro de téléphone indisponible.',
        icon: Icons.sms_failed_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: Colors.orange,
      );
      return;
    }

    final body = Uri.encodeComponent(_messageBody(item));
    final uri = Uri.parse('sms:$phone?body=$body');
    final ok = await launchUrl(uri);

    if (!ok && mounted) {
      await _showGlassDialog(
        message: 'Impossible d’ouvrir les messages.',
        icon: Icons.error_outline,
        iconBg: const Color(0xFFFFE5E5),
        iconColor: Colors.redAccent,
      );
    }
  }

  List<OfferModel> _relatedItems(OfferModel item) {
    final all = widget.manager.darekManager.currentList.value;
    final exact = <OfferModel>[];
    final sameMetier = <OfferModel>[];
    final samePlace = <OfferModel>[];
    final rest = <OfferModel>[];
    final used = <String>{item.id};

    bool sameCategory(OfferModel a, OfferModel b) =>
        a.metier.trim().toLowerCase() == b.metier.trim().toLowerCase();

    bool sameWilaya(OfferModel a, OfferModel b) =>
        a.wilaya.trim().toLowerCase() == b.wilaya.trim().toLowerCase();

    bool sameCommune(OfferModel a, OfferModel b) =>
        a.commune.trim().toLowerCase() == b.commune.trim().toLowerCase();

    for (final e in all) {
      if (used.contains(e.id)) continue;
      if (sameCategory(e, item) &&
          sameWilaya(e, item) &&
          sameCommune(e, item)) {
        exact.add(e);
        used.add(e.id);
      }
    }

    for (final e in all) {
      if (used.contains(e.id)) continue;
      if (sameCategory(e, item)) {
        sameMetier.add(e);
        used.add(e.id);
      }
    }

    for (final e in all) {
      if (used.contains(e.id)) continue;
      if (sameWilaya(e, item) && sameCommune(e, item)) {
        samePlace.add(e);
        used.add(e.id);
      }
    }

    for (final e in all) {
      if (used.contains(e.id)) continue;
      rest.add(e);
      used.add(e.id);
    }

    return <OfferModel>[
      ...exact,
      ...sameMetier,
      ...samePlace,
      ...rest,
    ].take(20).toList();
  }

  void _openRelated(OfferModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DarekDetailView(
          manager: widget.manager,
          item: item,
        ),
      ),
    );
  }

  Future<void> _goToImagePage(int index, int max) async {
    if (!_pageController.hasClients) return;
    final safe = index.clamp(0, max - 1);
    await _pageController.animateToPage(
      safe,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildImageArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: _glassPill(
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: _handleBack,
      ),
      title: const Text(
        'renovily',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.redAccent : Colors.black,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.black),
          onPressed: _shareItem,
        ),
      ],
    );
  }

  Widget _buildMobileOverlayAppBar() {
    final statusBar = MediaQuery.of(context).padding.top;

    return Positioned(
      top: statusBar + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          GlassCircleIconButton(
            icon: Icons.arrow_back_ios_new,
            tooltip: 'Retour',
            onTap: _handleBack,
          ),
          const Spacer(),
          GlassCircleIconButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            tooltip: 'Favori',
            onTap: _toggleFavorite,
          ),
          const SizedBox(width: 8),
          GlassCircleIconButton(
            icon: Icons.share_outlined,
            tooltip: 'Partager',
            onTap: _shareItem,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(OfferModel item, {double height = 280}) {
    final images = item.images;

    if (images.isEmpty || images.first.url.trim().isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFE9EEF3),
        alignment: Alignment.center,
        child: Icon(
          Icons.home_repair_service,
          size: 54,
          color: Colors.black.withOpacity(0.45),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final url = images[i].url.trim();
              return Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1F2937)),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          if (_isDesktopLike && images.length > 1)
            Positioned(
              left: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildImageArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _goToImagePage(_page - 1, images.length),
                ),
              ),
            ),
          if (_isDesktopLike && images.length > 1)
            Positioned(
              right: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildImageArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _goToImagePage(_page + 1, images.length),
                ),
              ),
            ),
          Positioned(
            right: 14,
            bottom: 14,
            child: _glassPill(
              child: Text(
                '${_page + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: active ? 18 : 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(active ? 0.95 : 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _glassPill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: Colors.black.withOpacity(0.72),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dateText(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double _indiceSafe(OfferModel item) {
    final raw = item.indiceFinitionMoyen;
    return raw.clamp(1.0, 10.0).toDouble();
  }

  double _noteSafe(OfferModel item) {
    final raw = item.noteMoyenne;
    return raw.clamp(0.0, 5.0).toDouble();
  }

  Widget _buildInfoGrid(OfferModel item, bool isWide) {
    final cards = [
      _infoTile(
        icon: Icons.work_outline,
        label: 'Métier',
        value: item.metier.trim().isEmpty ? '-' : item.metier,
      ),
      _infoTile(
        icon: Icons.location_on_outlined,
        label: 'Localisation',
        value: _locationText(item),
      ),
      _infoTile(
        icon: Icons.sell_outlined,
        label: 'Tarif',
        value: _priceText(item),
      ),
      _infoTile(
        icon: Icons.calendar_today_outlined,
        label: 'Publié le',
        value: _dateText(item.createdAt),
      ),
      _infoTile(
        icon: Icons.workspace_premium_outlined,
        label: 'Expérience',
        value:
        '${item.experienceAnnees} an${item.experienceAnnees > 1 ? 's' : ''}',
      ),
      _infoTile(
        icon: Icons.rate_review_outlined,
        label: 'Avis',
        value: '${item.nbAvis} avis • ${_noteSafe(item).toStringAsFixed(1)}/5',
      ),
    ];

    if (!isWide) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
          cards.map((card) => SizedBox(width: itemWidth, child: card)).toList(),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.call_outlined,
                text: 'Appeler',
                onTap: _callItem,
                bg: Colors.black,
                fg: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                icon: Icons.message_outlined,
                text: 'Message',
                onTap: _messageItem,
                bg: const Color(0xFFF3F4F6),
                fg: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isReviewActionLoading ? null : _openAvisDialog,
            icon: _isReviewActionLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.rate_review_outlined, size: 20),
            label: const Text(
              'Laisser un avis',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(
                color: Colors.black.withOpacity(0.10),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStars(double rating, {double size = 18}) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index < fullStars) {
          icon = Icons.star_rounded;
        } else if (index == fullStars && hasHalf) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            icon,
            size: size,
            color: const Color(0xFFF5B301),
          ),
        );
      }),
    );
  }

  Widget _buildIndiceGauge(OfferModel item) {
    final score = _indiceSafe(item);
    final progress = ((score - 1.0) / 9.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indice de finition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Niveau estimé de qualité de finition',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black.withOpacity(0.62),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ 10.0',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: const Color(0xFFE8EDF3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '10.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBlock(OfferModel item) {
    final note = _noteSafe(item);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              note.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStars(note, size: 20),
                const SizedBox(height: 6),
                Text(
                  '${item.nbAvis} avis client${item.nbAvis > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDescription(OfferModel item) {
    final text = item.description.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final shouldTruncate = text.length > 180;
    final displayText =
    (!_showFullDescription && shouldTruncate)
        ? '${text.substring(0, 180)}...'
        : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black.withOpacity(0.78),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              setState(() {
                _showFullDescription = !_showFullDescription;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _showFullDescription ? 'Voir moins' : 'Voir plus',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvisSection(OfferModel item) {
    final avis = _sortedAvisWithMineFirst(item.avis);

    if (avis.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.07),
            width: 1,
          ),
        ),
        child: Text(
          'Aucun avis pour le moment.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.65),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final visibleCount = _showAllAvis ? avis.length : math.min(3, avis.length);
    final visibleAvis = avis.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avis clients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildRatingBlock(item),
        const SizedBox(height: 12),
        for (int i = 0; i < visibleAvis.length; i++) ...[
          _AvisTile(
            avis: visibleAvis[i],
            canDelete: _isMyReview(visibleAvis[i]),
            onDelete: _isMyReview(visibleAvis[i])
                ? () => _deleteMyReview(visibleAvis[i])
                : null,
          ),
          if (i != visibleAvis.length - 1) const SizedBox(height: 10),
        ],
        if (avis.length > 3) ...[
          const SizedBox(height: 10),
          Center(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _showAllAvis = !_showAllAvis;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _showAllAvis ? 'Voir moins' : 'Voir plus',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRelatedSection(OfferModel item) {
    final related = _relatedItems(item);

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Text(
          'Annonces similaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        HorizontalDarek(
          items: related,
          emptyText: 'Aucune annonce similaire',
          onTap: _openRelated,
          shadow: false,
        ),
      ],
    );
  }

  Widget _buildHeaderInfosOnly(OfferModel item, bool isWide) {
    final namePro = item.namePro.trim();
    final hasNamePro = namePro.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.isPro)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Pro',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
        if (item.isPro) const SizedBox(height: 12),
        Text(
          item.titre,
          style: TextStyle(
            fontSize: isWide ? 28 : 24,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: Colors.black,
          ),
        ),
        if (hasNamePro) ...[
          const SizedBox(height: 8),
          Text(
            namePro,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.78),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          _priceText(item),
          style: TextStyle(
            fontSize: isWide ? 26 : 22,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 18),
        _buildRatingBlock(item),
        const SizedBox(height: 16),
        _buildIndiceGauge(item),
      ],
    );
  }

  Widget _buildBody(OfferModel item, bool isWide) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: _buildImageSlider(item),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfosOnly(item, false),
                const SizedBox(height: 22),
                _buildExpandableDescription(item),
                const SizedBox(height: 22),
                _buildInfoGrid(item, false),
                const SizedBox(height: 18),
                _buildActionRow(),
                const SizedBox(height: 24),
                _buildAvisSection(item),
                _buildRelatedSection(item),
              ],
            ),
          ),
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _buildImageSlider(item, height: 420),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 10,
                    child: _buildHeaderInfosOnly(item, true),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildExpandableDescription(item),
              const SizedBox(height: 22),
              _buildInfoGrid(item, true),
              const SizedBox(height: 24),
              _buildActionRow(),
              const SizedBox(height: 24),
              _buildAvisSection(item),
              _buildRelatedSection(item),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.manager.languageService.language,
      builder: (_, __, ___) {
        final item = _current;

        if (_loading) {
          return Scaffold(
            appBar: isWide ? _buildWebAppBar() : null,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (item == null) {
          return Scaffold(
            appBar: isWide ? _buildWebAppBar() : null,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GlassInfoDialog(
                      title: 'renovily',
                      message: _inlineError ?? 'Annonce introuvable',
                      okText: 'OK',
                      icon: Icons.error_outline,
                      iconBg: const Color(0xFFFFE5E5),
                      iconColor: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _fetchIfNeeded,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text(
                          'Réessayer',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isWide) {
          return Scaffold(
            appBar: _buildWebAppBar(),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: _buildBody(item, true),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: _buildBody(item, false),
              ),
              _buildMobileOverlayAppBar(),
            ],
          ),
        );
      },
    );
  }
}

class _AddAvisResult {
  final String prenom;
  final String message;
  final int note;
  final double indiceFinition;

  const _AddAvisResult({
    required this.prenom,
    required this.message,
    required this.note,
    required this.indiceFinition,
  });
}

class _AddAvisDialog extends StatefulWidget {
  const _AddAvisDialog();

  @override
  State<_AddAvisDialog> createState() => _AddAvisDialogState();
}

class _AddAvisDialogState extends State<_AddAvisDialog> {
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();

  int _note = 5;
  double _indiceFinition = 8.0;

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final prenom = _prenomCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (prenom.isEmpty || message.isEmpty) return;

    Navigator.pop(
      context,
      _AddAvisResult(
        prenom: prenom,
        message: message,
        note: _note,
        indiceFinition: _indiceFinition,
      ),
    );
  }

  Widget _buildStarPicker() {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final active = value <= _note;

        return IconButton(
          onPressed: () {
            setState(() {
              _note = value;
            });
          },
          visualDensity: VisualDensity.compact,
          splashRadius: 22,
          icon: Icon(
            active ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFF5B301),
            size: 30,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.92),
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.9),
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: SingleChildScrollView(
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
                          color: Color(0xFFEAF3FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rate_review_outlined,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Laisser un avis',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _prenomCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Votre prénom',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Votre note',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStarPicker(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Indice de finition',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        _indiceFinition.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        ' / 10',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      trackHeight: 6,
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 18,
                      ),
                    ),
                    child: Slider(
                      value: _indiceFinition,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      activeColor: Colors.black,
                      inactiveColor: const Color(0xFFE8EDF3),
                      label: _indiceFinition.toStringAsFixed(1),
                      onChanged: (v) {
                        setState(() {
                          _indiceFinition = v;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageCtrl,
                    minLines: 4,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Votre avis...',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.15),
                            ),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Envoyer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvisTile extends StatelessWidget {
  final OfferReviews avis;
  final bool canDelete;
  final VoidCallback? onDelete;

  const _AvisTile({
    required this.avis,
    this.canDelete = false,
    this.onDelete,
  });

  String _dateText(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _stars(int note) {
    final safe = note.clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < safe ? Icons.star_rounded : Icons.star_border_rounded,
          size: 16,
          color: const Color(0xFFF5B301),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prenom = avis.prenom.trim().isEmpty ? 'Client' : avis.prenom.trim();
    final date = _dateText(avis.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black.withOpacity(0.08),
                child: Text(
                  prenom.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prenom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.52),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _stars(avis.note),
                  const SizedBox(height: 4),
                  Text(
                    'Finition ${avis.indiceFinition.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black.withOpacity(0.58),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (canDelete && onDelete != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Supprimer',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
          if (avis.message.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              avis.message.trim(),
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black.withOpacity(0.78),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmDeleteAvisDialog extends StatelessWidget {
  const _ConfirmDeleteAvisDialog();

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
                const Text(
                  'Supprimer votre avis ?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cette action est définitive.',
                  style: TextStyle(
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
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Supprimer'),
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

class _LoginRequiredDialog extends StatelessWidget {
  const _LoginRequiredDialog();

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
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.blueAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Connexion requise',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Veuillez vous connecter pour exécuter cette action.',
                  style: TextStyle(
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
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Se connecter'),
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
