import 'dart:async';

import '../../App/HelperService.dart';
import '../../App/Manager.dart';
import '../../Darek/DarekModel.dart';

class FavorisAnnoncesService {
  final Manager _manager;
  final HelperService _helper;

  FavorisAnnoncesService(this._manager, this._helper);

  static const String getEndpoint = '/btp/favoris/list';
  static const String addEndpoint = '/btp/favoris/add';
  static const String deleteEndpoint = '/btp/favoris/delete';

  final List<Map<String, dynamic>> _mockFavoris = [
    {
      "id": 10,
      "titre": "Électricien bâtiment",
      "description":
      "Installation électrique complète, tableau, prises et dépannage.",
      "wilaya": "Alger",
      "commune": "Draria",
      "metier": "Électricien",
      "is_pro": 1,
      "name_pro": "ElectroFix",
      "experience_annees": 6,
      "prix": 1800,
      "unite_prix": "jour",
      "images": [
        {
          "url":
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4"
        }
      ],
      "avis": [
        {
          "prenom": "Nassim",
          "message": "Travail propre et sérieux",
          "note": 5,
          "indice_finition": 8.8,
          "created_at": "2024-01-03T10:00:00"
        },
        {
          "prenom": "Lina",
          "message": "Bonne intervention",
          "note": 4,
          "indice_finition": 8.0,
          "created_at": "2024-01-04T14:30:00"
        }
      ],
      "created_at": "2024-01-02T10:00:00"
    },
    {
      "id": 11,
      "titre": "Serrurier urgence",
      "description": "Ouverture porte blindée et dépannage serrurerie.",
      "wilaya": "Oran",
      "commune": "Bir El Djir",
      "metier": "Serrurier",
      "is_pro": 0,
      "name_pro": "",
      "experience_annees": 4,
      "prix": 1500,
      "unite_prix": "intervention",
      "images": [
        {
          "url":
          "https://images.unsplash.com/photo-1517048676732-d65bc937f952"
        }
      ],
      "avis": [
        {
          "prenom": "Samia",
          "message": "Rapide et efficace",
          "note": 4,
          "indice_finition": 7.6,
          "created_at": "2024-01-07T09:20:00"
        }
      ],
      "created_at": "2024-01-06T10:00:00"
    }
  ];

  Future<List<DarekModel>> getFavoris() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockFavoris.map((e) => DarekModel.fromJson(e)).toList();
  }

  Future<bool> addFavori(DarekModel item) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final exists =
    _mockFavoris.any((e) => e['id'].toString() == item.id.toString());
    if (exists) return true;

    _mockFavoris.add(item.toJson());
    return true;
  }

  Future<bool> deleteFavori(String annonceId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _mockFavoris
        .removeWhere((e) => e['id'].toString() == annonceId.toString());
    return true;
  }

  Future<bool> isFavori(String annonceId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _mockFavoris.any((e) => e['id'].toString() == annonceId.toString());
  }

  Future<bool> toggleFavori(DarekModel item) async {
    final exists = await isFavori(item.id);
    if (exists) {
      return deleteFavori(item.id);
    }
    return addFavori(item);
  }
}
