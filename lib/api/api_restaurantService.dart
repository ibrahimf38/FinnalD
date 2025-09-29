
import 'api_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
      final fullUrl = "${_api.baseUrl}/api/restaurants";
      print('📡 Création de la requête POST multipart vers $fullUrl');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      // CORRECTION: Ajouter les champs de texte en EXCLUANT les clés d'image
      restaurantData.forEach((key, value) {
        if (key != 'image' && key != 'imageBytes' && value != null) {
          request.fields[key] = value.toString();
          print('📦 Ajout du champ : $key = $value');
        }
      });

      // Ajouter le fichier image (Mobile/Desktop)
      if (restaurantData['image'] != null && restaurantData['image'] is File) {
        File imageFile = restaurantData['image'];
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
      else if (restaurantData['imageBytes'] != null && restaurantData['imageBytes'] is List<int>) {
        List<int> imageBytes = restaurantData['imageBytes'];

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