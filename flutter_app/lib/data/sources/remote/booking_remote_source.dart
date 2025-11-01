import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingsRemoteSource {
  final String baseUrl;
  final Future<String?> Function()? getToken;

  BookingsRemoteSource({required this.baseUrl, this.getToken});

  Future<List<Map<String, dynamic>>> listMyBookings({
    required int skip,
    required int limit,
    String? statusFilter, // "pending|confirmed|completed|cancelled"
  }) async {
    final uri = Uri.parse('$baseUrl/api/bookings').replace(
      queryParameters: {
        'skip': '$skip',
        'limit': '$limit',
        if (statusFilter != null) 'status_filter': statusFilter,
      },
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (getToken != null)
        'Authorization': 'Bearer ${await getToken!() ?? ''}',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode} ${resp.reasonPhrase}');
    }

    final data = json.decode(resp.body);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Respuesta inesperada: se esperaba una lista JSON');
  }
}
