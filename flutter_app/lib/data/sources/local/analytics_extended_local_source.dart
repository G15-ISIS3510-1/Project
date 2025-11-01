import '../../database/app_database.dart';

class AnalyticsExtendedLocalSource {
  final AppDatabase _db;
  AnalyticsExtendedLocalSource(this._db);

  Future<void> cacheExtendedMetrics(List<AnalyticsExtendedEntity> data) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.analyticsExtendedTable, data);
    });
  }

  Future<List<AnalyticsExtendedEntity>> getCachedExtendedMetrics() async {
    return await _db.select(_db.analyticsExtendedTable).get();
  }
}
