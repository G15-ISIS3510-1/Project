// lib/presentation/features/host_home/viewmodel/host_home_viewmodel.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/models/pricing_model.dart';

import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart'; // PricingService

enum HostHomeStatus { loading, ready, error }

class HostHomeViewModel extends ChangeNotifier {
  final VehicleRepository _vehiclesRepo;
  final PricingService _pricing;
  final String currentUserId;

  HostHomeViewModel({
    required VehicleRepository vehiclesRepo,
    required this.currentUserId,
    PricingService? pricing,
  }) : _vehiclesRepo = vehiclesRepo,
       _pricing = pricing ?? PricingService();

  HostHomeStatus _status = HostHomeStatus.loading;
  HostHomeStatus get status => _status;

  String? _error;
  String? get error => _error;

  // Fuente (mis autos) y lista visible (filtrada)
  List<Vehicle> _mine = [];
  List<Vehicle> _visible = [];
  List<Vehicle> get vehicles => _visible;

  // filtros UI
  String _query = '';
  String? _category; // 'SUVs', 'Trucks', etc.  (ignora 'My cars')

  // cache de pricing por vehículo
  final Map<String, Future<Pricing?>> _pricingFutures = {};

  // ---------- ciclo de vida ----------
  Future<void> init() async {
    if (_status == HostHomeStatus.loading && _mine.isEmpty) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    _status = HostHomeStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final all = await _vehiclesRepo.list();
      _mine = all.where((v) => v.ownerId == currentUserId).toList();
      _rebuild();
      _status = HostHomeStatus.ready;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _status = HostHomeStatus.error;
      notifyListeners();
    }
  }

  // Llamar después de crear un vehículo
  Future<void> onVehicleCreated() => refresh();

  // ---------- filtros ----------
  void setQuery(String q) {
    _query = q;
    _rebuild();
    notifyListeners();
  }

  /// `label` viene de los chips. Si es "My cars" o `null`, no aplica filtro por categoría.
  void setCategory(String? label) {
    if (label == null || label.toLowerCase() == 'my cars') {
      _category = null;
    } else {
      _category = label;
    }
    _rebuild();
    notifyListeners();
  }

  void _rebuild() {
    final q = _query.trim().toLowerCase();
    final c = _category?.trim().toLowerCase();

    Iterable<Vehicle> list = _mine;

    if (q.isNotEmpty) {
      list = list.where((v) {
        final fields = <String?>[
          v.title,
          v.make,
          v.model,
          v.transmission,
          v.plate,
          v.vehicle_id,
        ];
        return fields
            .whereType<String>()
            .map((s) => s.toLowerCase())
            .any((s) => s.contains(q));
      });
    }

    if (c != null && c.isNotEmpty) {
      // Heurística simple: usa título/campos para machear categorías (“SUVs”, “Trucks”, etc.)
      list = list.where((v) {
        final tags = <String?>[
          v.title,
          // si tienes segment/bodyType/category en tu payload, añádelos aquí:
          // v.segment, v.bodyType, v.category,
        ];
        return tags
            .whereType<String>()
            .map((s) => s.toLowerCase())
            .any((s) => s.contains(c));
      });
    }

    _visible = list.toList(growable: false);
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

  void invalidatePrice(String vehicleId) {
    _pricingFutures.remove(vehicleId);
  }
}
