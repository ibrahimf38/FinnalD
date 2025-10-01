import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

 // int? get length => null;

  /// Récupère la liste de tous les utilisateurs pour le Dashboard Admin.
  Future<List<dynamic>> getUsers() async {
    try {
      // ⚠️ Assurez-vous que cet endpoint est protégé et réservé aux admins
      final data = await _api.getData("api/users");

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('users')) {
        return data['users']; // Ex: Si le backend retourne {users: [...]}
      } else if (data is Map && data.containsKey('data')) {
        return data['data']; // Ex: Si le backend retourne {data: [...]}
      } else {
        return [];
      }
    } catch (e) {
      // Pour une meilleure gestion des logs dans un contexte réel
      print("UserService: Erreur lors du chargement des utilisateurs: $e");
      throw Exception("Impossible de charger la liste des utilisateurs.");
    }
  }

  /// Supprime un utilisateur spécifique par son ID.
  Future<void> deleteUser(String id) async {
    try {
      // L'ID est souvent l'ID Firestore/MongoDB/SQL (et non l'UID de Firebase Auth seul)
      await _api.deleteData("api/users/$id");
    } catch (e) {
      print("UserService: Erreur lors de la suppression de l'utilisateur $id: $e");
      throw Exception("Impossible de supprimer l'utilisateur.");
    }
  }

// Vous pouvez aussi ajouter update pour les rôles admin, etc.
}