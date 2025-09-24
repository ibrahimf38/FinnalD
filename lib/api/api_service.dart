import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  late String baseUrl;

 /* ApiService() {
    // Configuration automatique selon la plateforme
    if (Platform.isAndroid) {
      baseUrl = "http://10.0.2.2:8000"; // Émulateur Android
    } else if (Platform.isIOS) {
      baseUrl = "http://127.0.0.1:8000"; // Émulateur iOS
    } else {
      baseUrl = "http://localhost:8000"; // Desktop/Web
    }
    print('🔧 ApiService initialisé avec baseUrl: $baseUrl');
  }*/

  ApiService() {
    // Configuration automatique selon la plateforme
    if (Platform.isAndroid) {
      baseUrl = "http://192.168.188.98:8000"; // Émulateur Android
    } else if (Platform.isIOS) {
      baseUrl = "http://192.168.188.98:8000"; // Émulateur iOS
    } else {
      baseUrl = "http://localhost:8000"; // Desktop/Web
    }
    print('🔧 ApiService initialisé avec baseUrl: $baseUrl');
  }

  // GET avec logs détaillés
  Future<dynamic> getData(String endpoint) async {
    final fullUrl = "$baseUrl/$endpoint";
    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
      ).timeout(Duration(seconds: 10)); // Timeout de 10 secondes


      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return decodedData;
      } else {
        throw Exception("Erreur GET: ${response.statusCode} - ${response.body}");
      }
    } on SocketException catch (e) {

      throw Exception("Pas de connexion réseau: $e");
    } on FormatException catch (e) {
      throw Exception("Réponse JSON invalide: $e");
    } catch (e) {
      throw Exception("Erreur de connexion: $e");
    }
  }

  // POST avec logs détaillés
  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = "$baseUrl/$endpoint";

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = json.decode(response.body);
        return decodedData;
      } else {
        throw Exception("Erreur POST: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion POST: $e");
    }
  }

  // PUT avec logs
  Future<dynamic> putData(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = "$baseUrl/$endpoint";

    try {
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Erreur PUT: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion PUT: $e");
    }
  }

  // DELETE avec logs
  Future<void> deleteData(String endpoint) async {
    final fullUrl = "$baseUrl/$endpoint";

    try {
      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
      ).timeout(Duration(seconds: 10));

      print('📡 Réponse DELETE: Status ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception("Erreur DELETE: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion DELETE: $e");
    }
  }
}