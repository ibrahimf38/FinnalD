import 'api_service.dart';

class ProfilService {
  final ApiService _api = ApiService();



  /// Gère l'inscription d'un nouvel utilisateur.
  Future<dynamic> signup(String nom, String prenom, String email, String password, String phone) async {
    try {
      final data = {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'phoneNumber': phone,
      };
      // Endpoint d'inscription
      return await _api.postData("api/users/register", data);
    } catch (e) {
      // Propagation de l'exception pour affichage dans la Snackbar
      throw Exception("ProfilService: Erreur lors de l'inscription: $e");
    }
  }

  /// Gère la connexion de l'utilisateur.
  Future<dynamic> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };
      // Endpoint de connexion
      return await _api.postData("api/users/login", data);
    } catch (e) {
      // Propagation de l'exception pour affichage dans la Snackbar
      throw Exception("ProfilService: Erreur lors de la connexion: $e");
    }
  }

  Future<dynamic> getProfil(String userId) async {
    try {
      // NOTE: L'ID utilisateur doit être inclus dans l'URL ou géré par le middleware d'auth
      return await _api.getData("api/profils/$userId");
    } catch (e) {
      throw Exception("ProfilService: Impossible de charger le profil: $e");
    }
  }

  Future<dynamic> updateProfil(String userId, Map<String, dynamic> profilData) async {
    try {
      return await _api.putData("api/profils/$userId", profilData);
    } catch (e) {
      throw Exception("ProfilService: Impossible de mettre à jour le profil: $e");
    }
  }

  Future<void> deleteProfil(String userId) async {
    try {
      await _api.deleteData("api/profils/$userId");
    } catch (e) {
      throw Exception("ProfilService: Impossible de supprimer le profil: $e");
    }
  }
}