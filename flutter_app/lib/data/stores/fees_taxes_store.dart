import 'dart:convert';

import '../database/daos/kv_dao.dart';

class CachedFeesTaxesAverage {
  final double average;
  final int sampleSize;
  final DateTime savedAt;

  CachedFeesTaxesAverage({
    required this.average,
    required this.sampleSize,
    required this.savedAt,
  });

  bool isFresh(Duration ttl) {
    final now = DateTime.now().toUtc();
    return now.difference(savedAt.toUtc()) <= ttl;
  }

  Map<String, dynamic> toJson() => {
        'average': average,
        'sample_size': sampleSize,
        'saved_at': savedAt.toUtc().toIso8601String(),
      };

  factory CachedFeesTaxesAverage.fromJson(Map<String, dynamic> json) {
    return CachedFeesTaxesAverage(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      sampleSize: (json['sample_size'] as num?)?.toInt() ?? 0,
      savedAt: DateTime.tryParse(json['saved_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class FeesTaxesStore {
  final KvDao _kv;
  FeesTaxesStore(this._kv);

  String _key(String userId, {required bool asHost}) =>
      'fees_taxes_avg:$userId:${asHost ? 'host' : 'renter'}';

  Future<void> save({
    required String userId,
    required bool asHost,
    required double average,
    required int sampleSize,
  }) async {
    final payload = CachedFeesTaxesAverage(
      average: average,
      sampleSize: sampleSize,
      savedAt: DateTime.now().toUtc(),
    );
    await _kv.put(_key(userId, asHost: asHost), jsonEncode(payload.toJson()));
  }

  Future<CachedFeesTaxesAverage?> load({
    required String userId,
    required bool asHost,
    Duration? ttl,
  }) async {
    final row = await _kv.get(_key(userId, asHost: asHost));
    if (row?.v == null) return null;
    try {
      final decoded = jsonDecode(row!.v!);
      if (decoded is Map<String, dynamic>) {
        final cached = CachedFeesTaxesAverage.fromJson(decoded);
        if (ttl == null || cached.isFresh(ttl)) {
          return cached;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> clear(String userId, {required bool asHost}) async {
    await _kv.remove(_key(userId, asHost: asHost));
  }
}
