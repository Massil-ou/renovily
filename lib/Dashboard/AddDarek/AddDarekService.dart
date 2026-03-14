import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../App/BaseResponse.dart';
import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';
import 'AddDarekManager.dart';

class AddDarekService {
  final Manager _manager;
  final HelperService _auth;

  AddDarekService(this._manager, this._auth);

  static const String endpoint = '/renovily/offers/add';

  static const int _webpQuality = 70;
  static const int _minWidth = 1280;
  static const int _minHeight = 1280;

  Future<Uint8List> _toWebp70(Uint8List inputBytes) async {
    try {
      final out = await FlutterImageCompress.compressWithList(
        inputBytes,
        format: CompressFormat.webp,
        quality: _webpQuality,
        minWidth: _minWidth,
        minHeight: _minHeight,
        keepExif: false,
      );

      if (out.isEmpty) return inputBytes;
      return Uint8List.fromList(out);
    } catch (_) {
      return inputBytes;
    }
  }

  String _toWebpFilename(String original) {
    final base = p.basenameWithoutExtension(
      original.isEmpty ? 'image' : original,
    );
    return '$base.webp';
  }

  Future<BaseResponse<OfferModel>> addAnnonce({
    required String titre,
    required String description,
    required String wilaya,
    required String commune,
    required String metier,
    required bool isPro,
    required String namePro,
    required int experienceAnnees,
    int? prix,
    OfferPriceUnit? unitePrix,
    OfferStatus? status,
    List<AddDarekUploadFile> images = const [],
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('titre', titre.trim()),
        MapEntry('description', description.trim()),
        MapEntry('wilaya', wilaya.trim()),
        MapEntry('commune', commune.trim()),
        MapEntry('metier', metier.trim()),
        MapEntry('is_pro', isPro ? '1' : '0'),
        MapEntry('name_pro', namePro.trim()),
        MapEntry('experience_annees', experienceAnnees.toString()),
        MapEntry('status', (status ?? OfferStatus.pending).value),
      ]);

      if (prix != null) {
        formData.fields.add(
          MapEntry('prix', prix.toString()),
        );
      }

      if (unitePrix != null) {
        formData.fields.add(
          MapEntry('unite_prix', unitePrix.value),
        );
      }

      for (final img in images) {
        Uint8List bytesToSend = img.bytes;
        String filename = img.filename;
        String mime = img.mime;

        if (!img.isWebp) {
          bytesToSend = await _toWebp70(img.bytes);
          filename = _toWebpFilename(img.filename);
          mime = 'image/webp';
        }

        formData.files.add(
          MapEntry(
            'images[]',
            MultipartFile.fromBytes(
              bytesToSend,
              filename: filename,
              contentType: MediaType.parse(mime),
            ),
          ),
        );
      }

      final res = await _auth.dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final raw = res.data;

      final Map<String, dynamic> map = raw is Map<String, dynamic>
          ? raw
          : Map<String, dynamic>.from(
        jsonDecode(raw.toString()) as Map,
      );

      if (map['success'] != true) {
        return BaseResponse<OfferModel>(
          success: false,
          message: (map['message'] ?? 'request_failed').toString(),
          code: map['code'] is int
              ? map['code'] as int
              : int.tryParse(map['code']?.toString() ?? '') ?? -1,
          data: null,
        );
      }

      final data = map['data'];
      final idoffer = data is Map ? data['idoffer']?.toString() ?? '' : '';
      final createdImages = <OfferImage>[];

      if (data is Map && data['images'] is List) {
        for (final e in (data['images'] as List)) {
          if (e != null) {
            createdImages.add(
              OfferImage(url: e.toString()),
            );
          }
        }
      }

      final model = OfferModel(
        id: idoffer,
        titre: titre.trim(),
        description: description.trim(),
        wilaya: wilaya.trim(),
        commune: commune.trim(),
        metier: metier.trim(),
        isPro: isPro,
        namePro: namePro.trim(),
        status: status ?? OfferStatus.pending,
        experienceAnnees: experienceAnnees,
        prix: prix,
        unitePrix: unitePrix,
        images: createdImages,
        avis: const [],
        createdAt: DateTime.now(),
      );

      return BaseResponse<OfferModel>(
        success: true,
        message: (map['message'] ?? '').toString(),
        code: map['code'] is int
            ? map['code'] as int
            : int.tryParse(map['code']?.toString() ?? '') ?? 0,
        data: model,
      );
    } catch (_) {
      return BaseResponse<OfferModel>(
        success: false,
        message: 'network_error',
        code: -1,
        data: null,
      );
    }
  }
}
