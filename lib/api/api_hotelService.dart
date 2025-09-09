import 'api_service.dart';

class HotelService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getHotels() async {
    try {
      final data = await _api.getData("api/hotels");


      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('hotels')) {
        return data['hotels'];
      } else if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("HotelService: Impossible de charger les hôtels: $e");
    }
  }

  Future<dynamic> addHotel(Map<String, dynamic> hotelData) async {
    try {
      return await _api.postData("api/hotels", hotelData);
    } catch (e) {
      throw Exception("HotelService: Impossible d'ajouter l'hôtel: $e");
    }
  }

  Future<dynamic> updateHotel(String id, Map<String, dynamic> hotelData) async {
    try {
      return await _api.putData("api/hotels/$id", hotelData);
    } catch (e) {
      throw Exception("HotelService: Impossible de mettre à jour l'hôtel: $e");
    }
  }

  Future<void> deleteHotel(String id) async {
    try {
      await _api.deleteData("api/hotels/$id");
    } catch (e) {
      throw Exception("HotelService: Impossible de supprimer l'hôtel: $e");
    }
  }
}