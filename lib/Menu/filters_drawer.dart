import 'dart:ui';
import 'package:flutter/material.dart';
import '../App/AppLanguage.dart';
import '../App/Manager.dart';
import '../Dashboard/LanguageService.dart';

class FiltersDrawer extends StatelessWidget {
  const FiltersDrawer({
    super.key,
    required this.manager,
    required this.wilayas,
    required this.communes,
    required this.metiers,
    required this.prixMin,
    required this.prixMax,
    required this.isPro,
    required this.onSelectChanged,
    required this.onMetiersChanged,
    required this.onPrixMinChanged,
    required this.onPrixMaxChanged,
    required this.onIsProChanged,
    required this.onReset,
    required this.onApply,
  });

  final Manager manager;
  final List<String> wilayas;
  final List<String> communes;
  final List<String> metiers;
  final double? prixMin;
  final double? prixMax;
  final bool? isPro;

  final void Function(String type, String value, bool sel) onSelectChanged;
  final void Function(List<String> values) onMetiersChanged;
  final void Function(double? value) onPrixMinChanged;
  final void Function(double? value) onPrixMaxChanged;
  final void Function(bool? value) onIsProChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  List<String> _combineCommunes(List<String> selectedWilayas) {
    if (selectedWilayas.isEmpty) return [];
    final set = <String>{};

    for (final w in selectedWilayas) {
      final list = manager.dzLookupService.getCommunes(w, arabic: false);
      for (final c in list) {
        set.add(c);
      }
    }

    final result = set.toList()..sort();
    return result;
  }

  List<String> _allMetiers() {
    final items = manager.homeManager.currentList.value;
    final set = <String>{};

    for (final e in items) {
      final m = e.metier.trim();
      if (m.isNotEmpty) set.add(m);
    }

    final result = set.toList()..sort();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width.clamp(330, 450).toDouble();
    final allWilayas = manager.dzLookupService.wilayas(arabic: false);
    final allMetiers = _allMetiers();

    return Drawer(
      width: w,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 0.6,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: FiltersStateful(
                manager: manager,
                allWilayas: allWilayas,
                allMetiers: allMetiers,
                wilayas: wilayas,
                communes: communes,
                metiers: metiers,
                prixMin: prixMin,
                prixMax: prixMax,
                isPro: isPro,
                getCommunes: _combineCommunes,
                onSelectChanged: onSelectChanged,
                onMetiersChanged: onMetiersChanged,
                onPrixMinChanged: onPrixMinChanged,
                onPrixMaxChanged: onPrixMaxChanged,
                onIsProChanged: onIsProChanged,
                onReset: onReset,
                onApply: onApply,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FiltersStateful extends StatefulWidget {
  const FiltersStateful({
    super.key,
    required this.manager,
    required this.allWilayas,
    required this.allMetiers,
    required this.wilayas,
    required this.communes,
    required this.metiers,
    required this.prixMin,
    required this.prixMax,
    required this.isPro,
    required this.getCommunes,
    required this.onSelectChanged,
    required this.onMetiersChanged,
    required this.onPrixMinChanged,
    required this.onPrixMaxChanged,
    required this.onIsProChanged,
    required this.onReset,
    required this.onApply,
  });

  final Manager manager;
  final List<String> allWilayas;
  final List<String> allMetiers;
  final List<String> wilayas;
  final List<String> communes;
  final List<String> metiers;
  final double? prixMin;
  final double? prixMax;
  final bool? isPro;
  final List<String> Function(List<String>) getCommunes;

  final void Function(String type, String value, bool sel) onSelectChanged;
  final void Function(List<String> values) onMetiersChanged;
  final void Function(double? value) onPrixMinChanged;
  final void Function(double? value) onPrixMaxChanged;
  final void Function(bool? value) onIsProChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  State<FiltersStateful> createState() => _FiltersStatefulState();
}

class _FiltersStatefulState extends State<FiltersStateful> {
  late List<String> _wilayas;
  late List<String> _communes;
  late List<String> _metiers;

  late final TextEditingController _prixMinCtrl;
  late final TextEditingController _prixMaxCtrl;

  bool? _isPro;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _wilayas = [...widget.wilayas];
    _communes = [...widget.communes];
    _metiers = [...widget.metiers];
    _isPro = widget.isPro;
    _prixMinCtrl = TextEditingController(
      text: widget.prixMin != null ? widget.prixMin!.toStringAsFixed(0) : '',
    );
    _prixMaxCtrl = TextEditingController(
      text: widget.prixMax != null ? widget.prixMax!.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant FiltersStateful oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_dirty) return;

    _wilayas = [...widget.wilayas];
    _communes = [...widget.communes];
    _metiers = [...widget.metiers];
    _isPro = widget.isPro;
    _prixMinCtrl.text =
    widget.prixMin != null ? widget.prixMin!.toStringAsFixed(0) : '';
    _prixMaxCtrl.text =
    widget.prixMax != null ? widget.prixMax!.toStringAsFixed(0) : '';
  }

  @override
  void dispose() {
    _prixMinCtrl.dispose();
    _prixMaxCtrl.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    final raw = value.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _syncBackHard() {
    for (final old in List<String>.from(widget.wilayas)) {
      if (!_wilayas.contains(old)) {
        widget.onSelectChanged('wilaya', old, false);
      }
    }
    for (final item in _wilayas) {
      if (!widget.wilayas.contains(item)) {
        widget.onSelectChanged('wilaya', item, true);
      }
    }

    for (final old in List<String>.from(widget.communes)) {
      if (!_communes.contains(old)) {
        widget.onSelectChanged('commune', old, false);
      }
    }
    for (final item in _communes) {
      if (!widget.communes.contains(item)) {
        widget.onSelectChanged('commune', item, true);
      }
    }

    widget.onMetiersChanged([..._metiers]);
    widget.onPrixMinChanged(_parseDouble(_prixMinCtrl.text));
    widget.onPrixMaxChanged(_parseDouble(_prixMaxCtrl.text));
    widget.onIsProChanged(_isPro);
  }

  void _closeDrawerSafely() {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen == true) {
      scaffold!.closeDrawer();
      return;
    }
    if (scaffold?.isEndDrawerOpen == true) {
      scaffold!.closeEndDrawer();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Widget _priceField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
        prefixIcon: const Icon(Icons.sell_outlined, color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.25)),
        ),
      ),
      onChanged: (_) {
        setState(() {
          _dirty = true;
        });
      },
    );
  }

