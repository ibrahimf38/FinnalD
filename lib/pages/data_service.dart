import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
class DatabaseService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addHotel(Map<String, dynamic> hotelData) async {
    try {
      await _firestore.collection('hotels').add(hotelData);
      notifyListeners();
    } catch (e) {
      throw 'Erreur lors de l\'ajout de l\'hôtel: $e';
    }
  }

  Future<void> addRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      await _firestore.collection('restaurants').add(restaurantData);
      notifyListeners();
    } catch (e) {
      throw 'Erreur lors de l\'ajout du restaurant: $e';
    }
  }

  Future<void> addActivity(Map<String, dynamic> activityData) async {
    try {
      await _firestore.collection('activities').add(activityData);
      notifyListeners();
    } catch (e) {
      throw 'Erreur lors de l\'ajout de l\'activité: $e';
    }
  }

  Future<Map<String, int>> getDashboardStats() async {
  try {
    final hotelsSnapshot = await _firestore.collection('hotels').count().get();
    final restaurantsSnapshot = await _firestore.collection('restaurants').count().get();
    final activitiesSnapshot = await _firestore.collection('activities').count().get();
    final usersSnapshot = await _firestore.collection('users').count().get();

    return {
      'hotels': hotelsSnapshot.count!,
      'restaurants': restaurantsSnapshot.count!,
      'activities': activitiesSnapshot.count!,
      'users': usersSnapshot.count!,
    };
  } catch (e) {
    throw 'Erreur lors de la récupération des statistiques: $e';
  }
}

  Future<String> uploadImage(String path, Uint8List? fileBytes, File? file) async {
    try {
      final ref = _storage.ref().child(path);
      UploadTask uploadTask;

      if (kIsWeb && fileBytes != null) {
        uploadTask = ref.putData(fileBytes);
      } else if (file != null) {
        uploadTask = ref.putFile(file);
      } else {
        throw 'Aucun fichier valide fourni';
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Erreur lors de l\'upload de l\'image: $e';
    }
  }

  Stream<QuerySnapshot> getHotels() => _firestore.collection('hotels').snapshots();
  Stream<QuerySnapshot> getRestaurants() => _firestore.collection('restaurants').snapshots();
  Stream<QuerySnapshot> getActivities() => _firestore.collection('activities').snapshots();
}