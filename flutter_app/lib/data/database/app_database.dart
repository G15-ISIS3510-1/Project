import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_app/data/database/daos/infra_dao.dart';
import 'package:flutter_app/data/database/daos/vehicles_dao.dart';
import 'package:flutter_app/data/database/tables/bookings_table.dart';
import 'package:flutter_app/data/database/tables/conversations_table.dart';
import 'package:flutter_app/data/database/tables/kv_table.dart';
import 'package:flutter_app/data/database/tables/messages_table.dart';
import 'package:flutter_app/data/database/tables/pricing_table.dart';
import 'package:flutter_app/data/database/tables/vehicle_availability_table.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/infra_tables.dart';
import 'tables/vehicles_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    SyncState,
    PendingOps,
    VehicleAvailability,
    Conversations,
    Messages,
    Pricings,
    Bookings,
    Kvs,
  ],
  daos: [VehiclesDao, InfraDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {},
  );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'qovo.db'));
    return NativeDatabase.createInBackground(file);
  });
}
