import '../../app/utils/net.dart';
import '/data/database/app_database.dart';
import '../models/booking_reminder_model.dart';
import '../sources/remote/analytics_remote_source.dart';
import '../sources/local/analytics_local_source.dart';
import '../sources/local/analytics_extended_local_source.dart';
import '../sources/local/owner_income_local_source.dart';

abstract class AnalyticsRepository {
  Future<BookingReminderListModel> getBookingsNeedingReminder();
  Future<UpcomingBookingsListModel> getUserUpcomingBookings(
    String userId, {
    int hoursAhead = 24,
  });
  Future<List<dynamic>> getDemandPeaks();
  Future<List<dynamic>> getDemandPeaksExtended();
  Future<List<dynamic>> getOwnerIncome();
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteSource remoteSource;
  final AnalyticsLocalSource localAnalytics;
  final AnalyticsExtendedLocalSource localExtended;
  final OwnerIncomeLocalSource localIncome;

  AnalyticsRepositoryImpl({
    required this.remoteSource,
    required this.localAnalytics,
    required this.localExtended,
    required this.localIncome,
  });

  @override
  Future<BookingReminderListModel> getBookingsNeedingReminder() async {
    try {
      return await remoteSource.getBookingsNeedingReminder();
    } catch (e) {
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
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getDemandPeaks() async {
    final isOnline = await Net.isOnline();
    if (isOnline) {
      try {
        final remoteData = await remoteSource.getDemandPeaks();
        final list = List<Map<String, dynamic>>.from(remoteData as List);

        await localAnalytics.cacheDemandData(
          list
              .map((m) => AnalyticsDemandEntity(
                    latZone: (m['lat'] as num?)?.toDouble() ?? 0.0,
                    lonZone: (m['lng'] as num?)?.toDouble() ?? 0.0,
                    rentals: (m['total_rentals'] as int?) ?? 0,
                    lastUpdated: DateTime.now(),
                  ))
              .toList(),
        );

        return remoteData;
      } catch (e) {
        rethrow;
      }
    } else {
      final cached = await localAnalytics.getCachedDemandData();
      return cached;
    }
  }

  @override
  Future<List<dynamic>> getDemandPeaksExtended() async {
    final isOnline = await Net.isOnline();

    if (isOnline) {
      try {
        final remoteData = await remoteSource.getDemandPeaksExtended();
        final list = List<Map<String, dynamic>>.from(remoteData as List);

        await localExtended.cacheExtendedMetrics(
          list.map((m) => AnalyticsExtendedEntity(
                latZone: (m['lat_zone'] as num?)?.toDouble() ?? 0.0,
                lonZone: (m['lon_zone'] as num?)?.toDouble() ?? 0.0,
                hourSlot: (m['hour_slot'] as int?) ?? 0,
                make: m['make'] ?? '',
                year: (m['year'] as int?) ?? 0,
                fuelType: m['fuel_type'] ?? '',
                transmission: m['transmission'] ?? '',
                rentals: (m['rentals'] as int?) ?? 0,
                lastUpdated: DateTime.now(),
              )).toList(),
        );

        return remoteData;
      } catch (e) {
        print('Error in getDemandPeaksExtended: $e');
        rethrow;
      }
    } else {
      final cached = await localExtended.getCachedExtendedMetrics();
      return cached;
    }
  }


  @override
  Future<List<dynamic>> getOwnerIncome() async {
    final isOnline = await Net.isOnline();
    if (isOnline) {
      try {
        final remoteData = await remoteSource.getOwnerIncome();
        final list = List<Map<String, dynamic>>.from(remoteData as List);

        await localIncome.cacheOwnerIncome(
          list
              .map((m) => OwnerIncomeEntity(
                    ownerId: m['owner_id'] ?? '',
                    monthlyIncome:
                        (m['total_income'] as num?)?.toDouble() ?? 0.0,
                    month: m['month'] ?? '',
                    lastUpdated: DateTime.now(),
                  ))
              .toList(),
        );

        return remoteData;
      } catch (e) {
        rethrow;
      }
    } else {
      final cached = await localIncome.getCachedOwnerIncome();
      return cached;
    }
  }
}
