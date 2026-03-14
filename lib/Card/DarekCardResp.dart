import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../Darek/DarekModel.dart';
import '../Adresse/dz_lookup.dart';
import '../Const.dart';

class DarekCardResp extends StatefulWidget {
  const DarekCardResp({
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
  State<DarekCardResp> createState() => _DarekCardRespState();
}

class _DarekCardRespState extends State<DarekCardResp> {
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
    final unit = widget.item.unitePrix?.label ?? '';

    if (unit.isNotEmpty) {
      return '$p DA / $unit';
    }

    return '$p DA';
  }

  String _descriptionShort() {
    final d = widget.item.description.trim();
    if (d.isEmpty) return 'Professionnel disponible pour vos travaux.';
    if (d.length <= 90) return d;
    return '${d.substring(0, 90)}...';
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
        double height = 220,
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

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
              color: Colors.black.withOpacity(0.70),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black.withOpacity(0.52),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stars(double rating) {
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
            size: 16,
            color: const Color(0xFFF5B301),
          ),
        );
      }),
    );
  }

  Widget _ratingAndIndice() {
    final note = _noteSafe();
    final indice = _indiceSafe();
    final indiceProgress = ((indice - 1.0) / 9.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  note.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stars(note),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.item.nbAvis} avis',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.black.withOpacity(0.64),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${indice.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Finition',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black.withOpacity(0.54),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: indiceProgress,
              backgroundColor: const Color(0xFFE7EDF4),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dz = DzLookupService();
    final String? wilayaCode = dz.wilayaCodeFromName(widget.item.wilaya);
    final borderRadius = BorderRadius.circular(22);

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
                  height: 220,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      widget.item.metier.trim().isEmpty
                                          ? 'Service'
                                          : widget.item.metier.trim(),
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.72),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  if (wilayaCode != null && wilayaCode.trim().isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Zone ${wilayaCode.trim().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.72),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _priceText(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _title(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            height: 1.08,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _descriptionShort(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.70),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ratingAndIndice(),
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
  }
}
