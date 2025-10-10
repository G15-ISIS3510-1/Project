import 'api_client.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<http.Response> getUserRaw(String userId) {
    return Api.I().get('/api/users/$userId');
  }
}
