import 'dart:ui';

import 'package:flutter/material.dart';

import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';
import '../../DarekDetails/DarekDetailView.dart';
import '../DarekSettingsView/DarekSettingsView.dart';
import 'MesAnnoncesManager.dart';

class MesAnnoncesPage extends StatefulWidget {
  final Manager manager;

  const MesAnnoncesPage({
    super.key,
    required this.manager,
  });

  @override
  State<MesAnnoncesPage> createState() => _MesAnnoncesPageState();
}

class _MesAnnoncesPageState extends State<MesAnnoncesPage> {
  late final MesAnnoncesManager m = widget.manager.mesAnnoncesManager;

  @override
  void initState() {
    super.initState();
    m.addListener(_listener);
    m.load();
  }

  void _listener() {
    if (!mounted) return;

    setState(() {});

    if (m.lastError != null) {
      final err = m.lastError!;
      m.lastError = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showGlassDialog(
          title: 'Erreur',
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
    switch (code) {
      case 'update_failed':
        return 'Impossible de modifier cette annonce.';
      case 'delete_failed':
        return 'Impossible de supprimer cette annonce.';
      case 'exception':
        return 'Une erreur est survenue lors de la communication avec le serveur.';
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

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const _DeleteAnnonceDialog(),
    );

    return result == true;
  }

  String _price(OfferModel a) {
    if (a.prix == null || a.prix! <= 0) return 'Prix à négocier';
    final unit = a.unitePrix?.label ?? '';
    if (unit.isEmpty) return '${a.prix} DA';
    return '${a.prix} DA / $unit';
  }

  String _subtitle(OfferModel a) {
    final parts = <String>[
      if (a.metier.trim().isNotEmpty) a.metier.trim(),
      if (a.wilaya.trim().isNotEmpty) a.wilaya.trim(),
      if (a.commune.trim().isNotEmpty) a.commune.trim(),
    ];
    return parts.isEmpty ? '-' : parts.join(' • ');
  }

  Future<void> _deleteAnnonce(OfferModel item) async {
    final confirm = await _showDeleteConfirmDialog();
    if (!confirm) return;

    await m.delete(item.id);
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

  Future<void> _openEditDialog(OfferModel item) async {
    final updated = await showDialog<OfferModel>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _EditAnnonceDialog(item: item),
    );

    if (updated == null || !mounted) return;

    await m.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const PageHeader(
          title: 'Mes annonces',
          subtitle: 'Gérer vos annonces publiées',
        ),
        if (m.isLoading)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (m.annonces.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: _EmptyMesAnnoncesCard(),
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
                    children: List.generate(m.annonces.length, (index) {
                      final a = m.annonces[index];

                      return Column(
                        children: [
                          AnnonceCardItem(
                            imageUrl:
                            a.images.isNotEmpty ? a.images.first.url : null,
                            title: a.titre,
                            subtitle: _subtitle(a),
                            price: _price(a),
                            status: a.status,
                            onTap: () => _openDetails(a),
                            onEdit: () => _openEditDialog(a),
                            onDelete: () => _deleteAnnonce(a),
                          ),
                          if (index != m.annonces.length - 1)
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
  final OfferStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnnonceCardItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.status,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _statusColor(OfferStatus value) {
    switch (value) {
      case OfferStatus.pending:
        return Colors.orangeAccent;
      case OfferStatus.deleted:
        return Colors.redAccent;
      case OfferStatus.visible:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);
    final statusLabel = status.label;

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
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: statusColor.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    const SizedBox(width: 8),
                  if (onEdit != null)
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 8),
                  if (onDelete != null)
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
              ),
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
        width: 64,
        height: 64,
        color: Colors.white.withOpacity(0.12),
        child: url.isEmpty
            ? const Icon(
          Icons.construction_outlined,
          color: Colors.white,
          size: 28,
        )
            : Image.network(
          url,
          fit: BoxFit.cover,
          width: 64,
          height: 64,
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

class _EditAnnonceDialog extends StatefulWidget {
  final OfferModel item;

  const _EditAnnonceDialog({required this.item});

  @override
  State<_EditAnnonceDialog> createState() => _EditAnnonceDialogState();
}

class _EditAnnonceDialogState extends State<_EditAnnonceDialog> {
  late final TextEditingController _titreCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _wilayaCtrl;
  late final TextEditingController _communeCtrl;
  late final TextEditingController _metierCtrl;
  late final TextEditingController _prixCtrl;
  late OfferPriceUnit? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(text: widget.item.titre);
    _descriptionCtrl = TextEditingController(text: widget.item.description);
    _wilayaCtrl = TextEditingController(text: widget.item.wilaya);
    _communeCtrl = TextEditingController(text: widget.item.commune);
    _metierCtrl = TextEditingController(text: widget.item.metier);
    _prixCtrl = TextEditingController(
      text: widget.item.prix?.toString() ?? '',
    );
    _selectedUnit = widget.item.unitePrix;
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _wilayaCtrl.dispose();
    _communeCtrl.dispose();
    _metierCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = OfferModel(
      id: widget.item.id,
      titre: _titreCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      wilaya: _wilayaCtrl.text.trim(),
      commune: _communeCtrl.text.trim(),
      metier: _metierCtrl.text.trim(),
      isPro: widget.item.isPro,
      namePro: widget.item.namePro,
      status: widget.item.status,
      experienceAnnees: widget.item.experienceAnnees,
      prix: int.tryParse(_prixCtrl.text.trim()),
      unitePrix: _selectedUnit,
      images: widget.item.images,
      createdAt: widget.item.createdAt,
      avis: widget.item.avis,
    );

    Navigator.pop(context, updated);
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                          Icons.edit_outlined,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Modifier l’annonce',
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
                    controller: _titreCtrl,
                    decoration: _decoration('Titre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _decoration('Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _metierCtrl,
                    decoration: _decoration('Métier'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _wilayaCtrl,
                          decoration: _decoration('Wilaya'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _communeCtrl,
                          decoration: _decoration('Commune'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _prixCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _decoration('Prix'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<OfferPriceUnit?>(
                          value: _selectedUnit,
                          decoration: _decoration('Unité'),
                          items: [
                            const DropdownMenuItem<OfferPriceUnit?>(
                              value: null,
                              child: Text('Aucune unité'),
                            ),
                            ...OfferPriceUnit.values.map(
                                  (unit) => DropdownMenuItem<OfferPriceUnit?>(
                                value: unit,
                                child: Text(unit.label),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedUnit = value;
                            });
                          },
                        ),
                      ),
                    ],
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
                          child: const Text('Enregistrer'),
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

class _DeleteAnnonceDialog extends StatelessWidget {
  const _DeleteAnnonceDialog();

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
                    const Expanded(
                      child: Text(
                        'Supprimer l’annonce',
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
                  'Voulez-vous vraiment supprimer cette annonce ?',
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
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

class _EmptyMesAnnoncesCard extends StatelessWidget {
  const _EmptyMesAnnoncesCard();

  @override
  Widget build(BuildContext context) {
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
          child: const Column(
            children: [
              Icon(
                Icons.campaign_outlined,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(height: 12),
              Text(
                'Aucune annonce',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Vos annonces publiées apparaîtront ici.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
