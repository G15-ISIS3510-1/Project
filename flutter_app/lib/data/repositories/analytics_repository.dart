import '../models/booking_reminder_model.dart';
import '../sources/remote/analytics_remote_source.dart';

abstract class AnalyticsRepository {
  Future<BookingReminderListModel> getBookingsNeedingReminder();
  Future<UpcomingBookingsListModel> getUserUpcomingBookings(
      String userId, {
        int hoursAhead = 24,
      });
  Future<List<dynamic>> getDemandPeaks();
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteSource remoteSource;

  AnalyticsRepositoryImpl({required this.remoteSource});

  @override
  Future<BookingReminderListModel> getBookingsNeedingReminder() async {
    try {
      return await remoteSource.getBookingsNeedingReminder();
    } catch (e) {
      // Relanzamos la excepción original para evitar la anidación del mensaje.
      rethrow;
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
      // 🔥 SOLUCIÓN: Usamos 'rethrow' para mantener la excepción limpia.
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getDemandPeaks() async {
    try {
      return await remoteSource.getDemandPeaks();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getDemandPeaksExtended() async {
    try {
      return await remoteSource.getDemandPeaksExtended();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getOwnerIncome() async {
    try {
      return await remoteSource.getOwnerIncome();
    } catch (e) {
      rethrow;
    }
  }
}