import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';
import 'AddOfferManager.dart';

class AddOffersView extends StatefulWidget {
  final Manager manager;

  const AddOffersView({
    super.key,
    required this.manager,
  });

  @override
  State<AddOffersView> createState() => _AddOffersViewState();
}

class _AddOffersViewState extends State<AddOffersView>
    with WidgetsBindingObserver {
  final _scrollCtrl = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late final AddOfferManager m = widget.manager.addOfferManager;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    m.addListener(_onManagerChanged);
    m.prefillFromCurrentUser();
  }

  void _onManagerChanged() {
    if (!mounted) return;

    setState(() {});

    if (m.lastError != null) {
      final err = m.lastError!;
      m.clearError();

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

    if (m.lastCreatedOffer != null) {
      m.clearCreatedOffer();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showGlassDialog(
          title: 'Offre publiée',
          message: 'Votre offre a bien été publiée.',
          icon: Icons.check_circle_outline,
          iconBg: const Color(0xFFE8F7EC),
          iconColor: Colors.green,
        );
        if (!mounted) return;
        m.clearForm();
      });
    }
  }

  String _mapErrorMessage(String code) {
    switch (code) {
      case 'network_error':
        return 'Impossible de communiquer avec le serveur.';
      case 'add_offer_failed':
        return 'Impossible de publier cette offre.';
      case 'exception':
        return 'Une erreur inattendue est survenue.';
      default:
        return code;
    }
  }

  bool get _isProUser {
    return widget.manager.currentUser?.isPro == true;
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

  @override
  void dispose() {
    m.removeListener(_onManagerChanged);
    WidgetsBinding.instance.removeObserver(this);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _gap([double h = 12]) => SizedBox(height: h);

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (images.isEmpty) return;

    for (final x in images.take(m.remainingPhotos)) {
      await m.addImageFromXFile(x);
    }
  }

  Future<void> _takePhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (x == null) return;
    await m.addImageFromXFile(x);
  }

  Future<void> _choosePhotoSource() async {
    if (m.remainingPhotos <= 0) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () async {
                  Navigator.pop(context);
                  await _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLimitInfo() {
    return _glassContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Limite d’offres',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Votre compte client peut publier jusqu’à 5 offres. Passez pro pour augmenter cette limite.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoTile(int i) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            m.photoBytes[i],
            width: 86,
            height: 86,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: () => m.removeImage(i),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotos() {
    return _glassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Photos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Optionnel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          _gap(),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < m.photoBytes.length; i++) _photoTile(i),
              if (m.photoBytes.length < AddOfferManager.maxPhotos)
                InkWell(
                  onTap: _choosePhotoSource,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(.2),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        TextInputType? keyboardType,
        int maxLines = 1,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.4),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          color: Colors.amberAccent,
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<OfferPriceUnit>(
      value: m.selectedUnit,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Unité de prix',
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.4),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          color: Colors.amberAccent,
        ),
      ),
      items: OfferPriceUnit.values
          .map(
            (e) => DropdownMenuItem<OfferPriceUnit>(
          value: e,
          child: Text(e.label),
        ),
      )
          .toList(),
      validator: (v) {
        if (v == null) return 'Unité de prix obligatoire';
        return null;
      },
      onChanged: m.setUnit,
    );
  }

  Widget _buildForm() {
    return _glassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(
              m.titreCtrl,
              'Titre',
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Titre obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              m.metierCtrl,
              'Métier',
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Métier obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              m.wilayaCtrl,
              'Wilaya',
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Wilaya obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              m.communeCtrl,
              'Commune',
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Commune obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              m.phoneCtrl,
              'Numéro de téléphone',
              keyboardType: TextInputType.phone,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Numéro obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              m.experienceCtrl,
              'Années d’expérience',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Expérience obligatoire';
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'L’expérience doit contenir uniquement des chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              m.prixCtrl,
              'Prix',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Prix obligatoire';
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Le prix doit contenir uniquement des chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildUnitDropdown(),
            const SizedBox(height: 12),
            _field(
              m.descCtrl,
              'Description',
              maxLines: 5,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Description obligatoire';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await m.publish();
  }

  Widget _buildActions() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: m.isSaving ? null : _submit,
        child: m.isSaving
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.black,
          ),
        )
            : const Text(
          'Publier',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(0),
      children: [
        if (!_isProUser) ...[
          _buildLimitInfo(),
          const SizedBox(height: 12),
        ],
        _buildPhotos(),
        const SizedBox(height: 12),
        _buildForm(),
        const SizedBox(height: 16),
        _buildActions(),
        const SizedBox(height: 60),
      ],
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