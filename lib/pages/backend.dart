import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendTestPage extends StatefulWidget {
  @override
  _BackendTestPageState createState() => _BackendTestPageState();
}

class _BackendTestPageState extends State<BackendTestPage> {
  String message = 'Chargement...';

  @override
  void initState() {
    super.initState();
    fetchMessage();
  }

  Future<void> fetchMessage() async {
    final url = Uri.parse('http://localhost:3000'); // 10.0.2.2 pour l'émulateur Android
    // final url = Uri.parse('http://10.0.2.2:3000/api/hello'); // <- Vers un endpoint JSON
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        message = data['message'];
      });
    } else {
      setState(() {
        message = 'Erreur serveur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Center(child: Text(message)),
    );
  }
}
