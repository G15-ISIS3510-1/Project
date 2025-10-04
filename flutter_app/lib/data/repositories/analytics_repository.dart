import '../models/booking_reminder_model.dart';
import '../sources/remote/analytics_remote_source.dart';

abstract class AnalyticsRepository {
  Future<BookingReminderListModel> getBookingsNeedingReminder();
  Future<UpcomingBookingsListModel> getUserUpcomingBookings(
    String userId, {
    int hoursAhead = 24,
  });
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteSource remoteSource;

  AnalyticsRepositoryImpl({required this.remoteSource});

  @override
  Future<BookingReminderListModel> getBookingsNeedingReminder() async {
    try {
      return await remoteSource.getBookingsNeedingReminder();
    } catch (e) {
      throw Exception('Error fetching booking reminders: $e');
    }
  }

  @override
  Future<UpcomingBookingsListModel> getUserUpcomingBookings(
    String userId, {
    int hoursAhead = 24,
  }) async {
    try {
      return await remoteSource.getUserUpcomingBookings(
        userId,
        hoursAhead: hoursAhead,
      );
    } catch (e) {
      throw Exception('Error fetching upcoming bookings: $e');
    }
  }
}