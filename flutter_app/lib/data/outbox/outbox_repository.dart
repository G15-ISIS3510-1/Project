import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:flutter_app/data/database/app_database.dart';
import '../database/daos/infra_dao.dart';

class OutboxRepository {
  final InfraDao infra;
  OutboxRepository(this.infra);

  Future<void> enqueueJson({
    required String method,
    required String url,
    Map<String, String>? headers,
    required Map<String, dynamic> json,
    required String kind,
    String? correlationId,
  }) async {
    await infra.enqueue(
      PendingOpsCompanion.insert(
        method: method,
        url: url,
        headers: Value(headers == null ? null : jsonEncode(headers)),
        body: Value(Uint8List.fromList(utf8.encode(jsonEncode(json)))),
        kind: kind,
        correlationId: Value(correlationId),
      ),
    );
  }
}
