import '../App/HelperService.dart';
import '../App/Manager.dart';
import 'DarekModel.dart';

class DarekService {
  final Manager _manager;
  final HelperService _helper;

  DarekService(this._manager, this._helper);

  static const String pathAll = '/btp/annonces_all';
  static const String pathSearch = '/btp/annonces_search';

  /// DATA MOCK
  List<Map<String, dynamic>> _mockJson() {
    return [
      {
        "id": "annonce-1",
        "titre": "Plombier disponible urgence",
        "description": "Réparation fuite, installation sanitaire",
        "wilaya": "Alger",
        "commune": "Bab Ezzouar",
        "metier": "Plombier",
        "is_pro": true,
        "name_pro": "Société HydroFix",
        "status": "active",
        "experience_annees": 8,
        "prix": 2500,
        "unite_prix": "jour",
        "avis": [
          {
            "prenom": "Karim",
            "message": "Travail rapide et propre",
            "note": 5,
            "indice_finition": 9.2,
            "created_at": "2024-02-05T10:30:00"
          },
          {
            "prenom": "Lina",
            "message": "Bonne intervention, rien à signaler",
            "note": 4,
            "indice_finition": 8.4,
            "created_at": "2024-02-06T14:00:00"
          }
        ],
        "images": [
          {
            "url": "https://images.unsplash.com/photo-1581578731548-c64695cc6952"
          },
          {
            "url": "https://images.unsplash.com/photo-1503387762-592deb58ef4e"
          }
        ],
        "created_at": "2024-02-01T10:00:00"
      },
      {
        "id": "annonce-2",
        "titre": "Electricien bâtiment",
        "description": "Installation tableau électrique et dépannage",
        "wilaya": "Oran",
        "commune": "Es Senia",
        "metier": "Electricien",
        "is_pro": false,
        "name_pro": "",
        "status": "pending",
        "experience_annees": 3,
        "prix": 1800,
        "unite_prix": "jour",
        "avis": [
          {
            "prenom": "Samir",
            "message": "Service correct",
            "note": 4,
            "indice_finition": 7.8,
            "created_at": "2024-02-07T09:00:00"
          },
          {
            "prenom": "Nora",
            "message": "Petit retard mais travail sérieux",
            "note": 3,
            "indice_finition": 6.9,
            "created_at": "2024-02-08T16:20:00"
          }
        ],
        "images": [
          {
            "url": "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789"
          }
        ],
        "created_at": "2024-02-02T09:00:00"
      },
      {
        "id": "annonce-3",
        "titre": "Maçon travaux maison",
        "description": "Construction mur, dalle béton",
        "wilaya": "Blida",
        "commune": "Boufarik",
        "metier": "Maçon",
        "is_pro": true,
        "name_pro": "BTP Construction DZ",
        "status": "active",
        "experience_annees": 12,
        "prix": 3500,
        "unite_prix": "m2",
        "avis": [
          {
            "prenom": "Yacine",
            "message": "Très bonne finition",
            "note": 5,
            "indice_finition": 9.5,
            "created_at": "2024-02-09T11:45:00"
          },
          {
            "prenom": "Sofia",
            "message": "Travail solide et propre",
            "note": 5,
            "indice_finition": 9.3,
            "created_at": "2024-02-10T13:10:00"
          },
          {
            "prenom": "Adel",
            "message": "Bon maçon, sérieux",
            "note": 4,
            "indice_finition": 8.8,
            "created_at": "2024-02-11T08:15:00"
          }
        ],
        "images": [
          {
            "url": "https://images.unsplash.com/photo-1541888946425-d81bb19240f5"
          }
        ],
        "created_at": "2024-02-03T11:00:00"
      },
      {
        "id": "annonce-4",
        "titre": "Peinture maison complète",
        "description": "Peinture intérieure et extérieure",
        "wilaya": "Alger",
        "commune": "Draria",
        "metier": "Peintre",
        "is_pro": false,
        "name_pro": "",
        "status": "rejected",
        "experience_annees": 5,
        "prix": 900,
        "unite_prix": "m2",
        "avis": [
          {
            "prenom": "Meriem",
            "message": "Résultat propre",
            "note": 4,
            "indice_finition": 8.0,
            "created_at": "2024-02-12T15:00:00"
          }
        ],
        "images": [
          {
            "url": "https://images.unsplash.com/photo-1562259949-e8e7689d7828"
          }
        ],
        "created_at": "2024-02-04T12:00:00"
      }
    ];
  }

  /// Charger toutes les annonces
  Future<List<DarekModel>> fetchAnnonces() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final raw = _mockJson();

    return raw
        .map((e) => DarekModel.fromJson(e))
        .toList(growable: false);
  }

  /// Recherche mock avec filtres complets
  Future<List<DarekModel>> searchAnnonces({
    String q = '',
    required List<String> wilayas,
    required List<String> communes,
    List<String> metiers = const [],
    double? prixMin,
    double? prixMax,
    bool? isPro,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final all = _mockJson()
        .map((e) => DarekModel.fromJson(e))
        .toList(growable: false);

    final query = q.trim().toLowerCase();

    return all.where((a) {
      final matchQ = query.isEmpty ||
          a.titre.toLowerCase().contains(query) ||
          a.description.toLowerCase().contains(query) ||
          a.metier.toLowerCase().contains(query) ||
          a.wilaya.toLowerCase().contains(query) ||
          a.commune.toLowerCase().contains(query) ||
          a.namePro.toLowerCase().contains(query);

      final matchWilaya =
          wilayas.isEmpty || wilayas.contains(a.wilaya);

      final matchCommune =
          communes.isEmpty || communes.contains(a.commune);

      final matchMetier =
          metiers.isEmpty || metiers.contains(a.metier);

      final matchPrixMin =
          prixMin == null || (a.prix != null && a.prix! >= prixMin);

      final matchPrixMax =
          prixMax == null || (a.prix != null && a.prix! <= prixMax);

      final matchIsPro =
          isPro == null || a.isPro == isPro;

      return matchQ &&
          matchWilaya &&
          matchCommune &&
          matchMetier &&
          matchPrixMin &&
          matchPrixMax &&
          matchIsPro;
    }).toList(growable: false);
  }
}
