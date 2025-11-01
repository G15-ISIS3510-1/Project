import 'package:drift/drift.dart';
import 'package:flutter_app/data/database/tables/infra_tables.dart';
import '../app_database.dart';

part 'infra_dao.g.dart';

@DriftAccessor(tables: [SyncState, PendingOps])
class InfraDao extends DatabaseAccessor<AppDatabase> with _$InfraDaoMixin {
  InfraDao(AppDatabase db) : super(db);

  Future<SyncStateData?> getState(String entity) async {
    final q = select(syncState)..where((t) => t.entity.equals(entity));
    return await q.getSingleOrNull();
  }

  Future<int> clearAll() async {
    final a = await (delete(syncState)).go();
    final b = await (delete(pendingOps)).go();
    return a + b;
  }

  Future<void> saveState({
    required String entity,
    DateTime? lastFetchAt,
    String? etag,
    String? pageCursor,
  }) async {
    await into(syncState).insertOnConflictUpdate(
      SyncStateCompanion(
        entity: Value(entity),
        lastFetchAt: Value(lastFetchAt),
        etag: Value(etag),
        pageCursor: Value(pageCursor),
      ),
    );
  }

  Future<int> enqueue(PendingOpsCompanion op) => into(pendingOps).insert(op);

  Future<PendingOpsData?> nextPending() async {
    return (select(pendingOps)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> markDone(int id) =>
      (update(pendingOps)..where((t) => t.id.equals(id))).write(
        const PendingOpsCompanion(status: Value('done')),
      );

  Future<void> reschedule({
    required int id,
    required int attempts,
    required DateTime nextRetryAt,
  }) => (update(pendingOps)..where((t) => t.id.equals(id))).write(
    PendingOpsCompanion(
      attempts: Value(attempts),
      nextRetryAt: Value(nextRetryAt),
      status: const Value('pending'),
    ),
  );
}
