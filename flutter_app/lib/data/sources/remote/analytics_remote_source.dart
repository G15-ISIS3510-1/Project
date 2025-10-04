import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/booking_reminder_model.dart';

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
      throw Exception('Failed to load booking reminders: ${response.statusCode}');
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
      throw Exception('Failed to load upcoming bookings: ${response.statusCode}');
    }
  }
}