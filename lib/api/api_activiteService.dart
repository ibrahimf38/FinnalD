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

  /*Future<dynamic> addActivite(Map<String, dynamic> activiteData) async {
    try {
      return await _api.postData("api/activites", activiteData);
    } catch (e) {
      throw Exception("ActiviteService: Impossible d'ajouter l'activité: $e");
    }
  }*/

/*
  Future<dynamic> addActivite(Map<String, dynamic> activiteData) async {
    try {
      // Récupérer l'URL de base depuis ApiService
      final fullUrl =   await _api.postData("api/activites", activiteData);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      // Ajouter tous les champs sauf les images
      activiteData.forEach((key, value) {
        if (key != 'image' && key != 'imageBytes' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Ajouter le fichier image
      if (activiteData['image'] != null || activiteData['imageBytes'] != null) {
        List<int> imageBytes;

        if (activiteData['imageBytes'] != null) {
          // Pour le web
          imageBytes = activiteData['imageBytes'];
        } else {
          // Pour mobile
          File image = activiteData['image'];
          imageBytes = await image.readAsBytes();
        }

        var multipartFile = http.MultipartFile.fromBytes(
          'image', // Nom du champ attendu par votre backend
          imageBytes,
          filename: 'activity_image.png',
        );
        request.files.add(multipartFile);
      }


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
*/

  Future<dynamic> addActivite(Map<String, dynamic> activiteData) async {
    try {
      final fullUrl = "${_api.baseUrl}/api/activites";
      print('📡 Création de la requête POST multipart vers $fullUrl');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      // Ajouter les champs de texte
      activiteData.forEach((key, value) {
        if (key != 'image' && key != 'imageBytes' && value != null) {
          request.fields[key] = value.toString();
          print('📦 Ajout du champ : $key = $value');
        }
      });

      // Ajouter le fichier image avec le type de média explicite
      if (activiteData['image'] != null) {
        // Pour les plateformes mobiles
        File imageFile = activiteData['image'];
        String filename = path.basename(imageFile.path);

        // Déterminer le type MIME de l'image
        final mediaType = MediaType('image', path.extension(filename).substring(1));

        var multipartFile = await http.MultipartFile.fromPath(
          'image', // Nom du champ attendu par votre backend (req.file)
          imageFile.path,
          filename: filename,
          contentType: mediaType, // ✅ L'ajout crucial
        );
        request.files.add(multipartFile);
        print('🖼️ Ajout du fichier image depuis le chemin: ${imageFile.path} avec type: $mediaType');
      } else if (activiteData['imageBytes'] != null) {
        // Pour le web
        List<int> imageBytes = activiteData['imageBytes'];
        var multipartFile = http.MultipartFile.fromBytes(
          'image', // Nom du champ attendu par votre backend (req.file)
          imageBytes,
          filename: 'image_from_web.png', // Nom de fichier par défaut
          contentType: MediaType('image', 'png'), // ✅ L'ajout crucial
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
