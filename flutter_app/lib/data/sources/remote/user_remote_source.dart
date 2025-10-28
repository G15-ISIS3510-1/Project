// // lib/data/users_api.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class UsersApi {
//   final String baseUrl; // ej: https://qovo-api-862569067561.us-central1.run.app/api
//   final String token;
//   UsersApi({required this.baseUrl, required this.token});

//   Map<String, String> get _headers => {
//     'Authorization': 'Bearer $token',
//     'Content-Type': 'application/json',
//   };

//   // --- Caché en memoria ---
//   final Map<String, Map<String, dynamic>> _userCache = {}; // userId -> json

//   /// Limpia caché de un usuario
//   void clearCacheFor(String userId) => _userCache.remove(userId);

//   /// Limpia toda la caché
//   void clearAllCache() => _userCache.clear();

//   /// Devuelve el JSON del usuario (name, email, role, etc.)
//   /// [refresh] para forzar ir a red.
//   Future<Map<String, dynamic>?> getUser(
//     String userId, {
//     bool refresh = false,
//   }) async {
//     if (!refresh) {
//       final cached = _userCache[userId];
//       if (cached != null) return cached;
//     }

//     final uri = Uri.parse('$baseUrl/users/$userId');
//     final res = await http.get(uri, headers: _headers);
//     if (res.statusCode != 200) return null;

//     final data = json.decode(res.body) as Map<String, dynamic>;
//     _userCache[userId] = data;
//     return data;
//   }

//   /// Devuelve nombre amigable del usuario (name > full_name > email)
//   Future<String?> getUserName(String userId, {bool refresh = false}) async {
//     final u = await getUser(userId, refresh: refresh);
//     if (u == null) return null;
//     return (u['name'] as String?) ??
//         (u['full_name'] as String?) ??
//         (u['email'] as String?);
//   }

//   /// Devuelve (name, role) normalizados
//   Future<({String? name, String? role})> getUserNameAndRole(
//     String userId, {
//     bool refresh = false,
//   }) async {
//     final u = await getUser(userId, refresh: refresh);
//     if (u == null) return (name: null, role: null);
//     final name =
//         (u['name'] as String?) ??
//         (u['full_name'] as String?) ??
//         (u['email'] as String?);
//     final role = _normalizeRole(u);
//     return (name: name, role: role);
//   }

//   /// Devuelve el rol del usuario ('renter' | 'host' | 'both'), normalizado
//   Future<String?> getUserRole(String userId, {bool refresh = false}) async {
//     final u = await getUser(userId, refresh: refresh);
//     return _normalizeRole(u);
//   }

//   // ----------------- Helpers privados -----------------

//   /// Normaliza el rol a 'renter' | 'host' | 'both' a partir de distintos formatos.
//   String? _normalizeRole(Map<String, dynamic>? u) {
//     if (u == null) return null;

//     // 1) Campo role directo
//     final roleRaw = u['role'];
//     if (roleRaw is String && roleRaw.isNotEmpty) {
//       final r = roleRaw.toLowerCase();
//       if (r == 'renter' || r == 'host' || r == 'both') return r;
//     }

//     // 2) Campo roles como lista
//     final roles = u['roles'];
//     if (roles is List) {
//       final set = roles.map((e) => e.toString().toLowerCase()).toSet();
//       final hasHost = set.contains('host');
//       final hasRenter = set.contains('renter');
//       if (hasHost && hasRenter) return 'both';
//       if (hasHost) return 'host';
//       if (hasRenter) return 'renter';
//     }

//     // 3) Flags booleanos
//     final isHost =
//         _asBool(u['is_host']) || _asBool(u['host']) || _asBool(u['isHost']);
//     final isRenter =
//         _asBool(u['is_renter']) ||
//         _asBool(u['renter']) ||
//         _asBool(u['isRenter']);

//     if (isHost && isRenter) return 'both';
//     if (isHost) return 'host';
//     if (isRenter) return 'renter';

//     // 4) Fallback: si no hay nada, null (desconocido)
//     return null;
//   }

//   bool _asBool(dynamic v) {
//     if (v is bool) return v;
//     if (v is num) return v != 0;
//     if (v is String) {
//       final s = v.toLowerCase().trim();
//       return s == 'true' || s == '1' || s == 'yes';
//     }
//     return false;
//   }
// }

import 'api_client.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<http.Response> getUserRaw(String userId) {
    return Api.I().get('/api/users/$userId');
  }
}
