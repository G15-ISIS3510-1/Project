import 'package:drift/drift.dart';

@DataClassName('AnalyticsDemandEntity')
class AnalyticsDemandTable extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  RealColumn get latZone => real()();     
  RealColumn get lonZone => real()();     
  IntColumn get rentals => integer()();   
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AnalyticsExtendedEntity')
class AnalyticsExtendedTable extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  RealColumn get latZone => real().named('lat_zone')();
  RealColumn get lonZone => real().named('lon_zone')();
  IntColumn get hourSlot => integer().named('hour_slot')();
  TextColumn get make => text().named('make')();
  IntColumn get year => integer().named('year')();
  TextColumn get fuelType => text().named('fuel_type')();
  TextColumn get transmission => text().named('transmission')();
  IntColumn get rentals => integer().named('rentals')();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
}


@DataClassName('OwnerIncomeEntity')
class OwnerIncomeTable extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  TextColumn get ownerId => text()();       
  RealColumn get monthlyIncome => real()(); 
  TextColumn get month => text()();         
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}
