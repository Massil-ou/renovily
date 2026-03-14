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

  static const String _endpoint = '/renovily/btp/annonces_create';

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
    final base =
    p.basenameWithoutExtension(original.isEmpty ? 'image' : original);
    return '$base.webp';
  }

  Future<BaseResponse<DarekModel>> addAnnonce({
    required String titre,
    required String description,
    required String wilaya,
    required String commune,
    required String metier,
    required bool isPro,
    required String namePro,
    required int experienceAnnees,
    double? prix,
    String? unitePrix,
    List<AddDarekUploadFile> images = const [],
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('titre', titre),
        MapEntry('description', description),
        MapEntry('wilaya', wilaya),
        MapEntry('commune', commune),
        MapEntry('metier', metier),
        MapEntry('is_pro', isPro ? '1' : '0'),
        MapEntry('name_pro', namePro),
        MapEntry('experience_annees', experienceAnnees.toString()),
      ]);

      if (prix != null) {
        formData.fields.add(MapEntry('prix', prix.toString()));
      }

      if (unitePrix != null && unitePrix.trim().isNotEmpty) {
        formData.fields.add(MapEntry('unite_prix', unitePrix.trim()));
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
        _endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final raw = res.data;

      final Map<String, dynamic> map = raw is Map<String, dynamic>
          ? raw
          : (jsonDecode(raw.toString()) as Map<String, dynamic>);

      return BaseResponse.fromJson<DarekModel>(
        map,
        parse: (j) => DarekModel.fromJson(j),
      );
    } catch (_) {
      return BaseResponse<DarekModel>(
        success: false,
        message: 'network_error',
        code: -1,
        data: null,
      );
    }
  }
}
