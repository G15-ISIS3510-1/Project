import 'dart:convert';

import 'package:flutter_app/data/sources/remote/user_remote_source.dart';

abstract class UserRepository {
  Future<Map<String, dynamic>?> getUser(String userId, {bool refresh = false});
  Future<String?> getUserName(String userId, {bool refresh = false});
  Future<({String? name, String? role})> getUserNameAndRole(
    String userId, {
    bool refresh = false,
  });
  Future<String?> getUserRole(String userId, {bool refresh = false});

  void clearCacheFor(String userId);
  void clearAllCache();
}

class UserRepositoryImpl implements UserRepository {
  final UserService remote;
  UserRepositoryImpl({required this.remote});

  // cache en memoria: userId -> json
  final Map<String, Map<String, dynamic>> _cache = {};

  @override
  void clearCacheFor(String userId) => _cache.remove(userId);

  @override
  void clearAllCache() => _cache.clear();

  @override
  Future<Map<String, dynamic>?> getUser(
    String userId, {
    bool refresh = false,
  }) async {
    if (!refresh && _cache.containsKey(userId)) {
      return _cache[userId];
    }

    final res = await remote.getUserRaw(userId);
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _cache[userId] = data;
    return data;
  }

  @override
  Future<String?> getUserName(String userId, {bool refresh = false}) async {
    final u = await getUser(userId, refresh: refresh);
    if (u == null) return null;
    return (u['name'] as String?) ??
        (u['full_name'] as String?) ??
        (u['email'] as String?);
  }

  @override
  Future<({String? name, String? role})> getUserNameAndRole(
    String userId, {
    bool refresh = false,
  }) async {
    final u = await getUser(userId, refresh: refresh);
    if (u == null) return (name: null, role: null);
    final name =
        (u['name'] as String?) ??
        (u['full_name'] as String?) ??
        (u['email'] as String?);
    final role = _normalizeRole(u);
    return (name: name, role: role);
  }

  @override
  Future<String?> getUserRole(String userId, {bool refresh = false}) async {
    final u = await getUser(userId, refresh: refresh);
    return _normalizeRole(u);
  }

  // ---------- helpers ----------
  String? _normalizeRole(Map<String, dynamic>? u) {
    if (u == null) return null;

    final roleRaw = u['role'];
    if (roleRaw is String && roleRaw.isNotEmpty) {
      final r = roleRaw.toLowerCase();
      if (r == 'renter' || r == 'host' || r == 'both') return r;
    }

    final roles = u['roles'];
    if (roles is List) {
      final set = roles.map((e) => e.toString().toLowerCase()).toSet();
      final hasHost = set.contains('host');
      final hasRenter = set.contains('renter');
      if (hasHost && hasRenter) return 'both';
      if (hasHost) return 'host';
      if (hasRenter) return 'renter';
    }

    final isHost =
        _asBool(u['is_host']) || _asBool(u['host']) || _asBool(u['isHost']);
    final isRenter =
        _asBool(u['is_renter']) ||
        _asBool(u['renter']) ||
        _asBool(u['isRenter']);

    if (isHost && isRenter) return 'both';
    if (isHost) return 'host';
    if (isRenter) return 'renter';
    return null;
  }

  bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }
}
