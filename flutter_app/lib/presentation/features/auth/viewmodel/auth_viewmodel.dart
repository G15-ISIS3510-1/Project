import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  final String
  baseUrl; // para que el View tenga el mismo BASE usado globalmente

  AuthViewModel(this._repo, {required this.baseUrl});

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool get loading => _status == AuthStatus.loading;

  // Resultado de login
  String? _token;
  String? _userId;
  String? get token => _token;
  String? get userId => _userId;

  // Mensaje post-register
  String? _registerMessage;
  String? get registerMessage => _registerMessage;

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _error = null;
    _token = null;
    _userId = null;
    notifyListeners();

    final res = await _repo.login(email: email, password: password);
    return res.when(
      ok: (data) {
        _token = data.token;
        _userId = data.userId;
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      err: (msg) {
        _error = msg;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    _registerMessage = null;
    notifyListeners();

    final res = await _repo.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
    return res.when(
      ok: (msg) {
        _registerMessage = msg;
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      err: (msg) {
        _error = msg;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  void reset() {
    _status = AuthStatus.idle;
    _error = null;
    _registerMessage = null;
    notifyListeners();
  }

  Future<void> saveToken(String token) => _repo.saveToken(token);
}
