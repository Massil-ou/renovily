import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint;

import '../App/HelperService.dart';
import '../App/Manager.dart';
import 'DarekModel.dart';
import 'OfferService.dart';

class OffreManager {
  final OfferService _service;

  OffreManager(Manager manager, HelperService helper)
      : _service = OfferService(manager, helper);

  final ValueNotifier<List<OfferModel>> annonces =
  ValueNotifier<List<OfferModel>>([]);

  final ValueNotifier<List<OfferModel>> searchAnnonces =
  ValueNotifier<List<OfferModel>>([]);

  final ValueNotifier<bool> isSearchActive = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);
  final ValueNotifier<int> dataChangeVersion = ValueNotifier<int>(0);

  final ValueNotifier<String> selectedQ = ValueNotifier<String>('');
  final ValueNotifier<List<String>> selectedWilayas =
  ValueNotifier<List<String>>([]);
  final ValueNotifier<List<String>> selectedCommunes =
  ValueNotifier<List<String>>([]);
  final ValueNotifier<List<String>> selectedMetiers =
  ValueNotifier<List<String>>([]);
  final ValueNotifier<int?> selectedPrixMin = ValueNotifier<int?>(null);
  final ValueNotifier<int?> selectedPrixMax = ValueNotifier<int?>(null);
  final ValueNotifier<bool?> selectedIsPro = ValueNotifier<bool?>(null);

  void clearLastError() {
    lastError.value = null;
  }

  Future<void> init() async {
    await refreshInitialFromNetwork();
  }

  Future<void> refreshInitialFromNetwork() async {
    try {
      isLoading.value = true;
      clearLastError();

      final fresh = await _service.fetchAnnonces(limit: 100);

      annonces.value = List<OfferModel>.unmodifiable(fresh);
      isSearchActive.value = false;
      searchAnnonces.value = const [];

      selectedQ.value = '';
      selectedWilayas.value = [];
      selectedCommunes.value = [];
      selectedMetiers.value = [];
      selectedPrixMin.value = null;
      selectedPrixMax.value = null;
      selectedIsPro.value = null;

      _bump();
    } catch (e, st) {
      debugPrint('DarekManager.refreshInitialFromNetwork: $e\n$st');
      lastError.value = e.toString();
      _bump();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilters({
    String? q,
    List<String>? wilayas,
    List<String>? communes,
    List<String>? metiers,
    int? prixMin,
    int? prixMax,
    bool? isPro,
  }) async {
    try {
      isLoading.value = true;
      clearLastError();

      final selectedQuery = (q ?? '').trim();
      final selectedW = List<String>.from(wilayas ?? const []);
      final selectedC = List<String>.from(communes ?? const []);
      final selectedM = List<String>.from(metiers ?? const []);

      selectedQ.value = selectedQuery;
      selectedWilayas.value = selectedW;
      selectedCommunes.value = selectedC;
      selectedMetiers.value = selectedM;
      selectedPrixMin.value = prixMin;
      selectedPrixMax.value = prixMax;
      selectedIsPro.value = isPro;

      final hasActiveFilter = selectedQuery.isNotEmpty ||
          selectedW.isNotEmpty ||
          selectedC.isNotEmpty ||
          selectedM.isNotEmpty ||
          prixMin != null ||
          prixMax != null ||
          isPro != null;

      if (!hasActiveFilter) {
        isSearchActive.value = false;
        searchAnnonces.value = const [];
        _bump();
        return;
      }

      final results = await _service.searchAnnonces(
        q: selectedQuery,
        wilayas: selectedW,
        communes: selectedC,
        metiers: selectedM,
        prixMin: prixMin,
        prixMax: prixMax,
        isPro: isPro,
        limit: 100,
      );

      searchAnnonces.value = List<OfferModel>.unmodifiable(results);
      isSearchActive.value = true;

      _bump();
    } catch (e, st) {
      debugPrint('DarekManager.applyFilters: $e\n$st');
      lastError.value = e.toString();
      isSearchActive.value = false;
      searchAnnonces.value = const [];
      _bump();
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    selectedQ.value = '';
    selectedWilayas.value = [];
    selectedCommunes.value = [];
    selectedMetiers.value = [];
    selectedPrixMin.value = null;
    selectedPrixMax.value = null;
    selectedIsPro.value = null;

    isSearchActive.value = false;
    searchAnnonces.value = const [];
    lastError.value = null;

    _bump();
  }

  ValueNotifier<List<OfferModel>> get currentList =>
      isSearchActive.value ? searchAnnonces : annonces;

  List<OfferModel> displayedList() {
    return isSearchActive.value ? searchAnnonces.value : annonces.value;
  }

  OfferModel? displayedItemAt(int index) {
    final list = displayedList();
    if (index < 0 || index >= list.length) return null;
    return list[index];
  }

  void _bump() {
    dataChangeVersion.value = dataChangeVersion.value + 1;
  }

  void dispose() {
    annonces.dispose();
    searchAnnonces.dispose();
    isSearchActive.dispose();
    isLoading.dispose();
    lastError.dispose();
    dataChangeVersion.dispose();
    selectedQ.dispose();
    selectedWilayas.dispose();
    selectedCommunes.dispose();
    selectedMetiers.dispose();
    selectedPrixMin.dispose();
    selectedPrixMax.dispose();
    selectedIsPro.dispose();
  }
}
