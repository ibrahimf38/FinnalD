import 'api_service.dart';

class CommandeService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getCommandes() async {
    try {
      final data = await _api.getData("api/commandes");

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('commandes')) {
        return data['commandes'];
      } else if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("CommandeService: Impossible de charger les commandes: $e");
    }
  }

  Future<dynamic> getCommandeById(String id) async {
    try {
      return await _api.getData("api/commandes/$id");
    } catch (e) {
      throw Exception("CommandeService: Impossible de charger la commande $id: $e");
    }
  }

  Future<dynamic> addCommande(Map<String, dynamic> commandeData) async {
    try {
      return await _api.postData("api/commandes", commandeData);
    } catch (e) {
      throw Exception("CommandeService: Impossible d'ajouter la commande: $e");
    }
  }

  Future<dynamic> updateCommande(String id, Map<String, dynamic> commandeData) async {
    try {
      return await _api.putData("api/commandes/$id", commandeData);
    } catch (e) {
      throw Exception("CommandeService: Impossible de mettre à jour la commande: $e");
    }
  }

  Future<void> deleteCommande(String id) async {
    try {
      await _api.deleteData("api/commandes/$id");
    } catch (e) {
      throw Exception("CommandeService: Impossible de supprimer la commande: $e");
    }
  }
}
