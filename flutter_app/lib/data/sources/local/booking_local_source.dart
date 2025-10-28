import '../../database/daos/bookings_dao.dart';
import '../../database/daos/infra_dao.dart';
import '../../mappers/booking_db_mapper.dart';
import '../../models/booking_model.dart' as vm;

class BookingLocalSource {
  final BookingsDao dao;
  final InfraDao infra;
  BookingLocalSource(this.dao, this.infra);

  Future<vm.Booking?> getById(String id) async {
    final row = await dao.byId(id);
    return row?.toModel();
  }

  Future<List<vm.Booking>> getPage({
    int skip = 0,
    int limit = 20,
    String? status, // string form (use BookingStatus.asParam when calling)
  }) async {
    final rows = await dao.listPaged(
      limit: limit,
      offset: skip,
      status: status,
    );
    return rows.map((e) => e.toModel()).toList(growable: false);
  }

  Future<void> cacheModels(List<vm.Booking> items) async {
    if (items.isEmpty) return;
    await dao.upsertAll(items.map(bookingModelToDb).toList(growable: false));
  }

  Future<void> checkpoint({
    DateTime? lastFetchAt,
    String? cursor,
    String scope = 'bookings:mine',
  }) {
    return infra.saveState(
      entity: scope,
      lastFetchAt: lastFetchAt,
      pageCursor: cursor,
    );
  }

  Future<void> softDelete(String bookingId) => dao.softDelete(bookingId);
}
