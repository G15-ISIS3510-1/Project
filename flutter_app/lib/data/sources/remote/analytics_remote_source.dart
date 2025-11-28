import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/booking_reminder_model.dart';
import '../../../core/exceptions/api_exception.dart';

abstract class AnalyticsRemoteSource {
  Future<BookingReminderListModel> getBookingsNeedingReminder();
  Future<UpcomingBookingsListModel> getUserUpcomingBookings(
    String userId, {
    int hoursAhead = 24,
  });
  Future<List<dynamic>> getDemandPeaks();
  Future<List<dynamic>> getDemandPeaksExtended();
  Future<List<dynamic>> getOwnerIncome();
  Future<Map<String, dynamic>> getFeesTaxesAverage();

  /// NEW: vehicles with recent price updates (last 7 days)
  Future<List<dynamic>> getRecentPriceUpdates();
}

class AnalyticsRemoteSourceImpl implements AnalyticsRemoteSource {
  final http.Client client;
  final String baseUrl;

  AnalyticsRemoteSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<BookingReminderListModel> getBookingsNeedingReminder() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/analytics/bookings/reminders'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return BookingReminderListModel.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<UpcomingBookingsListModel> getUserUpcomingBookings(
    String userId, {
    int hoursAhead = 24,
  }) async {
    final response = await client.get(
      Uri.parse(
        '$baseUrl/api/analytics/users/$userId/upcoming-bookings?hours_ahead=$hoursAhead',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return UpcomingBookingsListModel.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<List<dynamic>> getDemandPeaks() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/analytics/demand-peaks'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw ApiException('Failed to fetch demand peaks');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getOwnerIncome() async {
    final url = Uri.parse('$baseUrl/api/analytics/owner-income');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch owner income: ${response.statusCode}');
    }
  }

  @override
  Future<List<dynamic>> getDemandPeaksExtended() async {
    final url = Uri.parse('$baseUrl/api/analytics/demand-peaks-extended');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch demand peaks extended: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFeesTaxesAverage() async {
    final url = Uri.parse('$baseUrl/api/analytics/fees-taxes-average');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is num) {
        return {'average': decoded.toDouble()};
      }
      throw Exception('Unexpected payload for fees/taxes average');
    } else {
      throw _handleError(response);
    }
  }

  /// NEW: vehicles with recent price updates (last 7 days)
  @override
  Future<List<dynamic>> getRecentPriceUpdates() async {
    final url =
        Uri.parse('$baseUrl/api/analytics/vehicles/recent-price-updates');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw _handleError(response);
    }
  }

  Exception _handleError(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 500) {
      return ApiException(
        'The service is currently unavailable. Please try again later.',
        statusCode: statusCode,
      );
    } else if (statusCode == 401 || statusCode == 403) {
      return ApiException(
        'Session expired or unauthorized access. Please log in again.',
        statusCode: statusCode,
      );
    } else if (statusCode >= 400 && statusCode < 500) {
      return ApiException(
        'A request error occurred. Check input data.',
        statusCode: statusCode,
      );
    } else {
      return ApiException(
        'An unexpected error occurred: $statusCode',
        statusCode: statusCode,
      );
    }
  }
}
