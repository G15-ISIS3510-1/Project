import 'package:drift/drift.dart';

@DataClassName('SyncStateData')
class SyncState extends Table {
  TextColumn get entity => text()(); // 'vehicles', 'messages:conv=<id>', etc.
  DateTimeColumn get lastFetchAt => dateTime().nullable()();
  TextColumn get etag => text().nullable()();
  TextColumn get pageCursor => text().nullable()();
  @override
  Set<Column> get primaryKey => {entity};
}

@DataClassName('PendingOpsData')
class PendingOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get method => text()(); // 'POST' | 'PUT' | 'DELETE'
  TextColumn get url => text()(); // relativo o absoluto
  TextColumn get headers => text().nullable()(); // JSON (string)
  BlobColumn get body => blob().nullable()(); // bytes del body (JSON/multipart)
  TextColumn get kind => text()(); // 'CREATE_VEHICLE','UPLOAD_IMAGE',...
  TextColumn get correlationId => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending|done
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
