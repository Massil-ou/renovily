import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import 'AddDarekService.dart';

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

class AddDarekManager extends ChangeNotifier {
  final AddDarekService _service;

  AddDarekManager(Manager manager, HelperService helper)
      : _service = AddDarekService(manager, helper);

  final titreCtrl = TextEditingController();
  final metierCtrl = TextEditingController();
  final wilayaCtrl = TextEditingController();
  final communeCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final prixCtrl = TextEditingController();
  final uniteCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final List<XFile> pickedFiles = [];
  final List<Uint8List> photoBytes = [];

  static const int maxPhotos = 5;

  int get remainingPhotos => maxPhotos - photoBytes.length;

  bool isPro = false;
  bool loading = false;
  bool success = false;
  String? lastError;

  void addImage(XFile file, Uint8List bytes) {
    if (photoBytes.length >= maxPhotos) return;
    pickedFiles.add(file);
    photoBytes.add(bytes);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= pickedFiles.length) return;
    pickedFiles.removeAt(index);
    photoBytes.removeAt(index);
    notifyListeners();
  }

  void clear() {
    pickedFiles.clear();
    photoBytes.clear();

    titreCtrl.clear();
    metierCtrl.clear();
    wilayaCtrl.clear();
    communeCtrl.clear();
    experienceCtrl.clear();
    prixCtrl.clear();
    uniteCtrl.clear();
    descCtrl.clear();

    isPro = false;
    loading = false;
    success = false;
    lastError = null;
    notifyListeners();
  }

  Future<void> publish(Manager manager) async {
    if (loading) return;

    loading = true;
    success = false;
    lastError = null;
    notifyListeners();

    try {
      final images = <AddDarekUploadFile>[];

      for (int i = 0; i < photoBytes.length; i++) {
        final file = pickedFiles[i];
        images.add(
          AddDarekUploadFile(
            filename: file.name,
            bytes: photoBytes[i],
            mime: 'image/jpeg',
          ),
        );
      }

      final res = await _service.addAnnonce(
        titre: titreCtrl.text.trim(),
        description: descCtrl.text.trim(),
        wilaya: wilayaCtrl.text.trim(),
        commune: communeCtrl.text.trim(),
        metier: metierCtrl.text.trim(),
        isPro: isPro,
        namePro: manager.currentUser?.proProfile?.tradeName?.trim().isNotEmpty ==
            true
            ? manager.currentUser!.proProfile!.tradeName!.trim()
            : '',
        experienceAnnees: int.tryParse(
          experienceCtrl.text.trim().isEmpty ? '0' : experienceCtrl.text.trim(),
        ) ??
            0,
        prix: double.tryParse(prixCtrl.text.trim()),
        unitePrix: uniteCtrl.text.trim().isEmpty ? null : uniteCtrl.text.trim(),
        images: images,
      );

      if (res.success) {
        success = true;
      } else {
        lastError = res.message ?? 'publish_failed';
      }
    } catch (_) {
      lastError = 'network_error';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titreCtrl.dispose();
    metierCtrl.dispose();
    wilayaCtrl.dispose();
    communeCtrl.dispose();
    experienceCtrl.dispose();
    prixCtrl.dispose();
    uniteCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}
