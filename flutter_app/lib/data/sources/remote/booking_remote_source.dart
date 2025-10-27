import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class BookingService {
  Future<http.Response> listMyBookings({
    int skip = 0,
    int limit = 100,
    String? statusFilter,
  }) async {
    return Api.I().get(
      '/api/bookings/?skip=$skip&limit=$limit${statusFilter != null ? '&status_filter=$statusFilter' : ''}',
    );
  }

  Future<http.Response> create(Map<String, dynamic> body) {
    return Api.I().post('/api/bookings', body);
  }
}
