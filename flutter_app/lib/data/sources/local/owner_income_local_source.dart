import '../../database/app_database.dart';

class OwnerIncomeLocalSource {
  final AppDatabase _db;
  OwnerIncomeLocalSource(this._db);

  Future<void> cacheOwnerIncome(List<OwnerIncomeEntity> data) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.ownerIncomeTable, data);
    });
  }

  Future<List<OwnerIncomeEntity>> getCachedOwnerIncome() async {
    return await _db.select(_db.ownerIncomeTable).get();
  }
}
