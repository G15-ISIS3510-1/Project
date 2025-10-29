// lib/domain/trips/bookings_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/app/utils/lru_cache.dart';
import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/models/booking_status.dart';
import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart';

class BookingsPage {
  final List<Booking> items;
  final bool hasMore;
  BookingsPage({required this.items, required this.hasMore});
}

abstract class BookingsRepository {
  Future<Result<BookingsPage>> listMyBookings({
    int skip,
    int limit,
    BookingStatus? statusFilter,
    bool asHost, // <- importante
  });

  Future<Result<Booking>> createBooking(BookingCreateModel data);

  void clearCache();
}

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingService remote;

  // LRU: guardamos páginas (skip,limit,status,rol) por identidad (token)
  // Capacidad 6 => hasta ~600 bookings en RAM si usas limit=100
  final LruCache<String, BookingsPage> _cache = LruCache<String, BookingsPage>(
    6,
  );

  BookingsRepositoryImpl(this.remote);

  @override
  void clearCache() {
    _cache.clear();
    if (kDebugMode) debugPrint('[BookingsRepoImpl] LRU cleared');
  }

  String _key({
    required String token,
    required bool asHost,
    required int skip,
    required int limit,
    String? status,
  }) {
    final th = token.isEmpty ? 'none' : token.hashCode.toString();
    return 'tok:$th|host:${asHost ? 1 : 0}|skip:$skip|lim:$limit|st:${status ?? ""}';
  }

  @override
  Future<Result<BookingsPage>> listMyBookings({
    int skip = 0,
    int limit = 20,
    BookingStatus? statusFilter,
    bool asHost = false,
  }) async {
    final token = Api.I().token ?? '';
    final key = _key(
      token: token,
      asHost: asHost,
      skip: skip,
      limit: limit,
      status: statusFilter?.asParam,
    );

    // 1) LRU hit
    final hit = _cache.get(key);
    if (hit != null) {
      if (kDebugMode) {
        debugPrint(
          '[BookingsRepoImpl] LRU HIT key=$key items=${hit.items.length}',
        );
      }
      return Result.ok(hit);
    }

    // 2) Remote
    final resp = await remote.listMyBookings(
      skip: skip,
      limit: limit,
      statusFilter: statusFilter?.asParam,
      asHost: asHost,
    );

    if (resp.statusCode != 200) {
      return Result.err('HTTP ${resp.statusCode}');
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = (body['items'] as List)
        .map((m) => Booking.fromJson(m as Map<String, dynamic>))
        .toList();
    final hasMore = body['has_more'] == true || items.length == limit;

    final page = BookingsPage(items: items, hasMore: hasMore);

    _cache.put(key, page);
    if (kDebugMode) {
      debugPrint(
        '[BookingsRepoImpl] NET OK key=$key items=${items.length} hasMore=$hasMore (cached)',
      );
    }
    return Result.ok(page);
  }

  @override
  Future<Result<Booking>> createBooking(BookingCreateModel data) async {
    try {
      final res = await remote.create(data.toJson());
      if (res.statusCode != 201 && res.statusCode != 200) {
        String detail = 'Error al crear la reserva';
        try {
          final b = jsonDecode(res.body);
          detail = (b['detail'] ?? b['message'] ?? res.body).toString();
        } catch (_) {
          if (res.body.isNotEmpty) detail = res.body;
        }
        return Result.err('Error ${res.statusCode}: $detail');
      }

      // Invalida LRU para forzar recarga en próximos listados
      clearCache();

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        return Result.err('Respuesta inesperada al crear la reserva.');
      }
      return Result.ok(Booking.fromJson(decoded));
    } catch (e) {
      return Result.err('Error de red/conexión: $e');
    }
  }
}
