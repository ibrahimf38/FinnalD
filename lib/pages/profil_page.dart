/*import 'package:MaliDiscover/pages/acceil_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // Données du profil
  String name = "Nom";
  String prenom = "Prenom";
  String phoneNumber = "";
  String email = "Nomprenom@gmail.com";
  String profilePictureUrl = "https://www.gravatar.com/avatar/default?s=200";
  bool isLoggedIn = false;
  bool _isEditing = false;

  // Contrôleurs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "Nom";
      prenom = prefs.getString('prenom') ?? "Prenom";
      phoneNumber = prefs.getString('phoneNumber') ?? "";
      email = prefs.getString('email') ?? "Nomprenom@gmail.com";
      profilePictureUrl = prefs.getString('profilePictureUrl') ?? 
          "https://www.gravatar.com/avatar/default?s=200";
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      _nomController.text = name;
      _prenomController.text = prenom;
      _phoneController.text = phoneNumber;
      _emailController.text = email;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('prenom', prenom);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('email', email);
    await prefs.setString('profilePictureUrl', profilePictureUrl);
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        setState(() {
          name = googleUser.displayName?.split(" ").first ?? "";
          prenom = googleUser.displayName?.split(" ").last ?? "";
          email = googleUser.email ?? "";
          profilePictureUrl = googleUser.photoUrl ?? 
              "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=retro&s=200";
          isLoggedIn = true;
          
          _nomController.text = name;
          _prenomController.text = prenom;
          _emailController.text = email;
        });

        await _saveProfileData();
        _showSnackBar('Connecté en tant que ${googleUser.displayName}');
      }
    } catch (e) {
      _showSnackBar('Échec de la connexion avec Google: $e');
    }
  }

  void _saveProfile() {
    setState(() {
      name = _nomController.text;
      prenom = _prenomController.text;
      phoneNumber = _phoneController.text;
      email = _emailController.text;
      isLoggedIn = true;
      _isEditing = false;
    });

    _saveProfileData();
    _showSnackBar('Profil mis à jour!');
  }

  Future<void> _logout() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() {
        name = "";
        prenom = "";
        phoneNumber = "";
        email = "@gmail.com";
        profilePictureUrl = "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=retro&s=200";
        isLoggedIn = false;
        _isEditing = false;
        
        _nomController.clear();
        _prenomController.clear();
        _phoneController.clear();
        _emailController.clear();
        _passwordController.clear();
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AcceilPage()),
        (route) => false,
      );

      _showSnackBar('Déconnexion réussie');
    } catch (e) {
      _showSnackBar('Erreur lors de la déconnexion: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mon Profil', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section Photo de Profil
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      profilePictureUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                if (_isEditing)
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.camera_alt, size: 20),
                    onPressed: () {
                      // Ajouter la logique pour changer la photo
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Nom et Prénom
            Text(
              "$prenom $name",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            
            const SizedBox(height: 5),
            
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Bouton d'édition
            if (!_isEditing && isLoggedIn)
              ElevatedButton(
                onPressed: () => setState(() => _isEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  'Modifier le Profil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            
            if (_isEditing || !isLoggedIn) ...[
              const SizedBox(height: 30),
              
              // Formulaire
              _buildFormField(
                controller: _nomController,
                label: 'Nom',
                icon: Icons.person,
                enabled: _isEditing || !isLoggedIn,
              ),
              
              const SizedBox(height: 15),
              
              _buildFormField(
                controller: _prenomController,
                label: 'Prénom',
                icon: Icons.person_outline,
                enabled: _isEditing || !isLoggedIn,
              ),
              
              const SizedBox(height: 15),
              
              _buildFormField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                enabled: _isEditing || !isLoggedIn,
              ),
              
              const SizedBox(height: 15),
              
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                enabled: _isEditing || !isLoggedIn,
              ),
              
              if (_isEditing || !isLoggedIn) ...[
                const SizedBox(height: 15),
                
                _buildFormField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                  enabled: _isEditing || !isLoggedIn,
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_isEditing)
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        _loadProfileData(); // Recharger les données originales
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  
                  ElevatedButton(
                    onPressed: _isEditing || !isLoggedIn ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: _isEditing ? 25 : 30, 
                        vertical: 12
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Enregistrer' : 
                      isLoggedIn ? 'Connecté' : 'Créer un compte',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
            
            if (!isLoggedIn) ...[
              const SizedBox(height: 30),
              
              // Séparateur
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OU',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Connexion Google
              OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                ),
                label: Text(
                  'Continuer avec Google',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
    );
  }
}*/




