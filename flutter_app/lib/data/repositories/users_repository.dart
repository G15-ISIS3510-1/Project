// lib/presentation/features/messages/viewmodel/users_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_app/data/sources/remote/user_remote_source.dart';

class UsersRepository {
  final UserService _remote;

  UsersRepository({UserService? remote}) : _remote = remote ?? UserService();

  Future<String?> getUserName(String userId) async {
    final http.Response res = await _remote.getUserRaw(userId);
    if (res.statusCode != 200) return null;
    final j = jsonDecode(res.body);
    if (j is Map<String, dynamic>) {
      // intenta varios campos comunes
      final name =
          (j['name'] ??
          j['full_name'] ??
          (j['first_name'] != null && j['last_name'] != null
              ? '${j['first_name']} ${j['last_name']}'
              : null) ??
          j['email']);
      return name?.toString();
    }
    return null;
  }

  /// Retorna 'renter' | 'host' | 'both' | null
  Future<String?> getUserRole(String userId) async {
    final http.Response res = await _remote.getUserRaw(userId);
    if (res.statusCode != 200) return null;
    final j = jsonDecode(res.body);
    if (j is Map<String, dynamic>) {
      // casos posibles: role: "host"/"renter"/"both"  o  roles: ["host","renter"]
      final role = j['role'];
      if (role is String && role.isNotEmpty) return role.toLowerCase();

      final roles = j['roles'];
      if (roles is List) {
        final set = roles.map((e) => e.toString().toLowerCase()).toSet();
        if (set.contains('host') && set.contains('renter')) return 'both';
        if (set.contains('host')) return 'host';
        if (set.contains('renter')) return 'renter';
      }
    }
    return null;
  }
}
