import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Offre/DarekModel.dart';
import 'AddOfferService.dart';

class AddOfferManager extends ChangeNotifier {
  static const int maxPhotos = 10;

  final AddOfferService _service;
  final Manager _manager;

  AddOfferManager(this._manager, HelperService helper)
      : _service = AddOfferService(_manager, helper);

  final TextEditingController titreCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController wilayaCtrl = TextEditingController();
  final TextEditingController communeCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController metierCtrl = TextEditingController();
  final TextEditingController experienceCtrl = TextEditingController();
  final TextEditingController prixCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  bool isSaving = false;
  String? lastError;
  OfferModel? lastCreatedOffer;

  OfferPriceUnit? selectedUnit = OfferPriceUnit.service;

  final List<AddDarekUploadFile> _images = [];

  List<AddDarekUploadFile> get images => List.unmodifiable(_images);

  List<Uint8List> get photoBytes => _images.map((e) => e.bytes).toList();

  int get remainingPhotos => maxPhotos - _images.length;

  bool get currentUserIsPro => _manager.currentUser?.isPro == true;

  String get currentUserNamePro =>
      (_manager.currentUser?.proProfile?.tradeName ?? '').toString().trim();

  String get currentUserPhone =>
      (_manager.currentUser?.number ?? '').toString().trim();

  String get currentUserWilaya =>
      (_manager.currentUser?.wilaya ?? '').toString().trim();

  String get currentUserCommune =>
      (_manager.currentUser?.commune ?? '').toString().trim();

  void prefillFromCurrentUser() {
    if (wilayaCtrl.text.trim().isEmpty) {
      wilayaCtrl.text = currentUserWilaya;
    }
    if (communeCtrl.text.trim().isEmpty) {
      communeCtrl.text = currentUserCommune;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      phoneCtrl.text = currentUserPhone;
    }
    notifyListeners();
  }

  void setUnit(OfferPriceUnit? value) {
    selectedUnit = value;
    notifyListeners();
  }

  Future<void> addImageFromXFile(XFile file) async {
    if (_images.length >= maxPhotos) return;

    final bytes = await file.readAsBytes();
    addImage(
      file.name,
      bytes,
      _guessMime(file.name),
    );
  }

  void addImage(String filename, Uint8List bytes, String mime) {
    if (_images.length >= maxPhotos) return;

    _images.add(
      AddDarekUploadFile(
        filename: filename,
        bytes: bytes,
        mime: mime,
      ),
    );
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    notifyListeners();
  }

  String _guessMime(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<OfferModel?> addAnnonce({
    required String titre,
    required String description,
    required String wilaya,
    required String commune,
    required String phone,
    required String metier,
    required int experienceAnnees,
    int? prix,
    OfferPriceUnit? unitePrix,
    OfferStatus? status,
    List<AddDarekUploadFile> images = const [],
  }) async {
    if (isSaving) return null;

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final res = await _service.addAnnonce(
        titre: titre,
        description: description,
        wilaya: wilaya,
        commune: commune,
        metier: metier,
        namePro: currentUserNamePro,
        phone: phone,
        experienceAnnees: experienceAnnees,
        prix: prix,
        unitePrix: unitePrix,
        status: status,
        images: images,
      );

      if (!res.success) {
        lastError = res.message.isNotEmpty ? res.message : 'add_offer_failed';
        lastCreatedOffer = null;
        return null;
      }

      lastCreatedOffer = res.data;
      return res.data;
    } catch (_) {
      lastError = 'exception';
      lastCreatedOffer = null;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<OfferModel?> publish() async {
    final titre = titreCtrl.text.trim();
    final description = descCtrl.text.trim();
    final wilaya = wilayaCtrl.text.trim();
    final commune = communeCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final metier = metierCtrl.text.trim();

    final experienceAnnees = int.tryParse(experienceCtrl.text.trim()) ?? 0;
    final prix = int.tryParse(prixCtrl.text.trim());

    return addAnnonce(
      titre: titre,
      description: description,
      wilaya: wilaya,
      commune: commune,
      phone: phone,
      metier: metier,
      experienceAnnees: experienceAnnees,
      prix: prix,
      unitePrix: selectedUnit,
      status: OfferStatus.pending,
      images: _images,
    );
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }

  void clearCreatedOffer() {
    lastCreatedOffer = null;
    notifyListeners();
  }

  void clearForm() {
    titreCtrl.clear();
    descriptionCtrl.clear();
    wilayaCtrl.text = currentUserWilaya;
    communeCtrl.text = currentUserCommune;
    phoneCtrl.text = currentUserPhone;
    metierCtrl.clear();
    experienceCtrl.clear();
    prixCtrl.clear();
    descCtrl.clear();

    selectedUnit = OfferPriceUnit.service;
    _images.clear();
    lastError = null;
    lastCreatedOffer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titreCtrl.dispose();
    descriptionCtrl.dispose();
    wilayaCtrl.dispose();
    communeCtrl.dispose();
    phoneCtrl.dispose();
    metierCtrl.dispose();
    experienceCtrl.dispose();
    prixCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}

class AddDarekUploadFile {
  final String filename;
  final Uint8List bytes;
  final String mime;

  const AddDarekUploadFile({
    required this.filename,
    required this.bytes,
    required this.mime,
  });

  bool get isWebp =>
      mime.toLowerCase() == 'image/webp' ||
          filename.toLowerCase().endsWith('.webp');
}