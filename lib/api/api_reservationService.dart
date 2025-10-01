/*import 'api_service.dart';

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
}*/



// /*import 'api_service.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
//
// class ReservationService {
//   final ApiService _api = ApiService();
//   final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth
//
//   /// Récupère le token Firebase de l'utilisateur connecté
//   Future<String?> _getFirebaseToken() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final token = await user.getIdToken();
//         print('🔐 Token Firebase récupéré avec succès');
//         return token;
//       }
//       print('⚠️ Aucun utilisateur Firebase connecté');
//       return null;
//     } catch (e) {
//       print('❌ Erreur lors de la récupération du token Firebase: $e');
//       return null;
//     }
//   }
//
//   Future<List<dynamic>> getReservations() async {
//     try {
//       final data = await _api.getData("api/reservations");
//
//       if (data is List) {
//         return data;
//       } else if (data is Map && data.containsKey('reservations')) {
//         return data['reservations'];
//       } else if (data is Map && data.containsKey('data')) {
//         return data['data'];
//       } else {
//         return [];
//       }
//     } catch (e) {
//       throw Exception("ReservationService: Impossible de charger les réservations: $e");
//     }
//   }
//
//   Future<dynamic> getReservationById(String id) async {
//     try {
//       return await _api.getData("api/reservations/$id");
//     } catch (e) {
//       throw Exception("ReservationService: Impossible de charger la réservation $id: $e");
//     }
//   }
//
//   Future<dynamic> addReservation(Map<String, dynamic> reservationData) async {
//     try {
//       // Récupérer le token Firebase
//       final token = await _getFirebaseToken();
//
//       if (token != null) {
//         // Définir le token dans ApiService pour qu'il soit inclus dans les headers
//         _api.setAuthToken(token);
//         print('✅ Token Firebase intégré dans la requête de réservation');
//       } else {
//         print('⚠️ Réservation sans token Firebase (utilisateur non connecté)');
//       }
//
//       return await _api.postData("api/reservations", reservationData);
//     } catch (e) {
//       throw Exception("ReservationService: Impossible d'ajouter la réservation: $e");
//     }
//   }
//
//   Future<dynamic> updateReservation(String id, Map<String, dynamic> reservationData) async {
//     try {
//       // Récupérer le token Firebase pour la mise à jour
//       final token = await _getFirebaseToken();
//       if (token != null) {
//         _api.setAuthToken(token);
//       }
//
//       return await _api.putData("api/reservations/$id", reservationData);
//     } catch (e) {
//       throw Exception("ReservationService: Impossible de mettre à jour la réservation: $e");
//     }
//   }
//
//   Future<void> deleteReservation(String id) async {
//     try {
//       // Récupérer le token Firebase pour la suppression
//       final token = await _getFirebaseToken();
//       if (token != null) {
//         _api.setAuthToken(token);
//       }
//
//       await _api.deleteData("api/reservations/$id");
//     } catch (e) {
//       throw Exception("ReservationService: Impossible de supprimer la réservation: $e");
//     }
//   }
// }*/




import 'api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationService {
  final ApiService _api = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getFirebaseToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        print('🔐 Token Firebase récupéré avec succès');
        return token;
      }
      print('⚠️ Aucun utilisateur Firebase connecté');
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token Firebase: $e');
      return null;
    }
  }

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
      final token = await _getFirebaseToken();

      if (token != null) {
        _api.setAuthToken(token);
        print('✅ Token Firebase intégré dans la requête de réservation');
      } else {
        print('⚠️ Réservation sans token Firebase (utilisateur non connecté)');
      }

      return await _api.postData("api/reservations", reservationData);
    } catch (e) {
      throw Exception("ReservationService: Impossible d'ajouter la réservation: $e");
    }
  }



  Future<dynamic> updateReservation(String id, Map<String, dynamic> reservationData) async {
    try {
      final token = await _getFirebaseToken();
      if (token != null) {
        _api.setAuthToken(token);
      }

      return await _api.putData("api/reservations/$id", reservationData);
    } catch (e) {
      throw Exception("ReservationService: Impossible de mettre à jour la réservation: $e");
    }
  }

  Future<void> deleteReservation(String id) async {
    try {
      final token = await _getFirebaseToken();
      if (token != null) {
        _api.setAuthToken(token);
      }

      await _api.deleteData("api/reservations/$id");
    } catch (e) {
      throw Exception("ReservationService: Impossible de supprimer la réservation: $e");
    }
  }
}