import 'package:MaliDiscover/pages/acceil_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_profilService.dart'; // Import du service Profil

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final ProfilService _profilService = ProfilService(); // Instance du service

  // Données et État
  String userId = "";
  String name = "Nom";
  String prenom = "Prenom";
  String phoneNumber = "";
  String email = "Nomprenom@gmail.com";
  String profilePictureUrl = "https://www.gravatar.com/avatar/default?s=200";
  bool isLoggedIn = false;
  bool _isEditing = false;
  bool _isLoginMode = true; // true pour Connexion, false pour Inscription

  // Contrôleurs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =========================================================================
  // LOGIQUE AUTHENTIFICATION
  // =========================================================================

  void _showSnackbar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Veuillez remplir tous les champs.");
      return;
    }

    try {
      final response = await _profilService.login(email, password);

      // VÉRIFIEZ VOTRE BACKEND: Assurez-vous que les clés correspondent
      if (response != null && response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();

        // Sauvegarde de l'état de connexion et des données
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', response['userId'] ?? 'guest');
        await prefs.setString('name', response['nom'] ?? 'Nom');
        await prefs.setString('prenom', response['prenom'] ?? 'Prenom');
        await prefs.setString('email', email);

        setState(() {
          isLoggedIn = true;
          name = response['nom'] ?? 'Nom';
          prenom = response['prenom'] ?? 'Prenom';
          this.email = email;
          // Initialiser les contrôleurs pour le mode édition
          _nomController.text = name;
          _prenomController.text = prenom;
          _emailController.text = this.email;
        });

        // Navigation vers l'accueil
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AcceilPage()),
              (Route<dynamic> route) => false,
        );
        _showSnackbar("Connexion réussie !", color: Colors.green);
      } else {
        _showSnackbar("Connexion échouée. Veuillez vérifier vos identifiants.");
      }
    } catch (e) {
      _showSnackbar("Erreur de connexion: ${e.toString().split(':').last.trim()}");
    }
  }

  Future<void> _handleSignup() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackbar("Veuillez remplir tous les champs obligatoires.");
      return;
    }
    if (password != confirmPassword) {
      _showSnackbar("Les mots de passe ne correspondent pas.");
      return;
    }

    try {
      await _profilService.signup(nom, prenom, email, password, phone);

      _showSnackbar("Inscription réussie ! Vous pouvez maintenant vous connecter.", color: Colors.green);
      setState(() {
        _isLoginMode = true; // Passer au mode connexion
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      _showSnackbar("Erreur d'inscription: ${e.toString().split(':').last.trim()}");
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();

    setState(() {
      isLoggedIn = false;
      _isEditing = false;
      _isLoginMode = true;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      name = "Nom";
      prenom = "Prenom";
      phoneNumber = "";
      email = "Nomprenom@gmail.com";
      profilePictureUrl = "https://www.gravatar.com/avatar/default?s=200";
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AcceilPage()),
          (Route<dynamic> route) => false,
    );
    _showSnackbar("Déconnexion réussie.", color: Colors.grey);
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      name = prefs.getString('name') ?? "Nom";
      prenom = prefs.getString('prenom') ?? "Prenom";
      phoneNumber = prefs.getString('phoneNumber') ?? "";
      email = prefs.getString('email') ?? "Nomprenom@gmail.com";
      profilePictureUrl = prefs.getString('profilePictureUrl') ?? "https://www.gravatar.com/avatar/default?s=200";

      _nomController.text = name;
      _prenomController.text = prenom;
      _phoneController.text = phoneNumber;
      _emailController.text = email;
    });
  }

  // Fonction existante pour sauvegarder
  Future<void> _saveProfileData() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    try {
      final updatedData = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
      };

      final currentUserId = prefs.getString('userId') ?? '';

      if (currentUserId.isNotEmpty) {
        await _profilService.updateProfil(currentUserId, updatedData);

        // Sauvegarde locale après succès API
        await prefs.setString('name', _nomController.text);
        await prefs.setString('prenom', _prenomController.text);
        await prefs.setString('phoneNumber', _phoneController.text);
        await prefs.setString('email', _emailController.text);

        _showSnackbar("Profil mis à jour avec succès !", color: Colors.green);
        setState(() {
          name = _nomController.text;
          prenom = _prenomController.text;
          phoneNumber = _phoneController.text;
          email = _emailController.text;
          _isEditing = false;
        });
      } else {
        _showSnackbar("Erreur: ID utilisateur non trouvé pour la mise à jour.");
      }
    } catch (e) {
      _showSnackbar("Erreur de mise à jour: ${e.toString().split(':').last.trim()}");
    }
  }

  // Google Sign-In (À finir d'intégrer avec le backend pour l'échange de token)
  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // ... (Logique d'envoi du token au backend ici)

        final prefs = await SharedPreferences.getInstance();

        // Simuler la connexion/inscription réussie
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('name', googleUser.displayName?.split(' ').first ?? 'Google');
        await prefs.setString('prenom', googleUser.displayName?.split(' ').last ?? 'User');
        await prefs.setString('email', googleUser.email);
        await prefs.setString('profilePictureUrl', googleUser.photoUrl ?? "https://www.gravatar.com/avatar/default?s=200");

        setState(() {
          isLoggedIn = true;
          name = prefs.getString('name')!;
          prenom = prefs.getString('prenom')!;
          email = prefs.getString('email')!;
          profilePictureUrl = prefs.getString('profilePictureUrl')!;

          _nomController.text = name;
          _prenomController.text = prenom;
          _emailController.text = email;
        });

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AcceilPage()),
              (Route<dynamic> route) => false,
        );
        _showSnackbar("Connexion Google réussie !", color: Colors.green);
      }
    } catch (error) {
      _showSnackbar("Erreur de connexion Google: $error");
    }
  }


  // =========================================================================
  // UI BUILDERS
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoggedIn ? "Mon Profil" : (_isLoginMode ? "Connexion" : "Inscription")),
        backgroundColor: Colors.teal,
        actions: isLoggedIn
            ? [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _saveProfileData,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: isLoggedIn ? _buildProfileView() : _buildAuthForm(),
      ),
    );
  }

  Widget _buildProfileView() {
    // Vue du profil (inchangée)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profilePictureUrl),
                backgroundColor: Colors.teal[100],
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        _showSnackbar("Fonctionnalité 'Changer photo' à implémenter.", color: Colors.blue);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildFormField(
          controller: _nomController,
          label: "Nom",
          icon: Icons.person,
          enabled: _isEditing,
        ),
        const SizedBox(height: 15),
        _buildFormField(
          controller: _prenomController,
          label: "Prénom",
          icon: Icons.person_outline,
          enabled: _isEditing,
        ),
        const SizedBox(height: 15),
        _buildFormField(
          controller: _phoneController,
          label: "Numéro de Téléphone",
          icon: Icons.phone,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 15),
        _buildFormField(
          controller: _emailController,
          label: "Email",
          icon: Icons.email,
          enabled: false,
        ),
        const SizedBox(height: 30),
        if (!_isEditing)
          ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout),
            label: Text("Déconnexion"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
      ],
    );
  }


  Widget _buildAuthForm() {
    // Formulaire de connexion/inscription (NOUVEAU)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isLoginMode ? "Connectez-vous à votre compte" : "Créez votre compte",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),

        // Champs d'inscription (uniquement en mode inscription)
        if (!_isLoginMode) ...[
          _buildFormField(
            controller: _nomController,
            label: "Nom",
            icon: Icons.person,
          ),
          const SizedBox(height: 15),
          _buildFormField(
            controller: _prenomController,
            label: "Prénom",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 15),
          _buildFormField(
            controller: _phoneController,
            label: "Numéro de Téléphone (Optionnel)",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
        ],

        // Champs Email & Mot de passe
        _buildFormField(
          controller: _emailController,
          label: "Email",
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        _buildFormField(
          controller: _passwordController,
          label: "Mot de passe",
          icon: Icons.lock,
          obscureText: true,
        ),

        // Confirmation du mot de passe (uniquement en mode inscription)
        if (!_isLoginMode) ...[
          const SizedBox(height: 15),
          _buildFormField(
            controller: _confirmPasswordController,
            label: "Confirmer le mot de passe",
            icon: Icons.lock_outline,
            obscureText: true,
          ),
        ],

        const SizedBox(height: 30),

        // Bouton principal (Connexion ou Inscription)
        ElevatedButton(
          onPressed: _isLoginMode ? _handleLogin : _handleSignup,
          child: Text(_isLoginMode ? 'Connexion' : 'Inscription', style: TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
          ),
        ),

        const SizedBox(height: 20),

        // Séparateur
        Row(
          children: <Widget>[
            Expanded(child: Divider(color: Colors.grey[400])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text("OU", style: TextStyle(color: Colors.grey[600])),
            ),
            Expanded(child: Divider(color: Colors.grey[400])),
          ],
        ),

        const SizedBox(height: 20),

        // Bouton Google Sign-In
        OutlinedButton.icon(
          onPressed: _handleGoogleSignIn,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Image.asset(
            'assets/images/google_logo.png', // Assurez-vous d'avoir cette image dans vos assets
            width: 24,
            height: 24,
          ),
          label: Text(
            'Continuer avec Google',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ),

        const SizedBox(height: 20),

        // Lien pour changer de mode (Connexion <-> Inscription)
        TextButton(
          onPressed: () {
            setState(() {
              _isLoginMode = !_isLoginMode;
              // Effacer les champs en changeant de mode
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
            });
          },
          child: Text(
            _isLoginMode
                ? "Pas encore de compte ? S'inscrire"
                : "Déjà un compte ? Se connecter",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Fonction de construction de champ (existante)
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[400]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[400]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal, width: 2)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
    );
  }
}