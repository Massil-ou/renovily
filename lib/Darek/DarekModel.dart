enum OfferStatus {
  pending,
  visible,
  deleted;

  String get value {
    switch (this) {
      case OfferStatus.pending:
        return 'pending';
      case OfferStatus.visible:
        return 'visible';
      case OfferStatus.deleted:
        return 'deleted';
    }
  }

  String get label {
    switch (this) {
      case OfferStatus.pending:
        return 'En attente';
      case OfferStatus.visible:
        return 'Visible';
      case OfferStatus.deleted:
        return 'Supprimé';
    }
  }

  static OfferStatus fromJson(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'visible':
        return OfferStatus.visible;
      case 'deleted':
        return OfferStatus.deleted;
      case 'pending':
      default:
        return OfferStatus.pending;
    }
  }
}

enum OfferPriceUnit {
  hour,
  day,
  service,
  unit,
  m2,
  m3,
  linearMeter;

  String get value {
    switch (this) {
      case OfferPriceUnit.hour:
        return 'hour';
      case OfferPriceUnit.day:
        return 'day';
      case OfferPriceUnit.service:
        return 'service';
      case OfferPriceUnit.unit:
        return 'unit';
      case OfferPriceUnit.m2:
        return 'm2';
      case OfferPriceUnit.m3:
        return 'm3';
      case OfferPriceUnit.linearMeter:
        return 'linear_meter';
    }
  }

  String get label {
    switch (this) {
      case OfferPriceUnit.hour:
        return 'Heure';
      case OfferPriceUnit.day:
        return 'Jour';
      case OfferPriceUnit.service:
        return 'Intervention';
      case OfferPriceUnit.unit:
        return 'Unité';
      case OfferPriceUnit.m2:
        return 'm²';
      case OfferPriceUnit.m3:
        return 'm³';
      case OfferPriceUnit.linearMeter:
        return 'Mètre linéaire';
    }
  }

  static OfferPriceUnit? fromJson(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'hour':
        return OfferPriceUnit.hour;
      case 'day':
        return OfferPriceUnit.day;
      case 'service':
        return OfferPriceUnit.service;
      case 'unit':
        return OfferPriceUnit.unit;
      case 'm2':
        return OfferPriceUnit.m2;
      case 'm3':
        return OfferPriceUnit.m3;
      case 'linear_meter':
        return OfferPriceUnit.linearMeter;
      default:
        return null;
    }
  }
}

class OfferModel {
  final String id;
  final String? idfavorite;
  final String titre;
  final String description;
  final String wilaya;
  final String commune;
  final String metier;
  final bool isPro;
  final String namePro;
  final OfferStatus status;
  final int experienceAnnees;
  final int? prix;
  final OfferPriceUnit? unitePrix;
  final List<OfferImage> images;
  final DateTime? createdAt;
  final List<OfferReviews> avis;

  const OfferModel({
    required this.id,
    this.idfavorite,
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

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: (json['id'] ?? '').toString().trim(),
      idfavorite: json['idfavorite']?.toString().trim(),
      titre: (json['titre'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      wilaya: (json['wilaya'] ?? '').toString().trim(),
      commune: (json['commune'] ?? '').toString().trim(),
      metier: (json['metier'] ?? '').toString().trim(),
      isPro: json['is_pro'] == true ||
          json['is_pro'] == 1 ||
          json['is_pro'] == '1',
      namePro: (json['name_pro'] ?? '').toString().trim(),
      status: OfferStatus.fromJson(json['status']),
      experienceAnnees: json['experience_annees'] is int
          ? json['experience_annees'] as int
          : int.tryParse(json['experience_annees']?.toString() ?? '') ?? 0,
      prix: json['prix'] is int
          ? json['prix'] as int
          : int.tryParse(json['prix']?.toString() ?? ''),
      unitePrix: OfferPriceUnit.fromJson(json['unite_prix']),
      images: (json['images'] as List? ?? [])
          .map((e) => OfferImage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      avis: (json['avis'] as List? ?? [])
          .map((e) => OfferReviews.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idfavorite': idfavorite,
      'titre': titre,
      'description': description,
      'wilaya': wilaya,
      'commune': commune,
      'metier': metier,
      'is_pro': isPro,
      'name_pro': namePro,
      'status': status.value,
      'experience_annees': experienceAnnees,
      'prix': prix,
      'unite_prix': unitePrix?.value,
      'images': images.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'avis': avis.map((e) => e.toJson()).toList(),
    };
  }

  OfferModel copyWith({
    String? id,
    String? idfavorite,
    String? titre,
    String? description,
    String? wilaya,
    String? commune,
    String? metier,
    bool? isPro,
    String? namePro,
    OfferStatus? status,
    int? experienceAnnees,
    int? prix,
    OfferPriceUnit? unitePrix,
    List<OfferImage>? images,
    DateTime? createdAt,
    List<OfferReviews>? avis,
  }) {
    return OfferModel(
      id: id ?? this.id,
      idfavorite: idfavorite ?? this.idfavorite,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      wilaya: wilaya ?? this.wilaya,
      commune: commune ?? this.commune,
      metier: metier ?? this.metier,
      isPro: isPro ?? this.isPro,
      namePro: namePro ?? this.namePro,
      status: status ?? this.status,
      experienceAnnees: experienceAnnees ?? this.experienceAnnees,
      prix: prix ?? this.prix,
      unitePrix: unitePrix ?? this.unitePrix,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      avis: avis ?? this.avis,
    );
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

  bool get isPending => status == OfferStatus.pending;
  bool get isVisible => status == OfferStatus.visible;
  bool get isDeleted => status == OfferStatus.deleted;
}

class OfferReviews {
  final String prenom;
  final String message;
  final int note;
  final double indiceFinition;
  final DateTime? createdAt;

  const OfferReviews({
    required this.prenom,
    required this.message,
    required this.note,
    required this.indiceFinition,
    this.createdAt,
  });

  factory OfferReviews.fromJson(Map<String, dynamic> json) {
    final rawNote = json['note'] is int
        ? json['note'] as int
        : int.tryParse(json['note']?.toString() ?? '') ?? 1;

    final rawIndice = json['indice_finition'] != null
        ? double.tryParse(json['indice_finition'].toString()) ?? 1.0
        : 1.0;

    return OfferReviews(
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

class OfferImage {
  final String url;

  const OfferImage({
    required this.url,
  });

  factory OfferImage.fromJson(Map<String, dynamic> json) {
    return OfferImage(
      url: (json['url'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}
