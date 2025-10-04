// lib/presentation/features/home/viewmodel/home_viewmodel.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/models/pricing_model.dart';

import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart'; // PricingService

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

  // origen completo y vista filtrada
  List<Vehicle> _all = [];
  List<Vehicle> _visible = [];
  List<Vehicle> get vehicles => _visible;

  // filtros
  String _query = '';
  String? _category;

  // cache de precios por vehicleId (para evitar múltiples llamadas)
  final Map<String, Future<Pricing?>> _pricingFutures = {};

  // ---------- ciclo de vida ----------
  Future<void> init() async {
    if (_status == HomeStatus.loading && _all.isEmpty) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    _status = HomeStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _all = await _vehicles.list(); // usa tu repo
      _rebuild();
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
    _rebuild();
    notifyListeners();
  }

  void setCategory(String? c) {
    // ejemplo: chips con ['Cars','SUVs','Minivans','Trucks','Vans','Luxury']
    _category = c;
    _rebuild();
    notifyListeners();
  }

  void _rebuild() {
    final q = _query.trim().toLowerCase();
    final c = _category?.trim().toLowerCase();

    Iterable<Vehicle> list = _all;

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
      // Heurística: intenta casar la categoría con segment/bodyType/category (si existen en tu payload)
      final matchesCategory = (Vehicle v) {
        final tags = <String?>[
          // agrega aquí campos reales de tu vehículo si existen:
          // v.segment, v.bodyType, v.category,
          // por ahora tratamos por nombre simple:
          v.title,
        ];
        return tags
            .whereType<String>()
            .map((s) => s.toLowerCase())
            .any((s) => s.contains(c));
      };
      list = list.where(matchesCategory);
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

  // Invalida el cache de un vehículo (por si cambias el precio)
  void invalidatePrice(String vehicleId) {
    _pricingFutures.remove(vehicleId);
  }
}
