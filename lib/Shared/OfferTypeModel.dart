class OfferTypeData {
  final int id;
  final String code;
  final String label;
  final String target; // client | pro | all
  final int priceDa;
  final int? durationDays;
  final bool isActive;
  final List<String> description; // avantages
  final String? createdAt;

  OfferTypeData({
    required this.id,
    required this.code,
    required this.label,
    required this.target,
    required this.priceDa,
    required this.durationDays,
    required this.isActive,
    required this.description,
    this.createdAt,
  });

  factory OfferTypeData.fromJson(Map<String, dynamic> json) {
    List<String> desc = const [];

    final rawDesc = json['description'];
    if (rawDesc is List) {
      desc = rawDesc
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawDesc is String) {
      // si jamais l'API renvoie texte (fallback)
      final s = rawDesc.trim();
      desc = s.isEmpty ? const [] : [s];
    }

    return OfferTypeData(
      id: _asInt(json['id']),
      code: (json['code'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      target: (json['target'] ?? 'all').toString(),
      priceDa: _asInt(json['price_da'] ?? json['priceDa']),
      durationDays: _asNullableInt(
        json['duration_days'] ?? json['durationDays'],
      ),
      isActive: _asBool(json['is_active'] ?? json['isActive']),
      description: desc,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'label': label,
    'target': target,
    'price_da': priceDa,
    'duration_days': durationDays,
    'is_active': isActive ? 1 : 0,
    'description': description,
    'created_at': createdAt,
  };

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse((v ?? '0').toString()) ?? 0;
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    final s = (v ?? '').toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }
}
