import 'package:drift/drift.dart';

@DataClassName('BookingsData')
class Bookings extends Table {
  TextColumn get bookingId => text()(); // booking_id
  TextColumn get vehicleId => text()(); // vehicle_id
  TextColumn get renterId => text()(); // renter_id
  TextColumn get hostId => text()(); // host_id

  DateTimeColumn get startTs => dateTime()(); // start_ts
  DateTimeColumn get endTs => dateTime()(); // end_ts

  RealColumn get dailyPriceSnapshot => real()(); // daily_price_snapshot
  RealColumn get insuranceDailyCostSnapshot => real().nullable()();
  RealColumn get subtotal => real()();
  RealColumn get fees => real().nullable()();
  RealColumn get taxes => real().nullable()();
  RealColumn get total => real()();
  TextColumn get currency => text()(); // currency

  IntColumn get odoStart => integer().nullable()(); // odo_start
  IntColumn get odoEnd => integer().nullable()(); // odo_end
  IntColumn get fuelStart => integer().nullable()(); // fuel_start
  IntColumn get fuelEnd => integer().nullable()(); // fuel_end

  TextColumn get status => text()(); // status (enum as string)
  DateTimeColumn get createdAt => dateTime()(); // created_at

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {bookingId};
}
