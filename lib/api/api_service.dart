/*import 'dart:convert';
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
      baseUrl = "http://192.168.1.123:8000"; // Émulateur Android
    } else if (Platform.isIOS) {
      baseUrl = "http://192.168.1.123:8000"; // Émulateur iOS
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
}*/


/*
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  late String baseUrl;
  // Stocke le jeton pour l'utiliser dans toutes les requêtes authentifiées
  String? authToken;

  ApiService() {
    // Configuration automatique selon la plateforme
    // ATTENTION: Assurez-vous que cette IP est celle de votre machine sur le réseau local
    if (Platform.isAndroid) {
      baseUrl = "http://192.168.188.98:8000";
    } else if (Platform.isIOS) {
      baseUrl = "http://192.168.188.98:8000";
    } else {
      baseUrl = "http://localhost:8000";
    }
    print('🔧 ApiService initialisé avec baseUrl: $baseUrl');
  }

  // Permet à l'application de définir le token après l'authentification de l'utilisateur
  void setAuthToken(String token) {
    authToken = token;
  }

  // Crée les headers, y compris le jeton d'authentification si disponible
  Map<String, String> get _authHeaders => {
    "Content-Type": "application/json",
    if (authToken != null) "Authorization": "Bearer $authToken",
  };


  // GET avec logs détaillés
  Future<dynamic> getData(String endpoint) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ GET: $fullUrl');

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: _authHeaders,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print('✅ Réponse GET réussie. Statut: 200');
        return decodedData;
      } else {
        throw Exception("Erreur GET: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion GET: $e");
    }
  }

  // POST avec logs (utilise désormais _authHeaders)
  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ POST: $fullUrl');

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: _authHeaders,
        body: json.encode(data),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = json.decode(response.body);
        print('✅ Réponse POST réussie. Statut: ${response.statusCode}');
        return decodedData;
      } else {
        String errorBody = response.body.isNotEmpty
            ? json.decode(response.body)['error'] ?? json.decode(response.body)['message'] ?? response.body
            : 'Erreur inconnue du serveur';
        throw Exception("Erreur POST: ${response.statusCode} - $errorBody");
      }
    } catch (e) {
      throw Exception("Erreur de connexion POST: $e");
    }
  }

  // PUT avec logs (utilise désormais _authHeaders)
  Future<dynamic> putData(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ PUT: $fullUrl');

    try {
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: _authHeaders,
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

  // DELETE avec logs (utilise désormais _authHeaders)
  Future<void> deleteData(String endpoint) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ DELETE: $fullUrl');

    try {
      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: _authHeaders,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Suppression réussie. Statut: ${response.statusCode}');
        return;
      } else {
        throw Exception("Erreur DELETE: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion DELETE: $e");
    }
  }
}*/



import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  late String baseUrl;
  String? authToken;

  ApiService() {
    if (Platform.isAndroid) {
      baseUrl = "http://192.168.188.98:8000";
    } else if (Platform.isIOS) {
      baseUrl = "http://192.168.188.98:8000";
    } else {
      baseUrl = "http://localhost:8000";
    }
    print('🔧 ApiService initialisé avec baseUrl: $baseUrl');
  }

  void setAuthToken(String token) {
    authToken = token;
  }

  Map<String, String> get _authHeaders => {
    "Content-Type": "application/json",
    if (authToken != null) "Authorization": "Bearer $authToken",
  };

  Future<dynamic> getData(String endpoint) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ GET: $fullUrl');

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: _authHeaders,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print('✅ Réponse GET réussie. Statut: 200');
        return decodedData;
      } else {
        throw Exception("Erreur GET: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion GET: $e");
    }
  }

  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ POST: $fullUrl');

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: _authHeaders,
        body: json.encode(data),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = json.decode(response.body);
        print('✅ Réponse POST réussie. Statut: ${response.statusCode}');
        return decodedData;
      } else {
        String errorBody = response.body.isNotEmpty
            ? json.decode(response.body)['error'] ?? json.decode(response.body)['message'] ?? response.body
            : 'Erreur inconnue du serveur';
        throw Exception("Erreur POST: ${response.statusCode} - $errorBody");
      }
    } catch (e) {
      throw Exception("Erreur de connexion POST: $e");
    }
  }

  Future<dynamic> putData(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ PUT: $fullUrl');

    try {
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: _authHeaders,
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

  Future<void> deleteData(String endpoint) async {
    final fullUrl = "$baseUrl/$endpoint";
    print('➡️ DELETE: $fullUrl');

    try {
      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: _authHeaders,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Suppression réussie. Statut: ${response.statusCode}');
        return;
      } else {
        throw Exception("Erreur DELETE: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion DELETE: $e");
    }
  }
}