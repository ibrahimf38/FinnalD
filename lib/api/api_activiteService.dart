
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

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
      final fullUrl = "${_api.baseUrl}/api/activites";
      print('📡 Création de la requête POST multipart vers $fullUrl');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      // CORRECTION: Ajouter les champs de texte en EXCLUANT les clés d'image
      activiteData.forEach((key, value) {
        if (key != 'image' && key != 'imageBytes' && value != null) {
          request.fields[key] = value.toString();
          print('📦 Ajout du champ : $key = $value');
        }
      });

      // Ajouter le fichier image (Mobile/Desktop)
      if (activiteData['image'] != null && activiteData['image'] is File) {
        File imageFile = activiteData['image'];
        String filename = path.basename(imageFile.path);

        final mediaType = MediaType('image', path.extension(filename).substring(1));

        var multipartFile = await http.MultipartFile.fromPath(
          'image', // Nom du champ attendu par votre backend
          imageFile.path,
          filename: filename,
          contentType: mediaType,
        );
        request.files.add(multipartFile);
        print('🖼️ Ajout du fichier image depuis le chemin: ${imageFile.path} avec type: $mediaType');
      }
      // Ajouter les bytes de l'image (Web)
      else if (activiteData['imageBytes'] != null && activiteData['imageBytes'] is List<int>) {
        List<int> imageBytes = activiteData['imageBytes'];

        var multipartFile = http.MultipartFile.fromBytes(
          'image', // Nom du champ attendu par votre backend
          imageBytes,
          filename: 'image_from_web.png',
          contentType: MediaType('image', 'png'),
        );
        request.files.add(multipartFile);
        print('🖼️ Ajout des bytes de l\'image pour le web avec type: image/png');
      }


      // Envoyer la requête
      print('⏳ Envoi de la requête en cours...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('✅ Requête réussie ! Statut: 201');
        return json.decode(response.body);
      } else {
        print('❌ Échec de la requête ! Statut: ${response.statusCode}, Corps: ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur lors de la requête multipart : $e');
      throw Exception('Erreur lors de l\'envoi avec FormData: $e');
    }
  }

  // Assurez-vous d'avoir la méthode updateActivite (elle est partiellement visible dans votre code)
  Future<dynamic> updateActivite(String id, Map<String, dynamic> activiteData) async {
    try {
      return await _api.putData("api/activites/$id", activiteData);
    } catch (e) {
      throw Exception("ActiviteService: Impossible de mettre à jour l'activité: $e");
    }
  }
  // Dans api_activiteService.dart
  Future<dynamic> reserverActivite(Map<String, dynamic> reservationData) async {
    try {
      final fullUrl = "${_api.baseUrl}/api/reservations/activites";
      print('📡 Réservation d\'activité vers: $fullUrl');

      final response = await _api.postData("api/reservations/activites", reservationData);

      print('✅ Réservation d\'activité réussie: $response');
      return response;
    } catch (e) {
      print('❌ Erreur lors de la réservation d\'activité: $e');
      throw Exception("ActiviteService: Impossible de réserver l'activité: $e");
    }
  }

// ➡️ CORRECTION POUR LA SUPPRESSION
  Future<void> deleteActivite(String id) async {
    try {
      // L'endpoint DELETE doit correspondre à l'ID de l'activité
      await _api.deleteData("api/activites/$id");
    } catch (e) {
      throw Exception("ActiviteService: Impossible de supprimer l'activité: $e");
    }
  }


}