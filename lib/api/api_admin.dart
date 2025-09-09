import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();


  Future<List<dynamic>> getAdmins() async {
    try {
      final data = await _api.getData("api/admins");

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('admins')) {
        return data['admins'];
      } else if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("AdminService: Impossible de charger les administrateurs: $e");
    }
  }

  Future<dynamic> addAdmin(Map<String, dynamic> adminData) async {
    try {
      return await _api.postData("api/admins", adminData);
    } catch (e) {
      throw Exception("AdminService: Impossible d'ajouter l'administrateur: $e");
    }
  }

  Future<dynamic> updateAdmin(String id, Map<String, dynamic> adminData) async {
    try {
      return await _api.putData("api/admins/$id", adminData);
    } catch (e) {
      throw Exception("AdminService: Impossible de mettre à jour l'administrateur: $e");
    }
  }

  Future<void> deleteAdmin(String id) async {
    try {
      await _api.deleteData("api/admins/$id");
    } catch (e) {
      throw Exception("AdminService: Impossible de supprimer l'administrateur: $e");
    }
  }
}
