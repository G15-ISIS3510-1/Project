// lib/presentation/features/trips/viewmodel/trips_viewmodel.dart
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/models/booking_status.dart';
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/presentation/common_widgets/trip_filter.dart';
import 'package:flutter_app/presentation/common_widgets/trip_card.dart'
    show TripItem;

import '../mappers/booking_to_item.dart';

enum TripsStatus { idle, loading, ready, error }

class TripsViewModel extends ChangeNotifier {
  // ---------- constants ----------
  static const int _chunkSize = 100; // how many we ask from backend at once
  static const int _pageSize = 10;   // how many we show per UI "page"

  final BookingsRepository _repo;
  final VehicleNameResolver? _vehicleNameResolver;

  TripsViewModel(
    this._repo, {
    VehicleNameResolver? vehicleNameResolver,
  }) : _vehicleNameResolver = vehicleNameResolver;

  // ---------- high-level state exposed to UI ----------
  TripsStatus _status = TripsStatus.idle;
  TripsStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  TripFilter _filter = TripFilter.all;
  TripFilter get filter => _filter;

  String _query = '';
  String get query => _query;

  // The TripItem list for *the current visible page* (max 10 items).
  List<TripItem> _items = const [];
  List<TripItem> get items => _items;

  // ---------- chunk window ----------
  // Bookings currently cached (up to 100).
  List<Booking> _chunk = [];

  // Where this chunk starts in the global list.
  // 0 for first 100, 100 for next 100, 200 for next, etc.
  int _chunkStart = 0;

  // Did backend say "there is more after this chunk"?
  bool _chunkHasMoreAfter = true;

  // Which page *inside this chunk* are we showing? 0..9 normally.
  int _pageIndex = 0;

  // ---------- getters for pager pill ----------
  // Global page number (1-based) for the pill.
  // Example:
  //   chunkStart=0,  pageIndex=0 => 1
  //   chunkStart=0,  pageIndex=1 => 2
  //   chunkStart=100,pageIndex=0 => 11
  int get pageNumber {
    final basePage = (_chunkStart ~/ _pageSize); // 0 for first 100, 10 for next 100...
    return basePage + _pageIndex + 1;
  }

  // Can we go to previous page *within this chunk*?
  bool get canPrevPage => _pageIndex > 0;

  // Can we go forward?
  // true if:
  //  - there is another local page in this chunk (same 100),
  //  OR
  //  - we're at the end of local pages but backend still has more (chunkHasMoreAfter).
  bool get canNextPage {
    final filtered = _filteredChunk();
    if (filtered.isEmpty) {
      // nothing in this chunk. Next page is only valid if server says there's more.
      return _chunkHasMoreAfter;
    }
    final localMaxPageIdx = (filtered.length - 1) ~/ _pageSize;
    final moreLocalPages = _pageIndex < localMaxPageIdx;
    if (moreLocalPages) return true;
    // no more pages in this chunk → can go next only if server says more
    return _chunkHasMoreAfter;
  }

  // ---------- public lifecycle ----------
  Future<void> init() async {
    if (_status == TripsStatus.idle) {
      await _fetchChunk(0);
    }
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await _fetchChunk(0);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // User tapped right chevron on the pill
  Future<void> nextPage() async {
    final filtered = _filteredChunk();
    final localMaxPageIdx = filtered.isEmpty
        ? 0
        : ((filtered.length - 1) ~/ _pageSize);
    final moreLocalPages = _pageIndex < localMaxPageIdx;

    if (moreLocalPages) {
      // just go to next local page in the same 100-cache
      _pageIndex += 1;
      _rebuildVisibleItems();
      notifyListeners();
      return;
    }

    // we're at the last local page of this chunk
    if (_chunkHasMoreAfter) {
      // fetch the next 100 starting after current chunk
      final newStart = _chunkStart + _chunk.length;
      await _fetchChunk(newStart);
    }
    // else do nothing (we're on the last page of the last chunk)
  }

  // User tapped left chevron on the pill
  void prevPage() {
    if (_pageIndex > 0) {
      _pageIndex -= 1;
      _rebuildVisibleItems();
      notifyListeners();
    }
    // NOTE:
    // We intentionally do NOT go back to the previous 100 once we've thrown it
    // away (same rule as vehicles). So if _pageIndex == 0 we do nothing.
  }

  // User changed "All / Booked / History"
  void setFilter(TripFilter f) {
    if (_filter == f) return;
    _filter = f;
    // reset to first page of this chunk
    _pageIndex = 0;
    _rebuildVisibleItems();
    notifyListeners();
  }

  // User typed in the search bar
  void setQuery(String q) {
    if (_query == q) return;
    _query = q;
    // reset to first page of this chunk
    _pageIndex = 0;
    _rebuildVisibleItems();
    notifyListeners();
  }

  // ---------- internal helpers ----------

  // Fetches one 100-booking chunk starting at [start].
  Future<void> _fetchChunk(int start) async {
    _error = null;
    _status = TripsStatus.loading;
    notifyListeners();

    final res = await _repo.listMyBookings(
      skip: start,
      limit: _chunkSize,
      statusFilter: null,
    );

    res.when(
      ok: (page) {
        // cache this chunk
        _chunk = page.items;
        _chunkStart = start;
        _chunkHasMoreAfter = page.hasMore;

        // reset page index to first page of this new chunk
        _pageIndex = 0;

        _status = TripsStatus.ready;
        _rebuildVisibleItems();
        notifyListeners();
      },
      err: (msg) {
        _status = TripsStatus.error;
        _error = msg;
        _items = const [];
        notifyListeners();
      },
    );
  }

  // Apply TripFilter + search query over the current 100-cache.
  List<Booking> _filteredChunk() {
    Iterable<Booking> base = _chunk;
    final now = DateTime.now();

    // filter by All / Booked / History
    switch (_filter) {
      case TripFilter.all:
        break;
      case TripFilter.booked:
        base = base.where((b) => _isBooked(b, now));
        break;
      case TripFilter.history:
        base = base.where((b) => _isHistory(b, now));
        break;
    }

    // local search in this chunk
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      base = base.where(
        (b) =>
            b.vehicleId.toLowerCase().contains(q) ||
            b.bookingId.toLowerCase().contains(q),
      );
    }

    return base.toList(growable: false);
  }

  // booked == upcoming/active and not cancelled
  bool _isBooked(Booking b, DateTime now) {
    final notCancelled = b.status != BookingStatus.cancelled;
    return b.endTs.isAfter(now) && notCancelled;
  }

  // history == finished OR cancelled
  bool _isHistory(Booking b, DateTime now) {
    return b.endTs.isBefore(now) || b.status == BookingStatus.cancelled;
  }

  // Recompute the 10 visible TripItems for the current [_pageIndex].
  void _rebuildVisibleItems() {
    final filtered = _filteredChunk();

    if (filtered.isEmpty) {
      _pageIndex = 0;
      _items = const [];
      return;
    }

    // clamp page index in case filter/query removed items
    final maxPageIdx = (filtered.length - 1) ~/ _pageSize;
    if (_pageIndex > maxPageIdx) {
      _pageIndex = maxPageIdx;
    }

    final start = _pageIndex * _pageSize;
    final endExclusive = math.min(start + _pageSize, filtered.length);
    final currentSlice = filtered.sublist(start, endExclusive);

    _items = currentSlice
        .map(
          (b) => BookingMappers.toItem(
            b,
            resolveVehicleName: _vehicleNameResolver,
          ),
        )
        .toList(growable: false);
  }
}
