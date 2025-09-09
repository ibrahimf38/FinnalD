import 'api_service.dart';

class ReservationService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getReservations() async {
    try {
      final data = await _api.getData("api/reservations");

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('reservations')) {
        return data['reservations'];
      } else if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("ReservationService: Impossible de charger les réservations: $e");
    }
  }

  Future<dynamic> getReservationById(String id) async {
    try {
      return await _api.getData("api/reservations/$id");
    } catch (e) {
      throw Exception("ReservationService: Impossible de charger la réservation $id: $e");
    }
  }

  Future<dynamic> addReservation(Map<String, dynamic> reservationData) async {
    try {
      return await _api.postData("api/reservations", reservationData);
    } catch (e) {
      throw Exception("ReservationService: Impossible d'ajouter la réservation: $e");
    }
  }


  Future<dynamic> updateReservation(String id, Map<String, dynamic> reservationData) async {
    try {
      return await _api.putData("api/reservations/$id", reservationData);
    } catch (e) {
      throw Exception("ReservationService: Impossible de mettre à jour la réservation: $e");
    }
  }

  Future<void> deleteReservation(String id) async {
    try {
      await _api.deleteData("api/reservations/$id");
    } catch (e) {
      throw Exception("ReservationService: Impossible de supprimer la réservation: $e");
    }
  }
}
