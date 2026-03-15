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
  final ValueNotifier<bool> isLoadingMore = ValueNotifier<bool>(false);
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

  List<OfferModel>? _cachedInitialList;
  bool _didLoadInitial = false;

  int _searchOffset = 0;
  bool _searchHasMore = false;

  void clearLastError() {
    lastError.value = null;
  }

  Future<void> init() async {
    if (_didLoadInitial && _cachedInitialList != null) {
      annonces.value = List<OfferModel>.unmodifiable(_cachedInitialList!);
      isSearchActive.value = false;
      searchAnnonces.value = const [];
      clearLastError();
      _bump();
      return;
    }

    await refreshInitialFromNetwork(force: false);
  }

  Future<void> refreshInitialFromNetwork({bool force = true}) async {
    if (!force && _didLoadInitial && _cachedInitialList != null) {
      annonces.value = List<OfferModel>.unmodifiable(_cachedInitialList!);
      isSearchActive.value = false;
      searchAnnonces.value = const [];
      clearLastError();
      _bump();
      return;
    }

    try {
      isLoading.value = true;
      clearLastError();

      final fresh = await _service.fetchAnnonces();

      _cachedInitialList = List<OfferModel>.unmodifiable(fresh);
      _didLoadInitial = true;

      annonces.value = List<OfferModel>.unmodifiable(fresh);
      isSearchActive.value = false;
      searchAnnonces.value = const [];

      _searchOffset = 0;
      _searchHasMore = false;

      selectedQ.value = '';
      selectedWilayas.value = [];
      selectedCommunes.value = [];
      selectedMetiers.value = [];
      selectedPrixMin.value = null;
      selectedPrixMax.value = null;
      selectedIsPro.value = null;

      _bump();
    } catch (e, st) {
      debugPrint('OffreManager.refreshInitialFromNetwork: $e\n$st');
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
        _searchOffset = 0;
        _searchHasMore = false;

        if (_cachedInitialList != null) {
          annonces.value = List<OfferModel>.unmodifiable(_cachedInitialList!);
        }

        _bump();
        return;
      }

      final result = await _service.searchAnnonces(
        q: selectedQuery,
        wilayas: selectedW,
        communes: selectedC,
        metiers: selectedM,
        prixMin: prixMin,
        prixMax: prixMax,
        isPro: isPro,
        offset: 0,
      );

      searchAnnonces.value = List<OfferModel>.unmodifiable(result.items);
      isSearchActive.value = true;
      _searchOffset = result.nextOffset;
      _searchHasMore = result.hasMore;

      _bump();
    } catch (e, st) {
      debugPrint('OffreManager.applyFilters: $e\n$st');
      lastError.value = e.toString();
      isSearchActive.value = false;
      searchAnnonces.value = const [];
      _searchOffset = 0;
      _searchHasMore = false;
      _bump();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreSearch() async {
    if (!isSearchActive.value) return;
    if (!_searchHasMore) return;
    if (isLoading.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      clearLastError();

      final result = await _service.searchAnnonces(
        q: selectedQ.value,
        wilayas: selectedWilayas.value,
        communes: selectedCommunes.value,
        metiers: selectedMetiers.value,
        prixMin: selectedPrixMin.value,
        prixMax: selectedPrixMax.value,
        isPro: selectedIsPro.value,
        offset: _searchOffset,
      );

      final merged = <OfferModel>[
        ...searchAnnonces.value,
        ...result.items,
      ];

      searchAnnonces.value = List<OfferModel>.unmodifiable(merged);
      _searchOffset = result.nextOffset;
      _searchHasMore = result.hasMore;

      _bump();
    } catch (e, st) {
      debugPrint('OffreManager.loadMoreSearch: $e\n$st');
      lastError.value = e.toString();
      _bump();
    } finally {
      isLoadingMore.value = false;
    }
  }

  bool get hasMoreSearch => _searchHasMore;

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
    _searchOffset = 0;
    _searchHasMore = false;

    if (_cachedInitialList != null) {
      annonces.value = List<OfferModel>.unmodifiable(_cachedInitialList!);
    }

    _bump();
  }

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
    isLoadingMore.dispose();
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