import 'api_service.dart';

class RestaurantService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getRestaurants() async {
    try {
      final data = await _api.getData("api/restaurants");


      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('restaurants')) {
        return data['restaurants'];
      } else if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("RestaurantService: Impossible de charger les restaurants: $e");
    }
  }

  Future<dynamic> addRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      return await _api.postData("api/restaurants", restaurantData);
    } catch (e) {
      throw Exception("RestaurantService: Impossible d'ajouter le restaurant: $e");
    }
  }

  Future<dynamic> updateRestaurant(String id, Map<String, dynamic> restaurantData) async {
    try {
      return await _api.putData("api/restaurants/$id", restaurantData);
    } catch (e) {
      throw Exception("RestaurantService: Impossible de mettre à jour le restaurant: $e");
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      await _api.deleteData("api/restaurants/$id");
    } catch (e) {
      throw Exception("RestaurantService: Impossible de supprimer le restaurant: $e");
    }
  }
}