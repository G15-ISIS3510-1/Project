// lib/presentation/features/home/viewmodel/home_viewmodel.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/models/pricing_model.dart';

import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart'; // PricingService
import 'package:flutter_app/app/utils/pagination.dart';

enum HomeStatus { loading, ready, error }

class HomeViewModel extends ChangeNotifier {
  final VehicleRepository _vehicles;
  final PricingService _pricing;

  HomeViewModel({required VehicleRepository vehicles, PricingService? pricing})
      : _vehicles = vehicles,
        _pricing = pricing ?? PricingService();

  HomeStatus _status = HomeStatus.loading;
  HomeStatus get status => _status;

  String? _error;
  String? get error => _error;

  // ====== PAGED CACHE (remote 100 / visible 10) ======
  static const int _remoteLimit = 100; // server fetch size
  static const int _pageSize = 10;     // UI page size

  /// Vehicles currently cached (only the latest chunk of 100).
  final List<Vehicle> _cache = [];

  /// Filtered view over cache.
  List<Vehicle> _filtered = [];

  /// Current page inside the current 100-chunk (0..9).
  int _pageIndex = 0;

  /// Running page offset (how many pages were shown before this chunk).
  /// This makes the page label cumulative: 1..10, 11..20, 21..30, ...
  int _pageOffsetPages = 0;

  /// Remote paging info
  int _remoteSkip = 0;
  bool _remoteHasMore = true;

  /// What the UI reads (exactly the 10 visible items)
  List<Vehicle> _visible = [];
  List<Vehicle> get vehicles => _visible;

  // filtros
  String _query = '';
  String? _category;

  // cache de precios por vehicleId (para evitar múltiples llamadas)
  final Map<String, Future<Pricing?>> _pricingFutures = {};

  // ===== DEBUG/DEMO counters (for Viva) =====
  int _remoteRequestCount = 0;
  int _lastChunkSkip = 0;
  final int _lastChunkLimit = _remoteLimit;
  DateTime? _lastFetchAt;

  // Expose for a tiny HUD (optional)
  int get cacheSize => _cache.length;
  int get remoteRequests => _remoteRequestCount;
  int get lastChunkSkip => _lastChunkSkip;
  int get lastChunkLimit => _lastChunkLimit;

  // ---------- ciclo de vida ----------
  Future<void> init() async {
    if (_status == HomeStatus.loading && _cache.isEmpty) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    _status = HomeStatus.loading;
    _error = null;
    notifyListeners();
    try {
      // Reset paging state
      _cache.clear();
      _filtered = [];
      _visible = [];
      _pageIndex = 0;
      _pageOffsetPages = 0; // reset cumulative counter
      _remoteSkip = 0;
      _remoteHasMore = true;

      // Fetch first chunk (100)
      final usedSkip = _remoteSkip; // for logging
      final page =
          await _vehicles.listPaginated(skip: _remoteSkip, limit: _remoteLimit);

      _cache.addAll(page.items);
      // If your Paginated<T> exposes nextSkip, use it; otherwise compute:
      _remoteSkip = (page is dynamic && page.nextSkip != null)
          ? page.nextSkip
          : (page.skip + (page.limit == 0 ? page.items.length : page.limit));
      _remoteHasMore = page.hasMore;

      // DEBUG log
      _remoteRequestCount++;
      _lastChunkSkip = usedSkip;
      _lastFetchAt = DateTime.now();
      debugPrint('[VehiclesChunk] request #$_remoteRequestCount '
          'skip=$usedSkip limit=$_remoteLimit '
          'fetched=${page.items.length} hasMore=${page.hasMore} at=$_lastFetchAt');

      _applyFiltersAndBuildVisible(resetPageIndex: true);

      _status = HomeStatus.ready;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _status = HomeStatus.error;
      notifyListeners();
    }
  }

  // ---------- filtros ----------
  void setQuery(String q) {
    _query = q;
    _applyFiltersAndBuildVisible(resetPageIndex: true);
    notifyListeners();
  }

  void setCategory(String? c) {
    _category = c;
    _applyFiltersAndBuildVisible(resetPageIndex: true);
    notifyListeners();
  }

