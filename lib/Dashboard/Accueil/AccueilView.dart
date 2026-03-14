import 'dart:ui';
import 'package:flutter/material.dart';

import '../../Card/DarekCardResp.dart';
import '../../Const.dart';
import '../../Darek/DarekModel.dart';
import '../../DarekDetails/DarekDetailView.dart';
import '../../Menu/filters_drawer.dart';
import '../../App/Manager.dart';
import '../LanguageService.dart';

class AccueilView extends StatefulWidget {
  final Manager manager;

  const AccueilView({
    super.key,
    required this.manager,
  });

  @override
  State<AccueilView> createState() => _AccueilViewState();
}

class _AccueilViewState extends State<AccueilView> {
  static const double _maxContentWidth = 1180.0;
  static const double _heroHeight = 320;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _wilayas = [];
  final List<String> _communes = [];
  final List<String> _metiers = [];

  int? _prixMin;
  int? _prixMax;
  bool? _isPro;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await widget.manager.darekManager.init();
      } catch (_) {}
    });
  }

  void _openFilters() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _onSearch() async {
    FocusScope.of(context).unfocus();

    await widget.manager.darekManager.applyFilters(
      q: _searchCtrl.text.trim(),
      wilayas: _wilayas,
      communes: _communes,
      metiers: _metiers,
      prixMin: _prixMin,
      prixMax: _prixMax,
      isPro: _isPro,
    );

    if (!mounted) return;
    setState(() {});
  }

  void _onSelectChanged(String type, String value, bool selected) {
    List<String> target;

    switch (type) {
      case 'wilaya':
        target = _wilayas;
        if (!selected) _communes.clear();
        break;
      case 'commune':
        if (_wilayas.isEmpty) return;
        target = _communes;
        break;
      default:
        return;
    }

    setState(() {
      if (selected) {
        if (!target.contains(value)) target.add(value);
      } else {
        target.remove(value);
      }

      if (_wilayas.isEmpty) _communes.clear();
    });
  }

  void _onReset() {
    setState(() {
      _searchCtrl.clear();
      _wilayas.clear();
      _communes.clear();
      _metiers.clear();
      _prixMin = null;
      _prixMax = null;
      _isPro = null;
    });

    widget.manager.darekManager.clearFilters();
  }

  Future<void> _onApply() async {
    Navigator.of(context).maybePop();

    await widget.manager.darekManager.applyFilters(
      q: _searchCtrl.text.trim(),
      wilayas: _wilayas,
      communes: _communes,
      metiers: _metiers,
      prixMin: _prixMin,
      prixMax: _prixMax,
      isPro: _isPro,
    );

    if (!mounted) return;
    setState(() {});
  }

  void _openDetails(OfferModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DarekDetailView(
          manager: widget.manager,
          item: item,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isMobile(double width) => width < 720;

  int _gridCount(double width) {
    if (width >= 1120) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  double _cardHeight(double width) {
    if (width >= 1320) return 440;
    if (width >= 1120) return 425;
    if (width >= 900) return 415;
    if (width >= 720) return 460;
    if (width >= 520) return 450;
    return 440;
  }

  EdgeInsets _contentPadding(double width) {
    if (_isMobile(width)) {
      return const EdgeInsets.fromLTRB(6, 0, 6, 90);
    }
    return const EdgeInsets.fromLTRB(20, 0, 20, 90);
  }

  double _listOverlapForWidth(double width) {
    if (_isMobile(width)) return 48;
    return 0;
  }

  Widget _buildHero() {
    return SizedBox(
      height: _heroHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backs.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kGutter, 12, kGutter, 12),
              child: Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _GlassPill(
                            icon: Icons.construction,
                            text: 'BTP',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Trouver un professionnel du BTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Maçon, plombier, peintre, carreleur, électricien et plus encore.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _GlassSearchCard(
                            controller: _searchCtrl,
                            onSearch: _onSearch,
                            onFilters: _openFilters,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _buildActiveFilterBadges(),
                          ),
                        ],
                      ),
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

  List<Widget> _buildActiveFilterBadges() {
    final widgets = <Widget>[];

    if (_searchCtrl.text.trim().isNotEmpty) {
      widgets.add(_FilterBadge(text: 'Q: ${_searchCtrl.text.trim()}'));
    }

    widgets.addAll(_wilayas.map((e) => _FilterBadge(text: e)));
    widgets.addAll(_communes.map((e) => _FilterBadge(text: e)));
    widgets.addAll(_metiers.map((e) => _FilterBadge(text: e)));

    if (_prixMin != null) {
      widgets.add(_FilterBadge(text: 'Min $_prixMin DA'));
    }

    if (_prixMax != null) {
      widgets.add(_FilterBadge(text: 'Max $_prixMax DA'));
    }

    if (_isPro == true) {
      widgets.add(const _FilterBadge(text: 'Pro'));
    } else if (_isPro == false) {
      widgets.add(const _FilterBadge(text: 'Non pro'));
    }

    return widgets;
  }

  Widget _buildList() {
    return ValueListenableBuilder<List<OfferModel>>(
      valueListenable: widget.manager.darekManager.currentList,
      builder: (_, items, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.manager.darekManager.isLoading,
          builder: (_, isLoading, ___) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = _gridCount(width);
                final mainAxisExtent = _cardHeight(width);
                final padding = _contentPadding(width);
                final overlap = _listOverlapForWidth(width);

                return Transform.translate(
                  offset: Offset(0, -overlap),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: overlap),
                    child: Column(
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _maxContentWidth,
                            ),
                            child: Padding(
                              padding: padding,
                              child: isLoading
                                  ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                                  : items.isEmpty
                                  ? const _EmptyState()
                                  : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 18,
                                  crossAxisSpacing: 18,
                                  mainAxisExtent: mainAxisExtent,
                                ),
                                itemBuilder: (_, index) {
                                  final item = items[index];
                                  return DarekCardResp(
                                    item: item,
                                    shadow: false,
                                    onTap: () => _openDetails(item),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _floatingFilter() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.black.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: _openFilters,
              borderRadius: BorderRadius.circular(999),
              child: const Icon(
                Icons.tune,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.manager.languageService.language,
      builder: (_, __, ___) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          drawerEnableOpenDragGesture: false,
          drawerEdgeDragWidth: 0,
          drawer: FiltersDrawer(
            manager: widget.manager,
            wilayas: _wilayas,
            communes: _communes,
            metiers: _metiers,
            prixMin: _prixMin?.toDouble(),
            prixMax: _prixMax?.toDouble(),
            isPro: _isPro,
            onSelectChanged: _onSelectChanged,
            onMetiersChanged: (v) {
              setState(() {
                _metiers
                  ..clear()
                  ..addAll(v);
              });
            },
            onPrixMinChanged: (v) {
              setState(() {
                _prixMin = v?.toInt();
              });
            },
            onPrixMaxChanged: (v) {
              setState(() {
                _prixMax = v?.toInt();
              });
            },
            onIsProChanged: (v) {
              setState(() {
                _isPro = v;
              });
            },
            onReset: _onReset,
            onApply: _onApply,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        _buildHero(),
                        _buildList(),
                      ],
                    ),
                  ),
                  _floatingFilter(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _GlassSearchCard extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function() onSearch;
  final VoidCallback onFilters;

  const _GlassSearchCard({
    required this.controller,
    required this.onSearch,
    required this.onFilters,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearch(),
                  decoration: const InputDecoration(
                    hintText: 'Recherche plombier, maçon...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _GlassIconButton(
                icon: Icons.tune,
                onTap: onFilters,
              ),
              const SizedBox(width: 6),
              _GlassIconButton(
                icon: Icons.search,
                onTap: () => onSearch(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.85),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.amberAccent),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String text;

  const _FilterBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black.withOpacity(0.75),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: Colors.black.withOpacity(0.62),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie d’élargir la recherche ou de modifier les filtres.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.black.withOpacity(0.62),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
