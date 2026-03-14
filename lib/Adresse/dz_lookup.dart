import 'DzWillayas.dart';

class DzLookupService {
  static final DzLookupService _instance = DzLookupService._internal();
  factory DzLookupService() => _instance;

  DzLookupService._internal() {
    if (!_initialized) {
      init([
        ...dzWilayasPart1,
        ...dzWilayasPart2,
        ...dzWilayasPart3,
        ...dzWilayasPart4,
        ...dzWilayasPart5,
        ...dzWilayasPart6,
        ...dzWilayasPart7,
        ...dzWilayasPart8,
        ...dzWilayasPart9,
        ...dzWilayasPart10,
      ]);
    }
  }

  int? wilayaNumberFromName(String wilayaName) {
    if (!_initialized) return null;

    final raw = wilayaName.trim();
    if (raw.isEmpty) return null;

    final asInt = int.tryParse(raw);
    if (asInt != null && asInt >= 1 && asInt <= 69) return asInt;

    for (final w in _data) {
      if (raw == w.latinName || raw == w.arabicName) {
        return int.tryParse(w.code);
      }
    }

    final nraw = _norm(raw);
    for (final w in _data) {
      if (_norm(w.latinName) == nraw || _norm(w.arabicName) == nraw) {
        return int.tryParse(w.code);
      }
    }

    return null;
  }

  String? wilayaCodeFromName(String wilayaName) {
    final n = wilayaNumberFromName(wilayaName);
    if (n == null) return null;
    return n.toString().padLeft(2, '0');
  }

  bool _initialized = false;

  late List<DzWilaya> _data;
  late Map<String, List<String>> _byLatin;
  late Map<String, List<String>> _byArabic;
  late Map<String, List<String>> _byCode;
  late Map<String, List<String>> _byLatinNormalized;
  late List<String> _wilayasFROrdered;
  late List<String> _wilayasAROrdered;

  bool get isInitialized => _initialized;

  void init(List<DzWilaya> allWilayas) {
    if (allWilayas.isEmpty) {
      _data = const [];
      _byLatin = const {};
      _byArabic = const {};
      _byCode = const {};
      _byLatinNormalized = const {};
      _wilayasFROrdered = const [];
      _wilayasAROrdered = const [];
      _initialized = true;
      return;
    }

    _data = List<DzWilaya>.unmodifiable(allWilayas);

    List<String> uniq(List<String> list) {
      final seen = <String>{};
      final out = <String>[];
      for (final x in list) {
        final t = x.trim();
        if (t.isEmpty) continue;
        if (seen.add(t)) out.add(t);
      }
      return List<String>.unmodifiable(out);
    }

    _byLatin = {
      for (final w in _data)
        w.latinName: uniq([for (final c in w.communes) c.latin]),
    };

    _byArabic = {
      for (final w in _data)
        w.arabicName: uniq([for (final c in w.communes) c.arabic]),
    };

    _byCode = {
      for (final w in _data)
        w.code.padLeft(2, '0'): uniq([for (final c in w.communes) c.latin]),
    };

    _byLatinNormalized = {
      for (final w in _data)
        _norm(w.latinName): uniq([for (final c in w.communes) c.latin]),
    };

    _wilayasFROrdered = List<String>.unmodifiable(
      _data.map((w) => w.latinName).toList()..sort(_compareFR),
    );

    _wilayasAROrdered = List<String>.unmodifiable(
      _data.map((w) => w.arabicName).toList()..sort(),
    );

    _initialized = true;
  }

  List<String> wilayas({bool arabic = false}) {
    if (!_initialized) return const [];
    return arabic ? _wilayasAROrdered : _wilayasFROrdered;
  }

  List<String> getCommunes(String wilaya, {bool arabic = false}) {
    if (!_initialized) return const [];
    final key = wilaya.trim();
    if (key.isEmpty) return const [];

    final code = key.padLeft(2, '0');
    final byCode = _byCode[code];
    if (byCode != null && !arabic) return byCode;

    final fr = _byLatin[key];
    if (fr != null && !arabic) return fr;

    final ar = _byArabic[key];
    if (ar != null && arabic) return ar;

    final n = _byLatinNormalized[_norm(key)];
    if (n != null && !arabic) return n;

    if (arabic && ar != null) return ar;
    if (!arabic && fr != null) return fr;

    return const [];
  }

  int _compareFR(String a, String b) => _norm(a).compareTo(_norm(b));

  String _norm(String s) {
    final lower = s.toLowerCase();
    return lower
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ñ', 'n')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ÿ', 'y')
        .replaceAll('’', "'")
        .replaceAll('ʼ', "'")
        .replaceAll('`', "'")
        .replaceAll('´', "'")
        .trim();
  }
}
