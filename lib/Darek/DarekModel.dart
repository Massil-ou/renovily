class DarekModel {
  final String id;
  final String titre;
  final String description;
  final String wilaya;
  final String commune;
  final String metier;
  final bool isPro;
  final String namePro;
  final String status;
  final int experienceAnnees;
  final double? prix;
  final String? unitePrix;
  final List<DarekImage> images;
  final DateTime? createdAt;
  final List<DarekAvis> avis;

  const DarekModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.wilaya,
    required this.commune,
    required this.metier,
    required this.isPro,
    required this.namePro,
    required this.status,
    required this.experienceAnnees,
    required this.images,
    required this.avis,
    this.prix,
    this.unitePrix,
    this.createdAt,
  });

  factory DarekModel.fromJson(Map<String, dynamic> json) {
    return DarekModel(
      id: (json['id'] ?? '').toString().trim(),
      titre: (json['titre'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      wilaya: (json['wilaya'] ?? '').toString().trim(),
      commune: (json['commune'] ?? '').toString().trim(),
      metier: (json['metier'] ?? '').toString().trim(),
      isPro: json['is_pro'] == true ||
          json['is_pro'] == 1 ||
          json['is_pro'] == "1",
      namePro: (json['name_pro'] ?? '').toString().trim(),
      status: (json['status'] ?? 'active').toString().trim(),
      experienceAnnees: json['experience_annees'] is int
          ? json['experience_annees'] as int
          : int.tryParse(json['experience_annees']?.toString() ?? '') ?? 0,
      prix: json['prix'] != null
          ? double.tryParse(json['prix'].toString())
          : null,
      unitePrix: json['unite_prix']?.toString(),
      images: (json['images'] as List? ?? [])
          .map((e) => DarekImage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      avis: (json['avis'] as List? ?? [])
          .map((e) => DarekAvis.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'wilaya': wilaya,
      'commune': commune,
      'metier': metier,
      'is_pro': isPro,
      'name_pro': namePro,
      'status': status,
      'experience_annees': experienceAnnees,
      'prix': prix,
      'unite_prix': unitePrix,
      'images': images.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'avis': avis.map((e) => e.toJson()).toList(),
    };
  }

  int get nbAvis => avis.length;

  double get noteMoyenne {
    if (avis.isEmpty) return 0.0;
    final total = avis.fold<int>(0, (sum, item) => sum + item.note);
    return total / avis.length;
  }

  double get indiceFinitionMoyen {
    if (avis.isEmpty) return 1.0;
    final total = avis.fold<double>(
      0.0,
          (sum, item) => sum + item.indiceFinition,
    );
    return total / avis.length;
  }

  int get nb5Etoiles => avis.where((e) => e.note == 5).length;
  int get nb4Etoiles => avis.where((e) => e.note == 4).length;
  int get nb3Etoiles => avis.where((e) => e.note == 3).length;
  int get nb2Etoiles => avis.where((e) => e.note == 2).length;
  int get nb1Etoiles => avis.where((e) => e.note == 1).length;

  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isArchived => status.toLowerCase() == 'archived';
}

class DarekAvis {
  final String prenom;
  final String message;
  final int note; // 1 à 5
  final double indiceFinition; // 1.0 à 10.0
  final DateTime? createdAt;

  const DarekAvis({
    required this.prenom,
    required this.message,
    required this.note,
    required this.indiceFinition,
    this.createdAt,
  });

  factory DarekAvis.fromJson(Map<String, dynamic> json) {
    final rawNote = json['note'] is int
        ? json['note'] as int
        : int.tryParse(json['note']?.toString() ?? '') ?? 1;

    final rawIndice = json['indice_finition'] != null
        ? double.tryParse(json['indice_finition'].toString()) ?? 1.0
        : 1.0;

    return DarekAvis(
      prenom: (json['prenom'] ?? '').toString().trim(),
      message: (json['message'] ?? '').toString().trim(),
      note: rawNote < 1 ? 1 : (rawNote > 5 ? 5 : rawNote),
      indiceFinition: rawIndice < 1.0
          ? 1.0
          : (rawIndice > 10.0 ? 10.0 : rawIndice),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prenom': prenom,
      'message': message,
      'note': note,
      'indice_finition': indiceFinition,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class DarekImage {
  final String url;

  const DarekImage({
    required this.url,
  });

  factory DarekImage.fromJson(Map<String, dynamic> json) {
    return DarekImage(
      url: (json['url'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}
