// lib/data/utils/pagination.dart
import 'dart:convert';

class Paginated<T> {
  final List<T> items;
  final int? total;
  final int skip;
  final int limit;
  final bool hasMore;
  final String? nextCursor;

  Paginated({
    required this.items,
    required this.hasMore,
    this.total,
    this.skip = 0,
    this.limit = 0,
    this.nextCursor,
  });

  /// Convenience to compute the next 'skip' value when using offset pagination.
  int get nextSkip => skip + limit;
}

/// Extrae una página paginada desde un body JSON con múltiples formatos comunes.
/// - items en: "items", "results", "data.items", "data.results", "data.list", "list"
/// - total en: "total", "count", "total_count"
/// - paginación: "skip"/"offset", "limit"/"page_size"
/// - has_more directo, o deducido de total/skip/limit, o presencia de "next"/"next_cursor".
Paginated<T> parsePaginated<T>(
  String body,
  T Function(Map<String, dynamic>) mapper,
) {
  final raw = jsonDecode(body);

  if (raw is! Map<String, dynamic>) {
    throw Exception('Expected a paginated Map payload but got: $raw');
  }

  Map<String, dynamic>? _asMap(dynamic v) =>
      v is Map<String, dynamic> ? v : null;
  List<Map<String, dynamic>> _asList(dynamic v) =>
      (v as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> root = raw;

  // --- ITEMS ---
  List<Map<String, dynamic>>? itemsMapList;

  // nivel 1
  for (final key in ['items', 'results', 'list', 'data']) {
    final v = root[key];
    if (v is List) {
      itemsMapList = _asList(v);
      break;
    }
    if (v is Map<String, dynamic>) {
      // nivel 2
      for (final k2 in ['items', 'results', 'list']) {
        final vv = v[k2];
        if (vv is List) {
          itemsMapList = _asList(vv);
          break;
        }
      }
      if (itemsMapList != null) break;
    }
  }

  // fallback: si root trae directamente una lista (raro ya con paginación)
  if (itemsMapList == null && root is Map && root['data'] is List) {
    itemsMapList = _asList(root['data']);
  }

  if (itemsMapList == null) {
    throw Exception('Paginated payload: items not found in: $root');
  }

  // --- META ---
  int? total;
  for (final k in ['total', 'count', 'total_count']) {
    if (root[k] is num) {
      total = (root[k] as num).toInt();
      break;
    }
    // a veces viene en data.total
    final data = _asMap(root['data']);
    if (data != null && data[k] is num) {
      total = (data[k] as num).toInt();
      break;
    }
  }

  int skip = 0;
  for (final k in ['skip', 'offset']) {
    if (root[k] is num) {
      skip = (root[k] as num).toInt();
      break;
    }
  }

  int limit = 0;
  for (final k in ['limit', 'page_size']) {
    if (root[k] is num) {
      limit = (root[k] as num).toInt();
      break;
    }
  }

  // next/has_more
  String? nextCursor =
      (root['next_cursor'] ?? root['cursor_next'] ?? root['next'])?.toString();
  bool hasMore = false;
  if (root['has_more'] is bool) {
    hasMore = root['has_more'] as bool;
  } else if (nextCursor != null && nextCursor.isNotEmpty) {
    hasMore = true;
  } else if (total != null && limit > 0) {
    hasMore = (skip + itemsMapList.length) < total;
  } else if (limit > 0) {
    hasMore = itemsMapList.length == limit;
  }

  final items = itemsMapList.map(mapper).toList(growable: false);

  return Paginated<T>(
    items: items,
    total: total,
    skip: skip,
    limit: limit,
    hasMore: hasMore,
    nextCursor: nextCursor,
  );
}
