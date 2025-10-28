import 'dart:convert';
import 'package:dio/dio.dart';
import '../database/daos/infra_dao.dart';
import '../database/app_database.dart';

import '../database/app_database.dart';
import '../database/tables/infra_tables.dart';

class OutboxWorker {
  final InfraDao infra;
  final Dio dio;
  OutboxWorker({required this.infra, required this.dio});

  Future<void> drainOnce() async {
    final job = await infra.nextPending();
    if (job == null) return;

    if (job.nextRetryAt != null && DateTime.now().isBefore(job.nextRetryAt!))
      return;

    try {
      final headers = job.headers == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(job.headers!));

      Response res;
      switch (job.method) {
        case 'POST':
          res = await dio.post(
            job.url,
            data: job.body == null ? null : utf8.decode(job.body!),
            options: Options(headers: headers),
          );
          break;
        case 'PUT':
          res = await dio.put(
            job.url,
            data: job.body == null ? null : utf8.decode(job.body!),
            options: Options(headers: headers),
          );
          break;
        case 'DELETE':
          res = await dio.delete(job.url, options: Options(headers: headers));
          break;
        default:
          throw Exception('Unsupported method ${job.method}');
      }

      if ((res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300) {
        await infra.markDone(job.id);
        // TODO: si el body devuelve el objeto, aquí puedes upsert al DB
      } else {
        await _retry(job);
      }
    } catch (_) {
      await _retry(job);
    }
  }

  Future<void> _retry(PendingOpsData job) async {
    final attempts = job.attempts + 1;
    final delay = Duration(seconds: (1 << (attempts.clamp(0, 5))) * 2); // 2..64
    await infra.reschedule(
      id: job.id,
      attempts: attempts,
      nextRetryAt: DateTime.now().add(delay),
    );
  }
}
