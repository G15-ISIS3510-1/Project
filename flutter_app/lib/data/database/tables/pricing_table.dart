import 'package:drift/drift.dart';

@DataClassName('PricingData')
class Pricings extends Table {
  TextColumn get pricingId => text()(); // pricing_id (UUID)
  TextColumn get vehicleId => text()(); // vehicle_id
  RealColumn get dailyPrice => real()(); // daily_price
  IntColumn get minDays => integer()(); // min_days
  IntColumn get maxDays => integer().nullable()(); // max_days (nullable)
  TextColumn get currency => text()(); // currency (USD, etc.)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {pricingId};
}
