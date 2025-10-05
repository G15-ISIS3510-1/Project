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