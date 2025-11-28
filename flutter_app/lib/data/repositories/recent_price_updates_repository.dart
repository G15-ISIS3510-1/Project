// flutter_app/lib/data/repositories/recent_price_updates_repository.dart

import '../../app/utils/net.dart';
import '../sources/remote/analytics_remote_source.dart';

class RecentPriceUpdatesResult {
  final double averagePrice;
  final int sampleSize;
  final bool usedCache;
  final DateTime fetchedAt;

  RecentPriceUpdatesResult({
    required this.averagePrice,
    required this.sampleSize,
    required this.usedCache,
    required this.fetchedAt,
  });
}

abstract class RecentPriceUpdatesRepository {
  Future<RecentPriceUpdatesResult> getAverageDailyPrice({
    bool forceRefresh = false,
  });
}

class RecentPriceUpdatesRepositoryImpl implements RecentPriceUpdatesRepository {
  final AnalyticsRemoteSource remote;

  RecentPriceUpdatesRepositoryImpl({required this.remote});

  @override
  Future<RecentPriceUpdatesResult> getAverageDailyPrice({
    bool forceRefresh = false,
  }) async {
    final isOnline = await Net.isOnline();

    if (!isOnline) {
      // Offline fallback: no data
      return RecentPriceUpdatesResult(
        averagePrice: 0,
        sampleSize: 0,
        usedCache: true,
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    final List<dynamic> updates = await remote.getRecentPriceUpdates();

    if (updates.isEmpty) {
      return RecentPriceUpdatesResult(
        averagePrice: 0,
        sampleSize: 0,
        usedCache: false,
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    double sum = 0;
    int count = 0;

    for (final u in updates) {
      // backend returns: pricing_id, vehicle_id, daily_price, last_updated
      final price = (u['daily_price'] as num?)?.toDouble();
      if (price != null) {
        sum += price;
        count++;
      }
    }

    if (count == 0) {
      return RecentPriceUpdatesResult(
        averagePrice: 0,
        sampleSize: 0,
        usedCache: false,
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    return RecentPriceUpdatesResult(
      averagePrice: sum / count,
      sampleSize: count,
      usedCache: false,
      fetchedAt: DateTime.now().toUtc(),
    );
  }
}
