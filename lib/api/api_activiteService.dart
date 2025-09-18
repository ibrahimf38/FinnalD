import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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

  /*Future<dynamic> addActivite(Map<String, dynamic> activiteData) async {
    try {
      return await _api.postData("api/activites", activiteData);
    } catch (e) {
      throw Exception("ActiviteService: Impossible d'ajouter l'activité: $e");
    }
  }*/

  Future<dynamic> addActivite(Map<String, dynamic> activiteData) async {
    try {
      // Récupérer l'URL de base depuis ApiService
      String baseUrl = _api.baseUrl; // Assurez-vous que votre ApiService expose baseUrl

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/activites'),
      );

      // Ajouter tous les champs sauf les images
      activiteData.forEach((key, value) {
        if (key != 'imageFile' && key != 'imageBytes' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Ajouter le fichier image
      if (activiteData['imageFile'] != null || activiteData['imageBytes'] != null) {
        List<int> imageBytes;

        if (activiteData['imageBytes'] != null) {
          // Pour le web
          imageBytes = activiteData['imageBytes'];
        } else {
          // Pour mobile
          File imageFile = activiteData['imageFile'];
          imageBytes = await imageFile.readAsBytes();
        }

        var multipartFile = http.MultipartFile.fromBytes(
          'image', // Nom du champ attendu par votre backend
          imageBytes,
          filename: 'activity_image.png',
        );
        request.files.add(multipartFile);
      }

      /*// Ajouter les headers d'authentification si nécessaire
      Map<String, String> headers = await _api.getHeaders(); // Assurez-vous que cette méthode existe
      request.headers.addAll(headers);*/

      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi avec FormData: $e');
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
