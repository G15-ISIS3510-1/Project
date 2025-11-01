import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/bookings_table.dart';

part 'bookings_dao.g.dart';

@DriftAccessor(tables: [Bookings])
class BookingsDao extends DatabaseAccessor<AppDatabase>
    with _$BookingsDaoMixin {
  BookingsDao(AppDatabase db) : super(db);

  Future<void> upsertAll(List<BookingsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(bookings, rows));
  }

  Future<int> clearAll() => delete(bookings).go();

  Future<BookingsData?> byId(String id) => (select(
    bookings,
  )..where((t) => t.bookingId.equals(id))).getSingleOrNull();

  Future<List<BookingsData>> listMine({
    required String userId,
    required bool asHost, // true -> hostId==userId, false -> renterId==userId
    String? status, // optional status filter
    int limit = 50,
    int offset = 0,
  }) {
    final q = select(bookings)
      ..where(
        (t) =>
            (asHost ? t.hostId.equals(userId) : t.renterId.equals(userId)) &
            t.isDeleted.equals(false),
      );

    if (status != null && status.isNotEmpty) {
      q.where((t) => t.status.equals(status));
    }

    // ✅ cascade on q, not on orderBy
    q
      ..orderBy([(t) => OrderingTerm.desc(t.startTs)])
      ..limit(limit, offset: offset);

    return q.get();
  }

  Future<void> softDelete(String bookingId) async {
    await (update(bookings)..where((t) => t.bookingId.equals(bookingId))).write(
      const BookingsCompanion(isDeleted: Value(true)),
    );
  }

  Future<List<BookingsData>> listPaged({
    int limit = 20,
    int offset = 0,
    String? status,
  }) {
    final q = select(bookings)..where((t) => t.isDeleted.equals(false));

    if (status != null && status.isNotEmpty) {
      q.where((t) => t.status.equals(status));
    }

    // ✅ cascade on q, not on orderBy
    q
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);

    return q.get();
  }
}
