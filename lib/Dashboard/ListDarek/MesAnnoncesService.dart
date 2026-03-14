import 'dart:async';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';

class MesAnnoncesService {
  final Manager _manager;
  final HelperService _helper;

  MesAnnoncesService(this._manager, this._helper);

  static const String listEndpoint = '/renovily/btp/mes-annonces/list';
  static const String updateEndpoint = '/renovily/btp/mes-annonces/update';
  static const String deleteEndpoint = '/renovily/btp/mes-annonces/delete';

  final List<Map<String, dynamic>> _mockJson = [
    {
      "id": 1,
      "titre": "Plombier à domicile",
      "description": "Réparation fuite et installation sanitaire.",
      "wilaya": "Alger",
      "commune": "Bab Ezzouar",
      "metier": "Plombier",
      "is_pro": 1,
      "name_pro": "SARL HydroFix",
      "experience_annees": 8,
      "prix": 2500,
      "unite_prix": "jour",
      "images": [
        {
          "url":
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952"
        }
      ],
      "avis": [
        {
          "prenom": "Karim",
          "message": "Travail rapide et propre",
          "note": 5,
          "indice_finition": 9.1,
          "created_at": "2024-01-03T10:00:00"
        }
      ],
      "created_at": "2024-01-01T10:00:00"
    },
    {
      "id": 2,
      "titre": "Peinture intérieure",
      "description": "Peinture murs et plafonds, finition propre.",
      "wilaya": "Oran",
      "commune": "Es Senia",
      "metier": "Peintre",
      "is_pro": 0,
      "name_pro": "",
      "experience_annees": 5,
      "prix": 900,
      "unite_prix": "m²",
      "images": [
        {
          "url":
          "https://images.unsplash.com/photo-1562259949-e8e7689d7828"
        }
      ],
      "avis": [
        {
          "prenom": "Meriem",
          "message": "Résultat propre",
          "note": 4,
          "indice_finition": 8.0,
          "created_at": "2024-01-05T15:00:00"
        }
      ],
      "created_at": "2024-01-05T10:00:00"
    },
    {
      "id": 3,
      "titre": "Maçon gros œuvre",
      "description": "Construction et rénovation maison.",
      "wilaya": "Blida",
      "commune": "Boufarik",
      "metier": "Maçon",
      "is_pro": 1,
      "name_pro": "BTP Atlas",
      "experience_annees": 12,
      "prix": 3500,
      "unite_prix": "m²",
      "images": [
        {
          "url":
          "https://images.unsplash.com/photo-1541888946425-d81bb19240f5"
        }
      ],
      "avis": [
        {
          "prenom": "Yacine",
          "message": "Très bonne finition",
          "note": 5,
          "indice_finition": 9.4,
          "created_at": "2024-01-08T12:00:00"
        }
      ],
      "created_at": "2024-01-08T10:00:00"
    }
  ];

  Future<List<DarekModel>> getMesAnnonces() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockJson.map((e) => DarekModel.fromJson(e)).toList();
  }

  Future<DarekModel?> updateAnnonce(DarekModel item) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final index =
    _mockJson.indexWhere((e) => e['id'].toString() == item.id.toString());

    if (index == -1) return null;

    _mockJson[index] = item.toJson();
    return DarekModel.fromJson(_mockJson[index]);
  }

  Future<bool> deleteAnnonce(String annonceId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final before = _mockJson.length;
    _mockJson.removeWhere((e) => e['id'].toString() == annonceId.toString());
    return _mockJson.length < before;
  }
}
