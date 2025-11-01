import 'package:drift/drift.dart';
import 'package:flutter_app/data/database/app_database.dart';
import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/models/booking_status.dart';
import '../database/tables/bookings_table.dart';

// DB row -> Front model
extension BookingRowToModel on BookingsData {
  Booking toModel() => Booking(
    bookingId: bookingId,
    vehicleId: vehicleId,
    renterId: renterId,
    hostId: hostId,
    startTs: startTs.toLocal(),
    endTs: endTs.toLocal(),
    status: BookingStatus.fromString(status),
    dailyPriceSnapshot: dailyPriceSnapshot,
    insuranceDailyCostSnapshot: insuranceDailyCostSnapshot,
    subtotal: subtotal,
    fees: fees ?? 0.0,
    taxes: taxes ?? 0.0,
    total: total,
    currency: currency,
    odoStart: odoStart,
    odoEnd: odoEnd,
    fuelStart: fuelStart,
    fuelEnd: fuelEnd,
    createdAt: createdAt.toLocal(),
  );
}

// Front model -> DB row (for cache)
BookingsCompanion bookingModelToDb(Booking b) {
  DateTime _asUtc(DateTime dt) => dt.toUtc();

  return BookingsCompanion(
    bookingId: Value(b.bookingId),
    vehicleId: Value(b.vehicleId),
    renterId: Value(b.renterId),
    hostId: Value(b.hostId),
    startTs: Value(_asUtc(b.startTs)),
    endTs: Value(_asUtc(b.endTs)),
    dailyPriceSnapshot: Value(b.dailyPriceSnapshot),
    insuranceDailyCostSnapshot: Value(b.insuranceDailyCostSnapshot),
    subtotal: Value(b.subtotal),
    fees: Value(b.fees),
    taxes: Value(b.taxes),
    total: Value(b.total),
    currency: Value(b.currency),
    odoStart: Value(b.odoStart),
    odoEnd: Value(b.odoEnd),
    fuelStart: Value(b.fuelStart),
    fuelEnd: Value(b.fuelEnd),
    status: Value(b.status.asParam), // string form
    createdAt: Value(_asUtc(b.createdAt)),
    isDeleted: const Value(false),
  );
}