  Widget _proChoice(bool? value, String label) {
    final selected = _isPro == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _dirty = true;
            _isPro = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.45)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.black.withOpacity(0.22)
                  : Colors.white.withOpacity(0.35),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
        final communeOptions =
        _wilayas.isEmpty ? <String>[] : widget.getCommunes(_wilayas);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.filter_alt, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filtres',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Wilaya, commune, métier, prix, type',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.black,
                      onPressed: _closeDrawerSafely,
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: Colors.black.withOpacity(0.1)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  GSection(
                    title: 'Wilayas',
                    child: GDropMulti(
                      manager: widget.manager,
                      title: 'Wilayas',
                      values: _wilayas,
                      options: widget.allWilayas,
                      onTempChange: (v) {
                        setState(() {
                          _dirty = true;
                          _wilayas = v;
                          final valid = widget.getCommunes(_wilayas).toSet();
                          _communes.removeWhere((c) => !valid.contains(c));
                        });
                      },
                      onApply: (v) {
                        setState(() {
                          _dirty = true;
                          _wilayas = v;
                          final valid = widget.getCommunes(_wilayas).toSet();
                          _communes.removeWhere((c) => !valid.contains(c));
                        });
                      },
                    ),
                  ),
                  if (_wilayas.isNotEmpty)
                    GSection(
                      title: 'Communes',
                      child: GDropMulti(
                        manager: widget.manager,
                        title: 'Communes',
                        values: _communes,
                        options: communeOptions,
                        onTempChange: (v) {
                          setState(() {
                            _dirty = true;
                            _communes = v;
                          });
                        },
                        onApply: (v) {
                          setState(() {
                            _dirty = true;
                            _communes = v;
                          });
                        },
                      ),
                    ),
                  GSection(
                    title: 'Métiers',
                    child: GDropMulti(
                      manager: widget.manager,
                      title: 'Métiers',
                      values: _metiers,
                      options: widget.allMetiers,
                      onTempChange: (v) {
                        setState(() {
                          _dirty = true;
                          _metiers = v;
                        });
                      },
                      onApply: (v) {
                        setState(() {
                          _dirty = true;
                          _metiers = v;
                        });
                      },
                    ),
                  ),
                  GSection(
                    title: 'Prix',
                    child: Row(
                      children: [
                        Expanded(
                          child: _priceField(
                            controller: _prixMinCtrl,
                            hint: 'Prix min',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _priceField(
                            controller: _prixMaxCtrl,
                            hint: 'Prix max',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GSection(
                    title: 'Type de compte',
                    child: Row(
                      children: [
                        _proChoice(null, 'Tous'),
                        const SizedBox(width: 8),
                        _proChoice(true, 'Pro'),
                        const SizedBox(width: 8),
                        _proChoice(false, 'Non pro'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.black.withOpacity(0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _dirty = false;
                          _wilayas = [];
                          _communes = [];
                          _metiers = [];
                          _prixMinCtrl.clear();
                          _prixMaxCtrl.clear();
                          _isPro = null;
                        });
                        widget.onReset();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black.withOpacity(0.2)),
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _syncBackHard();
                        _closeDrawerSafely();
                        _dirty = false;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onApply();
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class GSection extends StatelessWidget {
  const GSection({
    super.key,
    required this.title,
    required this.child,
    this.hint,
  });

  final String title;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    const color = Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(width: 8),
                Text(
                  hint!,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class GDropMulti extends StatefulWidget {
  const GDropMulti({
    super.key,
    required this.manager,
    required this.title,
    required this.values,
    required this.options,
    required this.onApply,
    this.onTempChange,
    this.enabled = true,
  });

  final Manager manager;
  final String title;
  final List<String> values;
  final List<String> options;
  final bool enabled;
  final ValueChanged<List<String>> onApply;
  final ValueChanged<List<String>>? onTempChange;

  @override
  State<GDropMulti> createState() => _GDropMultiState();
}

class _GDropMultiState extends State<GDropMulti> {
  late List<String> _temp;
  bool _expanded = false;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _temp = [...widget.values];
  }

  @override
  void didUpdateWidget(covariant GDropMulti oldWidget) {
    super.didUpdateWidget(oldWidget);
    _temp = [...widget.values];
  }

  @override
  Widget build(BuildContext context) {
    const color = Colors.black;

    final opts = [...widget.options]..sort();
    final filtered = _q.isEmpty
        ? opts
        : opts.where((e) => e.toLowerCase().contains(_q.toLowerCase())).toList();

    const maxVisible = 4;
    const tileHeight = 40.0;
    final listHeight = filtered.isEmpty
        ? 0.0
        : (filtered.length <= maxVisible
        ? filtered.length * tileHeight
        : maxVisible * tileHeight);

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.white.withOpacity(0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.35)),
              ),
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _temp.isEmpty
                              ? widget.title
                              : _temp.length <= 2
                              ? '${widget.title}: ${_temp.join(', ')}'
                              : '${widget.title}: ${_temp.length} sélectionnés',
                          style: const TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: !_expanded
                  ? const SizedBox.shrink()
                  : Container(
                key: const ValueKey('expanded'),
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: color),
                      cursorColor: color,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: color.withOpacity(0.85),
                        ),
                        hintText: 'Rechercher',
                        hintStyle:
                        TextStyle(color: color.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                          BorderSide(color: color.withOpacity(0.35)),
                        ),
                      ),
                      onChanged: (v) => setState(() => _q = v),
                    ),
                    const SizedBox(height: 8),
                    if (listHeight > 0)
                      SizedBox(
                        height: listHeight,
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final v = filtered[i];
                              final sel = _temp.contains(v);

                              return CheckboxListTile(
                                value: sel,
                                dense: true,
                                onChanged: (b) {
                                  setState(() {
                                    if (b == true) {
                                      if (!_temp.contains(v)) {
                                        _temp.add(v);
                                      }
                                    } else {
                                      _temp.remove(v);
                                    }
                                  });
                                  widget.onTempChange?.call([..._temp]);
                                },
                                controlAffinity:
                                ListTileControlAffinity.leading,
                                activeColor: Colors.black,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: color.withOpacity(0.5),
                                ),
                                title: Text(
                                  v,
                                  style: const TextStyle(color: color),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() => _temp.clear());
                            widget.onTempChange?.call([]);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: color,
                          ),
                          child: const Text('Tout effacer'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _expanded = false);
                            widget.onApply([..._temp]);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}