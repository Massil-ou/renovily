import 'dart:ui';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../Darek/DarekModel.dart';
import '../Card/DarekCard.dart';

class HorizontalDarek extends StatefulWidget {
  final List<OfferModel> items;
  final String emptyText;
  final void Function(OfferModel) onTap;
  final bool enableImageSwipe;
  final bool buttonScroll;
  final bool showImageIndicators;
  final bool shadow;
  final void Function(bool locked)? onImageTouchLockScroll;

  const HorizontalDarek({
    super.key,
    required this.items,
    required this.emptyText,
    required this.onTap,
    this.enableImageSwipe = true,
    this.buttonScroll = true,
    this.showImageIndicators = true,
    this.shadow = false,
    this.onImageTouchLockScroll,
  });

  @override
  State<HorizontalDarek> createState() => _HorizontalDarekState();
}

class _HorizontalDarekState extends State<HorizontalDarek> {
  final ScrollController _controller = ScrollController();

  static const double _itemWidth = 320.0;
  static const double _spacing = 12.0;
  static const double _stripHeight = 450.0;

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  bool _lockInnerScroll = false;

  bool get _isDesktop {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonsState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtonsState());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonsState);
    _controller.dispose();
    super.dispose();
  }

  double _maxScroll() {
    if (!_controller.hasClients) return 0.0;
    return _controller.position.maxScrollExtent;
  }

  double _off() {
    if (!_controller.hasClients) return 0.0;
    return _controller.offset;
  }

  void _updateButtonsState() {
    final max = _maxScroll();
    final off = _off();
    const eps = 0.5;

    final canLeft = off > eps;
    final canRight = off < (max - eps);

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (_lockInnerScroll) return;
    if (event is PointerScrollEvent && _controller.hasClients) {
      final dx = event.scrollDelta.dx;
      final dy = event.scrollDelta.dy;
      final delta = dx.abs() > dy.abs() ? dx : dy;

      final max = _maxScroll();
      final newOffset = (_off() + delta).clamp(0.0, max).toDouble();
      _controller.jumpTo(newOffset);
    }
  }

  double _pageDelta() => (_itemWidth + _spacing) * 2;

  Future<void> _scrollBy(double delta) async {
    if (_lockInnerScroll) return;
    if (!_controller.hasClients) return;

    final max = _maxScroll();
    final target = (_off() + delta).clamp(0.0, max).toDouble();

    await _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _glassPill({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

  Widget _circleButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final ok = enabled && !_lockInnerScroll;

    return Opacity(
      opacity: ok ? 1.0 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: ok ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: _glassPill(
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.95),
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          widget.emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      );
    }

    final items = widget.items.take(20).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout = constraints.maxWidth < 800;

        return SizedBox(
          height: _stripHeight,
          child: Listener(
            onPointerSignal: _isDesktop ? null : _handlePointerSignal,
            child: Stack(
              children: [
                ListView.separated(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.start,
                  physics: _lockInnerScroll
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 0, right: 0, bottom: 14),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: _spacing),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return SizedBox(
                      width: _itemWidth,
                      child: DarekCard(
                        item: item,
                        onTap: () => widget.onTap(item),
                        shadow: widget.shadow,
                      ),
                    );
                  },
                ),
                if (!isMobileLayout) ...[
                  Positioned(
                    left: 6,
                    top: (_stripHeight - 28) / 2,
                    child: _circleButton(
                      icon: Icons.chevron_left_rounded,
                      enabled: _canScrollLeft,
                      onTap: () => _scrollBy(-_pageDelta()),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: (_stripHeight - 28) / 2,
                    child: _circleButton(
                      icon: Icons.chevron_right_rounded,
                      enabled: _canScrollRight,
                      onTap: () => _scrollBy(_pageDelta()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}