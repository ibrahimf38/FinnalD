import 'api_service.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

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

  /*Future<dynamic> addHotel(Map<String, dynamic> hotelData) async {
    try {
      return await _api.postData("api/hotels", hotelData);
    } catch (e) {
      throw Exception("HotelService: Impossible d'ajouter l'hôtel: $e");
    }
  }*/

  Future<dynamic> addHotel(Map<String, dynamic> hotelData) async {
    try {
      final fullUrl = "${_api.baseUrl}/api/hotels";
      print('📡 Création de la requête POST multipart vers $fullUrl');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      // Ajouter les champs de texte
      hotelData.forEach((key, value) {
        if (key != 'image' && key != 'imageBytes' && value != null) {
          request.fields[key] = value.toString();
          print('📦 Ajout du champ : $key = $value');
        }
      });

      // Ajouter le fichier image avec le type de média explicite
      if (hotelData['image'] != null) {
        // Pour les plateformes mobiles
        File imageFile = hotelData['image'];
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
      } else if (hotelData['imageBytes'] != null) {
        // Pour le web
        List<int> imageBytes = hotelData['imageBytes'];
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