import '../../database/app_database.dart';

class AnalyticsLocalSource {
  final AppDatabase _db;
  AnalyticsLocalSource(this._db);

  Future<void> cacheDemandData(List<AnalyticsDemandEntity> data) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.analyticsDemandTable, data);
    });
  }

  Future<List<AnalyticsDemandEntity>> getCachedDemandData() async {
    return await _db.select(_db.analyticsDemandTable).get();
  }
}
