
import 'api_service.dart';

class LoginService {
  final ApiService _api = ApiService();

  Future<dynamic> login(Map<String, dynamic> loginData) async {
    try {
      return await _api.postData("api/auth/login", loginData);
    } catch (e) {
      throw Exception("LoginService: Impossible de se connecter: $e");
    }
  }

  Future<dynamic> registerUser(Map<String, dynamic> registerData) async {
    try {
      return await _api.postData("api/auth/register/user", registerData);
    } catch (e) {
      throw Exception("LoginService: Impossible d'ajouter USER: $e");
    }
  }

}

