/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/api_authService.dart';
import 'dashbord.dart';

class AdminLoginPage extends StatefulWidget {
  final String? errorMessage;

  const AdminLoginPage({this.errorMessage, super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ Utilisez votre HotelService
  final LoginService _hotelService = LoginService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion Admin')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.errorMessage != null)
                Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Admin'),
                validator: (value) => value!.contains('@') ? null : 'Email invalide',
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) => value!.length >= 6 ? null : '6 caractères minimum',
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _loginAdmin,
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Nouvelle méthode utilisant votre HotelService
  Future<void> _loginAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ Préparez les données de connexion
      final loginData = {
        'email': _emailController.text.trim(),
        // Ajoutez le mot de passe si votre endpoint en a besoin
        'password': _passwordController.text,
      };

      // ✅ Appelez votre endpoint via HotelService
      final response = await _hotelService.login(loginData);

      print('✅ Réponse de connexion: $response');

      // ✅ Vérifiez la réponse et récupérez le customToken
      if (response != null && response['customToken'] != null) {
        final customToken = response['customToken'];

        // ✅ Connectez-vous avec Firebase Auth
        final userCredential = await FirebaseAuth.instance.signInWithCustomToken(customToken);

        print('✅ Utilisateur connecté: ${userCredential.user?.email}');

        // ✅ Affichez un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connexion réussie ! Bienvenue ${response['user']?['email'] ?? 'Admin'}'),
              backgroundColor: Colors.green,
            ),
          );

          // ✅ Navigation vers le dashboard admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        }

      } else {
        throw Exception('Token de connexion manquant dans la réponse');
      }

    } catch (e) {
      print('❌ Erreur de connexion: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ Méthode pour formater les messages d'erreur
  String _getErrorMessage(String error) {
    if (error.contains('Pas de connexion réseau')) {
      return 'Vérifiez votre connexion internet';
    } else if (error.contains('Erreur POST: 404')) {
      return 'Service non disponible';
    } else if (error.contains('Erreur POST: 422')) {
      return 'Email requis ou invalide';
    } else if (error.contains('Erreur POST: 500')) {
      return 'Utilisateur non trouvé';
    } else if (error.contains('invalid-custom-token')) {
      return 'Token de connexion invalide';
    } else {
      return 'Erreur de connexion: ${error.replaceAll('Exception: ', '')}';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}*/


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../api/api_authService.dart';
import 'dashbord.dart';
import 'hotel_page.dart';

class AdminLoginPage extends StatefulWidget {
  final String? errorMessage;

  const AdminLoginPage({this.errorMessage, super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nomController = TextEditingController();
  final _numeroController = TextEditingController();
  final _adresseController = TextEditingController();

  bool _isLoading = false;
  bool _showSignUpForm = false;
  late AnimationController _controller;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _numeroController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  final LoginService _loginService = LoginService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(_showSignUpForm ? 'Créer un compte' : 'Connexion'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animation Lottie en arrière-plan
          Positioned.fill(
            child: Lottie.asset(
              'assets/lotties/animation.json',
              controller: _controller,
              fit: BoxFit.cover,
            ),
          ),

          // Overlay de dégradé
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.3, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.errorMessage != null)
                        Text(
                          widget.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 20),

                      if (_showSignUpForm) ...[
                        // FORMULAIRE D'INSCRIPTION
                        TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _numeroController,
                          decoration: const InputDecoration(
                            labelText: 'Numéro de téléphone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.isEmpty ? 'Numéro requis' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _adresseController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty ? 'Adresse requise' : null,
                        ),
                        const SizedBox(height: 15),
                      ],

                      // CHAMPS COMMUNS (EMAIL ET MOT DE PASSE)
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.contains('@') ? null : 'Email invalide',
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => value!.length >= 6 ? null : '6 caractères minimum',
                      ),
                      const SizedBox(height: 20),

                      // BOUTON PRINCIPAL
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _showSignUpForm ? _signUpUser : _loginAdmin,
                        child: Text(_showSignUpForm ? 'Créer le compte' : 'Se connecter'),
                      ),

                      const SizedBox(height: 15),

                      // BOUTON POUR BASCULER ENTRE LOGIN ET SIGNUP
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showSignUpForm = !_showSignUpForm;
                          });
                        },
                        child: Text(
                          _showSignUpForm
                              ? 'Déjà un compte ? Se connecter'
                              : 'OU Créer un compte',
                          style: TextStyle(
                            color: Colors.blue.withOpacity(0.8),
                            fontSize: screenWidth * 0.035,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _loginAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final loginData = {
        'email': _emailController.text.trim(),
        'motDePasse': _passwordController.text,
      };

      // ✅ Ajout de la ligne de débogage pour voir les données envoyées
      print('DEBUG: Données de connexion envoyées: $loginData');

      final response = await _loginService.login(loginData);

      print('✅ Réponse de connexion: $response');

      if (response != null && response['customToken'] != null) {
        final customToken = response['customToken'];

        await FirebaseAuth.instance.signInWithCustomToken(customToken);

        // ✅ Vérifier le rôle de l'utilisateur
        final userRole = response['role'] as String?;

        if (mounted) {
          if (userRole == 'ADMIN') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connexion réussie ! Redirection vers le tableau de bord.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          } else if (userRole == 'USER') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connexion réussie ! Redirection vers la page d\'accueil.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HotelPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur de rôle : Rôle d\'utilisateur inconnu.'),
                backgroundColor: Colors.red,
              ),
            );
            await FirebaseAuth.instance.signOut(); // Déconnecter l'utilisateur
          }
        }
      } else {
        throw Exception('Token de connexion manquant dans la réponse');
      }

    } catch (e) {
      print('❌ Erreur de connexion: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  Future<void> _signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final registerData = {
        'nom': _nomController.text.trim(),
        'email': _emailController.text.trim(),
        'motDePasse': _passwordController.text,
        'telephone': _numeroController.text.trim(),
        'adresse': _adresseController.text.trim(),
      };

      // ✅ Appel à la nouvelle fonction registerUser dans l'API
      final response = await _loginService.registerUser(registerData);

      print('✅ Réponse d\'inscription: $response');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Compte créé avec succès ! Vous pouvez maintenant vous connecter.'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Revenir à la connexion
        setState(() => _showSignUpForm = false);
      }

    } catch (e) {
      print('❌ Erreur d\'inscription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: ${_getErrorMessage(e.toString())}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('network-error') || error.contains('socket')) {
      return 'Vérifiez votre connexion internet';
    } else if (error.contains('invalid-email')) {
      return 'Email invalide';
    } else if (error.contains('user-not-found')) {
      return 'Utilisateur non trouvé';
    } else if (error.contains('wrong-password')) {
      return 'Mot de passe incorrect';
    } else if (error.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé';
    } else if (error.contains('weak-password')) {
      return 'Mot de passe trop faible';
    } else {
      return 'Erreur: ${error.replaceAll('Exception: ', '').replaceAll('FirebaseAuthException: ', '')}';
    }
  }
}
