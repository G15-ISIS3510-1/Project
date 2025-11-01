import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/database/daos/infra_dao.dart';
import 'package:flutter_app/data/database/daos/vehicles_dao.dart';
import 'package:flutter_app/data/database/tables/analytics_table.dart';
import 'package:flutter_app/data/database/tables/bookings_table.dart';
import 'package:flutter_app/data/database/tables/conversations_table.dart';
import 'package:flutter_app/data/database/tables/infra_tables.dart';
import 'package:flutter_app/data/database/tables/kv_table.dart';
import 'package:flutter_app/data/database/tables/messages_table.dart';
import 'package:flutter_app/data/database/tables/pricing_table.dart';
import 'package:flutter_app/data/database/tables/vehicle_availability_table.dart';
import 'package:flutter_app/data/database/tables/vehicles_table.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

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
    AnalyticsDemandTable,
    AnalyticsExtendedTable,
    OwnerIncomeTable
  ],
  daos: [VehiclesDao, InfraDao],
)
class AppDatabase extends _$AppDatabase {
  /// ⭐ para saber a qué usuario pertenece esta conexión
  final String ownerUid;

  bool _closed = false;
  bool get isClosed => _closed;

  AppDatabase.forUser(this.ownerUid) : super(_openFor(ownerUid));
  AppDatabase() : ownerUid = 'anon', super(_open());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      debugPrint('[DB] Creating all tables...');
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      debugPrint('[DB] Upgrading from v$from to v$to, recreating schema...');
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
    beforeOpen: (details) async {
      debugPrint('[DB] Opening database (version ${details.versionNow})');
    },
  );


  @override
  Future<void> close() async {
    _closed = true;
    await super.close();
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'qovo.db'));
    return NativeDatabase.createInBackground(file);
  });
}

String _safeUid(String raw) {
  // hash corto y estable para nombre de archivo
  final d = sha1.convert(utf8.encode(raw));
  return d.toString(); // 40 hex chars
}

LazyDatabase _openFor(String uid) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = _safeUid(uid); // ← usa el hashed
    final file = File(p.join(dir.path, 'qovo_$safe.db'));
    debugPrint('[DB] open for uid=$uid path=${file.path}');
    return NativeDatabase.createInBackground(file);
  });
}
