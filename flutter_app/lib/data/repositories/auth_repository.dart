import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/auth_remote_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRepository {
  Future<Result<({String token, String userId})>> login({
    required String email,
    required String password,
  });

  /// Devuelve mensaje de éxito para UI según status code (201/200/409)
  Future<Result<String>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  });

  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> clearToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService remote;
  final FlutterSecureStorage storage;

  AuthRepositoryImpl({required this.remote, FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  static const _kToken = 'access_token';

  @override
  Future<Result<({String token, String userId})>> login({
    required String email,
    required String password,
  }) async {
    try {
      final token = await remote.login(email: email, password: password);

      // 1) Inyecta token global para TODAS las requests
      Api.I().setToken(token);

      // 2) Persiste para próximos arranques
      await saveToken(token);

      // 3) Ya no pases token: AuthService usa Api.I()
      final me = await remote.me();
      final userId = (me['user_id'] as String?) ?? '';
      if (userId.isEmpty) {
        return Result.err('No se pudo determinar user_id desde /me');
      }
      return Result.ok((token: token, userId: userId));
    } catch (e) {
      return Result.err(e.toString());
    }
  }

  @override
  Future<Result<String>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    try {
      final r = await remote.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      // Semántica según tu backend actual
      switch (r.code) {
        case 201:
          return Result.ok('✅ Registro exitoso');
        case 200:
          return Result.ok('✅ Tu cuenta ahora es BOTH (renter + host)');
        case 409:
          return Result.ok('Ya estás registrado con ese rol. Inicia sesión.');
        default:
          return Result.err('❌ Error ${r.code}: ${r.body}');
      }
    } catch (e) {
      return Result.err('⚠️ Error de red: $e');
    }
  }

  @override
  Future<void> saveToken(String token) =>
      storage.write(key: _kToken, value: token);

  @override
  Future<String?> readToken() => storage.read(key: _kToken);

  @override
  Future<void> clearToken() => storage.delete(key: _kToken);
}
