import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/kv_table.dart';

part 'kv_dao.g.dart';

@DriftAccessor(tables: [Kvs])
class KvDao extends DatabaseAccessor<AppDatabase> with _$KvDaoMixin {
  KvDao(AppDatabase db) : super(db);

  Future<void> put(String key, String? value) async {
    await into(kvs).insertOnConflictUpdate(
      KvsCompanion(
        k: Value(key),
        v: Value(value),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<KvEntry?> get(String key) async {
    return (select(kvs)..where((t) => t.k.equals(key))).getSingleOrNull();
  }

  Future<void> remove(String key) async {
    await (delete(kvs)..where((t) => t.k.equals(key))).go();
  }
}
