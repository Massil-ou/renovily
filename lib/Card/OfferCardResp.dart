import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../Adresse/dz_lookup.dart';
import '../Const.dart';
import '../Offre/DarekModel.dart';

class OfferCardResp extends StatefulWidget {
  const OfferCardResp({
    super.key,
    required this.item,
    required this.onTap,
    this.enableImageSwipe = true,
    this.buttonScroll = true,
    this.showImageIndicators = true,
    this.shadow = false,
    this.onImageTouchLockScroll,
  });

  final OfferModel item;
  final VoidCallback onTap;
  final bool enableImageSwipe;
  final bool buttonScroll;
  final bool showImageIndicators;
  final bool shadow;
  final void Function(bool locked)? onImageTouchLockScroll;

  @override
  State<OfferCardResp> createState() => _OfferCardRespState();
}

class _OfferCardRespState extends State<OfferCardResp> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  Offset? _down;
  bool _moved = false;

  bool _imgLock = false;
  double _accDx = 0.0;
  double _accDy = 0.0;

  @override
  void dispose() {
    widget.onImageTouchLockScroll?.call(false);
    _pageCtrl.dispose();
    super.dispose();
  }

  bool get _isPro => widget.item.isPro;

  int get _imgCount => widget.item.images.length;

  String? get _coverUrl {
    if (_imgCount == 0) return null;
    final u = widget.item.images.first.url.trim();
    return u.isEmpty ? null : u;
  }

  String _imgAt(int i) => widget.item.images[i].url.trim();

  String _title() {
    final t = widget.item.titre.trim();
    if (t.isNotEmpty) return t;

    final m = widget.item.metier.trim();
    if (m.isNotEmpty) return m;

    return 'Annonce';
  }

  String _priceText() {
    if (widget.item.prix == null || widget.item.prix! <= 0) {
      return 'Prix à négocier';
    }

    final p = widget.item.prix!.toString();
    final rawUnit = (widget.item.unitePrix?.label ?? '').trim();

    String shortUnit = rawUnit;
    if (shortUnit.isNotEmpty && shortUnit.length > 3) {
      shortUnit = shortUnit.substring(0, 3);
    }

    if (shortUnit.isNotEmpty) {
      return '$p DA / $shortUnit';
    }

    return '$p DA';
  }

  String _descriptionShort() {
    final d = widget.item.description.trim();
    if (d.isEmpty) return 'Professionnel disponible pour vos travaux.';
    if (d.length <= 110) return d;
    return '${d.substring(0, 110)}...';
  }

  double _noteSafe() {
    return widget.item.noteMoyenne.clamp(0.0, 5.0).toDouble();
  }

  double _indiceSafe() {
    final raw = widget.item.indiceFinitionMoyen;
    return raw.clamp(1.0, 10.0).toDouble();
  }

  void _setImgLock(bool v) {
    if (_imgLock == v) return;
    _imgLock = v;
    widget.onImageTouchLockScroll?.call(v);
  }

  void _handleTapDown(TapDownDetails d) {
    _down = d.globalPosition;
    _moved = false;
  }

  void _handlePointerMove(PointerMoveEvent e) {
    final start = _down;
    if (start == null) return;
    final dist = (e.position - start).distance;
    if (dist > 10) _moved = true;
  }

  void _handleTapUp(TapUpDetails d) {
    if (_moved) return;
    widget.onTap();
  }

  void _handleTapCancel() {
    _moved = true;
  }

  Future<void> _goTo(int i) async {
    if (!mounted) return;
    if (!_pageCtrl.hasClients) return;
    if (_imgCount <= 1) return;

    final t = i.clamp(0, _imgCount - 1);
    await _pageCtrl.animateToPage(
      t,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _prev() => _goTo(_page - 1);
  void _next() => _goTo(_page + 1);

  bool _isDesktopLike(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  Widget _glassPill({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
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

  Widget _dots() {
    final n = _imgCount;
    if (n <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(n, (i) {
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
    );
  }

  Widget _proChip() {
    return Container(
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
          height: 1.0,
        ),
      ),
    );
  }

  Widget _sideArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: _glassPill(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.95),
            size: 18,
          ),
        ),
      ),
    );
  }

  void _consumeDrag(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    _accDx += dx;
    _accDy += dy;

    const th = 22.0;

    if (_accDx.abs() >= _accDy.abs()) {
      if (_accDx <= -th) {
        _accDx = 0;
        _accDy = 0;
        _next();
      } else if (_accDx >= th) {
        _accDx = 0;
        _accDy = 0;
        _prev();
      }
    } else {
      if (_accDy <= -th) {
        _accDx = 0;
        _accDy = 0;
        _next();
      } else if (_accDy >= th) {
        _accDx = 0;
        _accDy = 0;
        _prev();
      }
    }
  }

  Widget _imageSlider(
      BuildContext context, {
        required double height,
        BorderRadius? radius,
      }) {
    final effectiveRadius = radius ?? BorderRadius.circular(kRadius);

    if (_imgCount == 0 || _coverUrl == null) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Container(
          height: height,
          color: const Color(0xFFE9EEF3),
          alignment: Alignment.center,
          child: Icon(
            Icons.home_repair_service,
            size: 42,
            color: Colors.black.withOpacity(0.45),
          ),
        ),
      );
    }

    final canSwipe = widget.enableImageSwipe && _imgCount > 1;
    final showArrows = canSwipe && widget.buttonScroll && _isDesktopLike(context);
    final showIndicators = canSwipe && widget.showImageIndicators;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: SizedBox(
        height: height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onPanDown: (_) {
            if (!canSwipe) return;
            _accDx = 0;
            _accDy = 0;
            _setImgLock(true);
          },
          onPanStart: (_) {
            if (!canSwipe) return;
            _setImgLock(true);
          },
          onPanUpdate: (d) {
            if (!canSwipe) return;
            _consumeDrag(d);
          },
          onPanEnd: (_) => _setImgLock(false),
          onPanCancel: () => _setImgLock(false),
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _imgCount,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final url = _imgAt(i);
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE9EEF3),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 36,
                          color: Colors.black.withOpacity(0.35),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 78,
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
              if (showArrows)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _sideArrow(
                      icon: Icons.chevron_left_rounded,
                      onTap: _prev,
                    ),
                  ),
                ),
              if (showArrows)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _sideArrow(
                      icon: Icons.chevron_right_rounded,
                      onTap: _next,
                    ),
                  ),
                ),
              if (_isPro)
                Positioned(
                  left: 12,
                  top: 12,
                  child: _proChip(),
                ),
              if (showIndicators)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _glassPill(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    child: Text(
                      '${_page + 1}/$_imgCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              if (showIndicators)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Center(child: _dots()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stars(double rating, {double size = 16}) {
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
          padding: const EdgeInsets.only(right: 1),
          child: Icon(
            icon,
            size: size,
            color: const Color(0xFFF5B301),
          ),
        );
      }),
    );
  }

  Widget _ratingAndIndice({required bool compact}) {
    final note = _noteSafe();
    final indice = _indiceSafe();
    final indiceProgress = ((indice - 1.0) / 9.0).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(compact ? 10 : 12),
                ),
                alignment: Alignment.center,
                child: Text(
                  note.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 15 : 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stars(note, size: compact ? 14 : 16),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.item.nbAvis} avis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 12.5,
                        color: Colors.black.withOpacity(0.64),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${indice.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Finition',
                    style: TextStyle(
                      fontSize: compact ? 10.5 : 11.5,
                      color: Colors.black.withOpacity(0.54),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: compact ? 6 : 8,
              value: indiceProgress,
              backgroundColor: const Color(0xFFE7EDF4),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black.withOpacity(0.72),
          fontWeight: FontWeight.w800,
          fontSize: compact ? 10.5 : 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dz = DzLookupService();
    final String? wilayaCode = dz.wilayaCodeFromName(widget.item.wilaya);
    final borderRadius = BorderRadius.circular(22);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight =
        constraints.maxHeight.isFinite ? constraints.maxHeight : 440.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final isWebLike = screenWidth >= 720;

        final compact = isWebLike && cardHeight <= 440;
        final imageHeight = compact ? 185.0 : 220.0;
        final contentPadding = compact ? 12.0 : 14.0;
        final titleLines = compact ? 1 : 2;
        final descLines = compact ? 1 : 2;

        return Material(
          color: Colors.transparent,
          child: Listener(
            onPointerMove: _handlePointerMove,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.06),
                  ),
                  boxShadow: widget.shadow
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imageSlider(
                      context,
                      height: imageHeight,
                      radius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          contentPadding,
                          contentPadding,
                          contentPadding,
                          contentPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _chip(
                                        widget.item.metier.trim().isEmpty
                                            ? 'Service'
                                            : widget.item.metier.trim(),
                                        compact: compact,
                                      ),
                                      if (wilayaCode != null &&
                                          wilayaCode.trim().isNotEmpty)
                                        _chip(
                                          'Zone ${wilayaCode.trim().padLeft(2, '0')}',
                                          compact: compact,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: compact ? 110 : 130,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _priceText(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: compact ? 16 : 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            Text(
                              _title(),
                              maxLines: titleLines,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: compact ? 17 : 19,
                                height: 1.08,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: compact ? 6 : 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _descriptionShort(),
                                  maxLines: descLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.70),
                                    fontSize: compact ? 12.5 : 13.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 12),
                            _ratingAndIndice(compact: compact),
                          ],
                        ),
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
}