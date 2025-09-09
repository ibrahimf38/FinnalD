import 'api_service.dart';

class ProfilService {
  final ApiService _api = ApiService();

  Future<dynamic> getProfil(String userId) async {
    try {
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
