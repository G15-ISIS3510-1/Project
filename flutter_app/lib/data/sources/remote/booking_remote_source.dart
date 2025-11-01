import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

String _snip(String s, [int max = 600]) =>
    s.length <= max ? s : s.substring(0, max) + '…[snip]';

class BookingService {
  Future<http.Response> listMyBookings({
    int skip = 0,
    int limit = 100,
    String? statusFilter,
    bool asHost = false,
  }) async {
    final path =
        '/api/bookings/?skip=$skip&limit=$limit'
        '${statusFilter != null ? '&status_filter=$statusFilter' : ''}'
        '&as_host=$asHost'; // ← aunque el backend no lo use, sirve para traza

    if (kDebugMode) {
      // si Api.I() expone el token/uid, también imprímelos acá
      debugPrint('[BookingService] GET $path');
    }

    final resp = Api.I().get(path);
    resp.then((r) {
      if (kDebugMode) {
        debugPrint(
          '[BookingService] ← ${r.statusCode} '
          'len=${r.body.length} body=${_snip(r.body)}',
        );
      }
    });
    return resp;
  }

  Future<http.Response> create(Map<String, dynamic> body) {
    if (kDebugMode)
      debugPrint('[BookingService] POST /api/bookings body=$body');
    return Api.I().post('/api/bookings', body);
  }
}
