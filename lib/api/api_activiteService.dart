import 'api_service.dart';

class ActiviteService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getActivites() async {
    try {
      final data = await _api.getData("api/activites");

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('activites')) {
        return data['activites'];
      } else if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("ActiviteService: Impossible de charger les activités: $e");
    }
  }

  Future<dynamic> addActivite(Map<String, dynamic> activiteData) async {
    try {
      return await _api.postData("api/activites", activiteData);
    } catch (e) {
      throw Exception("ActiviteService: Impossible d'ajouter l'activité: $e");
    }
  }

  Future<dynamic> updateActivite(String id, Map<String, dynamic> activiteData) async {
    try {
      return await _api.putData("api/activites/$id", activiteData);
    } catch (e) {
      throw Exception("ActiviteService: Impossible de mettre à jour l'activité: $e");
    }
  }

  Future<void> deleteActivite(String id) async {
    try {
      await _api.deleteData("api/activites/$id");
    } catch (e) {
      throw Exception("ActiviteService: Impossible de supprimer l'activité: $e");
    }
  }
}
