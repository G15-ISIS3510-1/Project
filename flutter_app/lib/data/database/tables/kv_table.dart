import 'package:drift/drift.dart';

@DataClassName('KvEntry')
class Kvs extends Table {
  TextColumn get k => text()(); // clave
  TextColumn get v => text().nullable()(); // valor (JSON/string)
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {k};
}