  void _applyFiltersAndBuildVisible({bool resetPageIndex = false}) {
    // 1) Filter over the cached list (current 100)
    final q = _query.trim().toLowerCase();
    final c = _category?.trim().toLowerCase();

    Iterable<Vehicle> list = _cache;

    if (q.isNotEmpty) {
      list = list.where((v) {
        final fields = <String?>[
          v.title,
          v.make,
          v.model,
          v.transmission,
          v.vehicle_id,
          v.plate,
        ];
        return fields
            .whereType<String>()
            .map((s) => s.toLowerCase())
            .any((s) => s.contains(q));
      });
    }

    if (c != null && c.isNotEmpty) {
      final matchesCategory = (Vehicle v) {
        final tags = <String?>[v.title];
        return tags
            .whereType<String>()
            .map((s) => s.toLowerCase())
            .any((s) => s.contains(c));
      };
      list = list.where(matchesCategory);
    }

    _filtered = list.toList(growable: false);

    if (resetPageIndex) {
      _pageOffsetPages = 0; // reset cumulative counter on new filter
      _pageIndex = 0;
    }

    // 2) Build current visible page from filtered list
    final start = _pageIndex * _pageSize;
    final end = (start + _pageSize) <= _filtered.length
        ? (start + _pageSize)
        : _filtered.length;

    _visible =
        start < _filtered.length ? _filtered.sublist(start, end) : const <Vehicle>[];
  }

  // ---------- paging controls for the UI ----------
  bool get canPrev => _pageIndex > 0;

  bool get canNext {
    final nextStart = (_pageIndex + 1) * _pageSize;
    return nextStart < _filtered.length || _remoteHasMore;
  }

  /// Cumulative page number (1-based), never resets when a new chunk loads.
  String get pageNumber => '${_pageOffsetPages + _pageIndex + 1}';

  Future<void> nextPage() async {
    final nextStart = (_pageIndex + 1) * _pageSize;

    // Next page exists inside current cached (filtered) list
    if (nextStart < _filtered.length) {
      _pageIndex++;
      _applyFiltersAndBuildVisible();
      notifyListeners();
      return;
    }

    // No more pages in cached list -> need next 100?
    if (_remoteHasMore) {
      // We are moving beyond the last page of this chunk,
      // account for pages already consumed in this chunk.
      _pageOffsetPages += (_pageIndex + 1); // carry cumulative offset

      // Pull next remote chunk (100) and REPLACE the cache (rolling window)
      final usedSkip = _remoteSkip; // for logging
      final page =
          await _vehicles.listPaginated(skip: _remoteSkip, limit: _remoteLimit);

      _remoteSkip = (page is dynamic && page.nextSkip != null)
          ? page.nextSkip
          : (page.skip + (page.limit == 0 ? page.items.length : page.limit));
      _remoteHasMore = page.hasMore;

      _cache
        ..clear()
        ..addAll(page.items);

      // DEBUG log
      _remoteRequestCount++;
      _lastChunkSkip = usedSkip;
      _lastFetchAt = DateTime.now();
      debugPrint('[VehiclesChunk] request #$_remoteRequestCount '
          'skip=$usedSkip limit=$_remoteLimit '
          'fetched=${page.items.length} hasMore=${page.hasMore} at=$_lastFetchAt');

      // Start within the new chunk at page 0 (label stays cumulative)
      _pageIndex = 0;
      _applyFiltersAndBuildVisible(resetPageIndex: false);
      notifyListeners();
    }
  }

  void prevPage() {
    if (_pageIndex == 0) return; // keep prev disabled at chunk boundary
    _pageIndex--;
    _applyFiltersAndBuildVisible();
    notifyListeners();
  }

  // ---------- pricing ----------
  Future<Pricing?> priceFutureFor(String vehicleId) {
    return _pricingFutures[vehicleId] ??= _fetchPrice(vehicleId);
  }

  Future<Pricing?> _fetchPrice(String vehicleId) async {
    final http.Response res = await _pricing.getByVehicle(vehicleId);
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Pricing ${res.statusCode}: ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return Pricing.fromJson(decoded);
    }
    throw Exception('Unexpected pricing payload');
  }

  // Invalida el cache de un vehículo (por si cambias el precio)
  void invalidatePrice(String vehicleId) {
    _pricingFutures.remove(vehicleId);
  }
}
