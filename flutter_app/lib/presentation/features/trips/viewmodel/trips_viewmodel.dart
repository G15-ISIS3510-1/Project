// lib/presentation/features/trips/viewmodel/trips_viewmodel.dart
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
  final BookingsRepository _repo;
  final VehicleNameResolver? _vehicleNameResolver;

  TripsViewModel(this._repo, {VehicleNameResolver? vehicleNameResolver})
    : _vehicleNameResolver = vehicleNameResolver;

  TripsStatus _status = TripsStatus.idle;
  TripsStatus get status => _status;

  String? _error;
  String? get error => _error;

  TripFilter _filter = TripFilter.all;
  TripFilter get filter => _filter;

  String _query = '';
  String get query => _query;

  final List<Booking> _bookingsRaw = [];
  List<TripItem> _items = const [];
  List<TripItem> get items => _items;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  int _skip = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> init() async {
    if (_status == TripsStatus.idle) {
      await _load(reset: true);
    }
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await _load(reset: true);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_status == TripsStatus.loading || !_hasMore) return;
    await _load(reset: false);
  }

  void setFilter(TripFilter f) {
    if (_filter == f) return;
    _filter = f;
    _rebuildItems();
    notifyListeners();
  }

  void setQuery(String q) {
    if (_query == q) return;
    _query = q;
    _rebuildItems(); // sólo filtra client-side por ahora
    notifyListeners();
  }

  Future<void> _load({required bool reset}) async {
    _error = null;
    if (reset) {
      _skip = 0;
      _hasMore = true;
      _bookingsRaw.clear();
    }

    if (reset) {
      _status = TripsStatus.loading;
      notifyListeners();
    }

    final res = await _repo.listMyBookings(
      skip: _skip,
      limit: _limit,
      statusFilter: null,
    );

    res.when(
      ok: (page) {
        _status = TripsStatus.ready;
        if (reset) {
          _bookingsRaw
            ..clear()
            ..addAll(page.items);
        } else {
          _bookingsRaw.addAll(page.items);
        }
        _hasMore = page.hasMore;
        if (_hasMore) _skip += _limit;

        _rebuildItems();
        notifyListeners();
      },
      err: (msg) {
        _status = TripsStatus.error;
        _error = msg;
        if (reset) _items = const [];
        notifyListeners();
      },
    );
  }

  // --- Lógica de filtros con tu TripFilter ---
  bool _isBooked(Booking b, DateTime now) {
    final notCancelled = b.status != BookingStatus.cancelled;
    return b.endTs.isAfter(now) && notCancelled; // vigentes o futuras
  }

  bool _isHistory(Booking b, DateTime now) {
    return b.endTs.isBefore(now) || b.status == BookingStatus.cancelled;
  }

  void _rebuildItems() {
    final now = DateTime.now();

    Iterable<Booking> base = _bookingsRaw;
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

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      base = base.where(
        (b) =>
            b.vehicleId.toLowerCase().contains(q) ||
            b.bookingId.toLowerCase().contains(q),
      );
    }

    _items = base
        .map(
          (b) => BookingMappers.toItem(
            b,
            resolveVehicleName: _vehicleNameResolver,
          ),
        )
        .toList(growable: false);
  }
}
