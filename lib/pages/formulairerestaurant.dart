/*
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_restaurantService.dart';

class AddRestaurantPage extends StatefulWidget {
  const AddRestaurantPage({super.key});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RestaurantService _restaurantService = RestaurantService();

  // SUPPRIMÉ: List inutile de controllers génériques
  // CORRIGÉ: Utilisation directe des controllers spécifiques
  final nomController = TextEditingController();
  final localisationController = TextEditingController();
  final ownerFirstNameController = TextEditingController();
  final ownerLastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final platController = TextEditingController();

  // SUPPRIMÉ: Controllers inutiles (paymentController, imageController)

  // CORRIGÉ: Création des FocusNodes uniquement pour les champs utilisés
  final _nomFocusNode = FocusNode();
  final _localisationFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _platFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _ownerFirstNameFocusNode = FocusNode();
  final _ownerLastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  File? _selectedImage;
  Uint8List? _webImage;
  String? _selectedPayment;
  bool _isSubmitting = false;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _paymentOptions = [
    {'value': 'orange', 'label': 'Orange Money', 'icon': 'assets/images/orange.png'},
    {'value': 'moov', 'label': 'Moov Money', 'icon': 'assets/images/moov.png'},
    {'value': 'carte', 'label': 'Carte Visa', 'icon': 'assets/images/banque.png'},
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80, // AJOUTÉ: Compression pour optimiser
      );

      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(picked.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection: ${e.toString()}', backgroundColor: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return; // AJOUTÉ: Vérification mounted

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: const Duration(seconds: 3), // CORRIGÉ: const ajouté
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // CORRIGÉ: Validation améliorée des étapes
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
      // Validation étape 1: infos de base + image
        if (!_formKey.currentState!.validate()) {
          _showSnackBar('Veuillez remplir tous les champs requis', backgroundColor: Colors.orange);
          return false;
        }
        if (_selectedImage == null && _webImage == null) {
          _showSnackBar('Veuillez sélectionner une image', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      case 1:
      // Validation étape 2: description et menu
        if (descriptionController.text.trim().isEmpty) {
          _showSnackBar('La description est requise', backgroundColor: Colors.orange);
          return false;
        }
        if (platController.text.trim().isEmpty) {
          _showSnackBar('Le nom du plat est requis', backgroundColor: Colors.orange);
          return false;
        }
        if (priceController.text.trim().isEmpty) {
          _showSnackBar('Le prix est requis', backgroundColor: Colors.orange);
          return false;
        }
        // AJOUTÉ: Validation du prix numérique
        if (double.tryParse(priceController.text) == null) {
          _showSnackBar('Veuillez entrer un prix valide', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      case 2:
      // Validation étape 3: propriétaire et paiement
        if (ownerFirstNameController.text.trim().isEmpty ||
            ownerLastNameController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty ||
            emailController.text.trim().isEmpty) {
          _showSnackBar('Veuillez remplir toutes les informations du propriétaire', backgroundColor: Colors.orange);
          return false;
        }
        if (_selectedPayment == null) {
          _showSnackBar('Veuillez sélectionner un mode de paiement', backgroundColor: Colors.orange);
          return false;
        }
        // AJOUTÉ: Validation email améliorée
        final email = emailController.text.trim();
        if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email)) {
          _showSnackBar('Veuillez entrer un email valide', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _submit() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isSubmitting = true);

    try {
      String? imageData;
      if (_webImage != null) {
        imageData = 'data:image/png;base64,${base64Encode(_webImage!)}';
      } else if (_selectedImage != null) {
        // CORRIGÉ: Pour mobile, convertir en base64 aussi
        final bytes = await _selectedImage!.readAsBytes();
        imageData = 'data:image/png;base64,${base64Encode(bytes)}';
      }

      final restaurantData = {
        'nom': nomController.text.trim(),
        'localisation': localisationController.text.trim(),
        'ownerFirstName': ownerFirstNameController.text.trim(),
        'ownerLastName': ownerLastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim().isNotEmpty == true
            ? emailController.text.trim()
            : '',
        'description': descriptionController.text.trim(),
        'plat': platController.text.trim(),
        'price': priceController.text.trim(),
        'quantity': '0',
        'payment': _selectedPayment!,
        'image': imageData!,
        'date_creation': DateTime.now().toIso8601String(),
      };

      // CORRIGÉ: Gestion des erreurs améliorée
      final result = await _restaurantService.addRestaurant(restaurantData);

      if (!mounted) return;

      _showSnackBar(
        '🎉 Restaurant ajouté avec succès!',
        backgroundColor: Colors.green,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pop(result ?? restaurantData); // CORRIGÉ: retourner le résultat API
      }
    } catch (e) {
      if (!mounted) return;

      final errorString = (e.toString() ?? 'unknown').toLowerCase();
      String errorMessage;

      if (errorString.contains('socketexception') || errorString.contains('connexion')) {
        errorMessage = '🔌 Problème de connexion au serveur';
      } else if (errorString.contains('timeoutexception') || errorString.contains('timeout')) {
        errorMessage = '⏰ Délai d\'attente dépassé';
      } else if (errorString.contains('formatexception')) {
        errorMessage = '📝 Erreur de format des données';
      } else if (errorString.contains('401')) {
        errorMessage = '🔐 Erreur d\'authentification';
      } else if (errorString.contains('403')) {
        errorMessage = '🚫 Accès non autorisé';
      } else if (errorString.contains('500')) {
        errorMessage = '⚠️ Erreur du serveur';
      } else {
        errorMessage = '❌ Erreur: $errorString';
      }

      _showSnackBar(errorMessage, backgroundColor: Colors.red);
      _showRetryDialog();
    }
    finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // AJOUTÉ: Dialog de retry en cas d'erreur
  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de soumission'),
        content: const Text('Voulez-vous réessayer ou sauvegarder localement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submit(); // Retry
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // AJOUTÉ: alignement
      children: [
        const Text("Photo du restaurant", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector( // AJOUTÉ: Tap pour ouvrir sélecteur
          onTap: () => _showImageSourceDialog(),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
                  : _webImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_webImage!, fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'Ajouter une photo\n(Tap pour sélectionner)',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galerie"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Caméra"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // AJOUTÉ: Dialog pour choisir source image
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mode de paiement", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // CORRIGÉ: Gestion d'erreur pour les assets
        ..._paymentOptions.map((option) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: RadioListTile<String>(
            value: option['value'],
            groupValue: _selectedPayment,
            onChanged: (v) => setState(() => _selectedPayment = v),
            title: Text(option['label']),
            secondary: _buildPaymentIcon(option['icon']),
            activeColor: Colors.blue,
          ),
        )).toList(),
      ],
    );
  }

  // AJOUTÉ: Widget sécurisé pour les icônes de paiement
  Widget _buildPaymentIcon(String assetPath) {
    return Container(
      width: 45,
      height: 45,
      child: Image.asset(
        assetPath,
        width: 45,
        height: 45,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.payment, size: 45, color: Colors.grey);
        },
      ),
    );
  }

  // AJOUTÉ: Validation du téléphone
  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Ajouter un Restaurant"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack( // AJOUTÉ: Stack pour loading overlay
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _isSubmitting ? null : () { // CORRIGÉ: Désactiver si submitting
              if (_validateCurrentStep()) {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _submit();
                }
              }
            },
            onStepCancel: _isSubmitting ? null : () { // CORRIGÉ: Désactiver si submitting
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.of(context).pop();
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    if (_currentStep != 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : details.onStepCancel,
                          child: const Text('Retour'),
                        ),
                      ),
                    if (_currentStep != 0) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : details.onStepContinue,
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(_currentStep == 2 ? 'Soumettre' : 'Continuer'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Informations de base'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nomController,
                        focusNode: _nomFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Nom du Restaurant',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                        onFieldSubmitted: (_) => _localisationFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: localisationController,
                        focusNode: _localisationFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Localisation',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Ex: Lomé, Togo',
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildImagePicker(),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Détails du restaurant'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      focusNode: _descriptionFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Décrivez votre restaurant...',
                      ),
                      maxLines: 3,
                      validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      onFieldSubmitted: (_) => _platFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: platController,
                      focusNode: _platFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nom du plat principal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                        hintText: 'Ex: Riz aux légumes',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      onFieldSubmitted: (_) => _priceFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: priceController,
                      focusNode: _priceFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Prix (FCFA)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Ex: 2500',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (double.tryParse(v!) == null) return 'Entrez un prix valide';
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Propriétaire & Paiement'),
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ownerFirstNameController,
                            focusNode: _ownerFirstNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                            onFieldSubmitted: (_) => _ownerLastNameFocusNode.requestFocus(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: ownerLastNameController,
                            focusNode: _ownerLastNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                            onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: phoneController,
                      focusNode: _phoneFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: 'Ex: +228 12 34 56 78',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (!_isValidPhone(v!)) return 'Numéro invalide';
                        return null;
                      },
                      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: 'exemple@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentOptions(),
                  ],
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
          // AJOUTÉ: Overlay de loading
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Ajout du restaurant en cours...'),
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

  @override
  void dispose() {
    // CORRIGÉ: Dispose tous les controllers
    nomController.dispose();
    localisationController.dispose();
    ownerFirstNameController.dispose();
    ownerLastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    platController.dispose();
    quantityController.dispose();

    // CORRIGÉ: Dispose tous les FocusNodes
    _nomFocusNode.dispose();
    _localisationFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _platFocusNode.dispose();
    _priceFocusNode.dispose();
    _ownerFirstNameFocusNode.dispose();
    _ownerLastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }
}*/

/*
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_restaurantService.dart';

class AddRestaurantPage extends StatefulWidget {
  const AddRestaurantPage({super.key});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RestaurantService _restaurantService = RestaurantService();

  // Controllers
  final nomController = TextEditingController();
  final localisationController = TextEditingController();
  final ownerFirstNameController = TextEditingController();
  final ownerLastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final platController = TextEditingController();

  // FocusNodes
  final _nomFocusNode = FocusNode();
  final _localisationFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _platFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _ownerFirstNameFocusNode = FocusNode();
  final _ownerLastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  File? _selectedImage;
  Uint8List? _webImage;
  String? _selectedPayment;
  bool _isSubmitting = false;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _paymentOptions = [
    {'value': 'orange', 'label': 'Orange Money', 'icon': 'assets/images/orange.png'},
    {'value': 'moov', 'label': 'Moov Money', 'icon': 'assets/images/moov.png'},
    {'value': 'carte', 'label': 'Carte Visa', 'icon': 'assets/images/banque.png'},
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(picked.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection: ${_safeErrorMessage(e)}', backgroundColor: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // FIXED: Safe error message extraction
  String _safeErrorMessage(dynamic error) {
    if (error == null) return 'Erreur inconnue';

    String errorString;
    try {
      errorString = error.toString();
      if (errorString.isEmpty) {
        errorString = 'Erreur vide';
      }
    } catch (e) {
      errorString = 'Erreur de conversion';
    }

    return errorString;
  }

  // FIXED: Safe error categorization
  String _categorizeError(dynamic error) {
    final errorString = _safeErrorMessage(error).toLowerCase();

    if (errorString.contains('socketexception') || errorString.contains('connexion')) {
      return '🔌 Problème de connexion au serveur';
    } else if (errorString.contains('timeoutexception') || errorString.contains('timeout')) {
      return '⏰ Délai d\'attente dépassé';
    } else if (errorString.contains('formatexception')) {
      return '📝 Erreur de format des données';
    } else if (errorString.contains('401')) {
      return '🔐 Erreur d\'authentification';
    } else if (errorString.contains('403')) {
      return '🚫 Accès non autorisé';
    } else if (errorString.contains('500')) {
      return '⚠️ Erreur du serveur';
    } else {
      return '❌ Erreur: $errorString';
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!_formKey.currentState!.validate()) {
          _showSnackBar('Veuillez remplir tous les champs requis', backgroundColor: Colors.orange);
          return false;
        }
        if (_selectedImage == null && _webImage == null) {
          _showSnackBar('Veuillez sélectionner une image', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      case 1:
        if (descriptionController.text.trim().isEmpty) {
          _showSnackBar('La description est requise', backgroundColor: Colors.orange);
          return false;
        }
        if (platController.text.trim().isEmpty) {
          _showSnackBar('Le nom du plat est requis', backgroundColor: Colors.orange);
          return false;
        }
        if (priceController.text.trim().isEmpty) {
          _showSnackBar('Le prix est requis', backgroundColor: Colors.orange);
          return false;
        }
        if (double.tryParse(priceController.text) == null) {
          _showSnackBar('Veuillez entrer un prix valide', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      case 2:
        if (ownerFirstNameController.text.trim().isEmpty ||
            ownerLastNameController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty ||
            emailController.text.trim().isEmpty) {
          _showSnackBar('Veuillez remplir toutes les informations du propriétaire', backgroundColor: Colors.orange);
          return false;
        }
        if (_selectedPayment == null) {
          _showSnackBar('Veuillez sélectionner un mode de paiement', backgroundColor: Colors.orange);
          return false;
        }
        final email = emailController.text.trim();
        if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          _showSnackBar('Veuillez entrer un email valide', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _submit() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isSubmitting = true);

    try {
      String? imageData;
      if (_webImage != null) {
        imageData = 'data:image/png;base64,${base64Encode(_webImage!)}';
      } else if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        imageData = 'data:image/png;base64,${base64Encode(bytes)}';
      }

      final restaurantData = {
        'nom': nomController.text.trim(),
        'localisation': localisationController.text.trim(),
        'ownerFirstName': ownerFirstNameController.text.trim(),
        'ownerLastName': ownerLastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim().isNotEmpty == true
            ? emailController.text.trim()
            : '',
        'description': descriptionController.text.trim(),
        'plat': platController.text.trim(),
        'price': priceController.text.trim(),
        'quantity': '0',
        'payment': _selectedPayment!,
        'image': imageData!,
        'date_creation': DateTime.now().toIso8601String(),
      };

      final result = await _restaurantService.addRestaurant(restaurantData);

      if (!mounted) return;

      _showSnackBar(
        '🎉 Restaurant ajouté avec succès!',
        backgroundColor: Colors.green,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pop(result ?? restaurantData);
      }
    } catch (e) {
      if (!mounted) return;

      // FIXED: Use the safe error categorization
      final errorMessage = _categorizeError(e);
      _showSnackBar(errorMessage, backgroundColor: Colors.red);
      _showRetryDialog();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de soumission'),
        content: const Text('Voulez-vous réessayer ou sauvegarder localement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submit();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photo du restaurant", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showImageSourceDialog(),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
                  : _webImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_webImage!, fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'Ajouter une photo\n(Tap pour sélectionner)',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galerie"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Caméra"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mode de paiement", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._paymentOptions.map((option) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: RadioListTile<String>(
            value: option['value'],
            groupValue: _selectedPayment,
            onChanged: (v) => setState(() => _selectedPayment = v),
            title: Text(option['label']),
            secondary: _buildPaymentIcon(option['icon']),
            activeColor: Colors.blue,
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPaymentIcon(String assetPath) {
    return SizedBox(
      width: 45,
      height: 45,
      child: Image.asset(
        assetPath,
        width: 45,
        height: 45,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.payment, size: 45, color: Colors.grey);
        },
      ),
    );
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Ajouter un Restaurant"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _isSubmitting ? null : () {
              if (_validateCurrentStep()) {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _submit();
                }
              }
            },
            onStepCancel: _isSubmitting ? null : () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.of(context).pop();
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    if (_currentStep != 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : details.onStepCancel,
                          child: const Text('Retour'),
                        ),
                      ),
                    if (_currentStep != 0) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : details.onStepContinue,
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(_currentStep == 2 ? 'Soumettre' : 'Continuer'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Informations de base'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nomController,
                        focusNode: _nomFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Nom du Restaurant',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                        onFieldSubmitted: (_) => _localisationFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: localisationController,
                        focusNode: _localisationFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Localisation',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Ex: Lomé, Togo',
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildImagePicker(),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Détails du restaurant'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      focusNode: _descriptionFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Décrivez votre restaurant...',
                      ),
                      maxLines: 3,
                      validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      onFieldSubmitted: (_) => _platFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: platController,
                      focusNode: _platFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nom du plat principal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                        hintText: 'Ex: Riz aux légumes',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      onFieldSubmitted: (_) => _priceFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: priceController,
                      focusNode: _priceFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Prix (FCFA)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Ex: 2500',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (double.tryParse(v!) == null) return 'Entrez un prix valide';
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Propriétaire & Paiement'),
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ownerFirstNameController,
                            focusNode: _ownerFirstNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                            onFieldSubmitted: (_) => _ownerLastNameFocusNode.requestFocus(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: ownerLastNameController,
                            focusNode: _ownerLastNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                            onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: phoneController,
                      focusNode: _phoneFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: 'Ex: +228 12 34 56 78',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (!_isValidPhone(v!)) return 'Numéro invalide';
                        return null;
                      },
                      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: 'exemple@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentOptions(),
                  ],
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Ajout du restaurant en cours...'),
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

  @override
  void dispose() {
    // Dispose controllers
    nomController.dispose();
    localisationController.dispose();
    ownerFirstNameController.dispose();
    ownerLastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    platController.dispose();
    quantityController.dispose();

    // Dispose FocusNodes
    _nomFocusNode.dispose();
    _localisationFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _platFocusNode.dispose();
    _priceFocusNode.dispose();
    _ownerFirstNameFocusNode.dispose();
    _ownerLastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }

}*/

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_restaurantService.dart';

class AddRestaurantPage extends StatefulWidget {
  const AddRestaurantPage({super.key});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RestaurantService _restaurantService = RestaurantService();

  // Controllers
  final nomController = TextEditingController();
  final localisationController = TextEditingController();
  final ownerFirstNameController = TextEditingController();
  final ownerLastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final platController = TextEditingController();

  // FocusNodes
  final _nomFocusNode = FocusNode();
  final _localisationFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _platFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _ownerFirstNameFocusNode = FocusNode();
  final _ownerLastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  File? _selectedImage;
  Uint8List? _webImage;
  String? _selectedPayment;
  bool _isSubmitting = false;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _paymentOptions = [
    {'value': 'orange', 'label': 'Orange Money', 'icon': 'assets/images/orange.png'},
    {'value': 'moov', 'label': 'Moov Money', 'icon': 'assets/images/moov.png'},
    {'value': 'carte', 'label': 'Carte Visa', 'icon': 'assets/images/banque.png'},
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(picked.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection de l\'image', backgroundColor: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // FIXED: Safe error message extraction
  String _safeErrorMessage(dynamic error) {
    if (error == null) return 'Erreur inconnue';

    String errorString;
    try {
      errorString = error.toString();
      if (errorString.isEmpty) {
        errorString = 'Erreur vide';
      }
    } catch (e) {
      errorString = 'Erreur de conversion';
    }

    return errorString;
  }

  // FIXED: Safe error categorization
  String _categorizeError(dynamic error) {
    final errorString = _safeErrorMessage(error);

    if (errorString.contains('socketexception') || errorString.contains('connexion')) {
      return '🔌 Problème de connexion au serveur';
    } else if (errorString.contains('timeoutexception') || errorString.contains('timeout')) {
      return '⏰ Délai d\'attente dépassé';
    } else if (errorString.contains('formatexception')) {
      return '📝 Erreur de format des données';
    } else if (errorString.contains('401')) {
      return '🔐 Erreur d\'authentification';
    } else if (errorString.contains('403')) {
      return '🚫 Accès non autorisé';
    } else if (errorString.contains('500')) {
      return '⚠️ Erreur du serveur';
    } else {
      return '❌ Erreur: $errorString';
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!_formKey.currentState!.validate()) {
          _showSnackBar('Veuillez remplir tous les champs requis', backgroundColor: Colors.orange);
          return false;
        }
        if (_selectedImage == null && _webImage == null) {
          _showSnackBar('Veuillez sélectionner une image', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      case 1:
        if (descriptionController.text.trim().isEmpty) {
          _showSnackBar('La description est requise', backgroundColor: Colors.orange);
          return false;
        }
        if (platController.text.trim().isEmpty) {
          _showSnackBar('Le nom du plat est requis', backgroundColor: Colors.orange);
          return false;
        }
        if (priceController.text.trim().isEmpty) {
          _showSnackBar('Le prix est requis', backgroundColor: Colors.orange);
          return false;
        }
        if (double.tryParse(priceController.text) == null) {
          _showSnackBar('Veuillez entrer un prix valide', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      case 2:
        if (ownerFirstNameController.text.trim().isEmpty ||
            ownerLastNameController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty ||
            emailController.text.trim().isEmpty) {
          _showSnackBar('Veuillez remplir toutes les informations du propriétaire', backgroundColor: Colors.orange);
          return false;
        }
        if (_selectedPayment == null) {
          _showSnackBar('Veuillez sélectionner un mode de paiement', backgroundColor: Colors.orange);
          return false;
        }
        final email = emailController.text.trim();
        if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          _showSnackBar('Veuillez entrer un email valide', backgroundColor: Colors.orange);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _submit() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isSubmitting = true);

    try {
      String? imageData;
      if (_webImage != null) {
        imageData = 'data:image/png;base64,${base64Encode(_webImage!)}';
      } else if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        imageData = 'data:image/png;base64,${base64Encode(bytes)}';
      }

      final restaurantData = {
        'nom': nomController.text.trim(),
        'localisation': localisationController.text.trim(),
        'ownerFirstName': ownerFirstNameController.text.trim(),
        'ownerLastName': ownerLastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim().isNotEmpty == true
            ? emailController.text.trim()
            : '',
        'description': descriptionController.text.trim(),
        'plat': platController.text.trim(),
        'price': priceController.text.trim(),
        'quantity': '0',
        'payment': _selectedPayment!,
        'image': imageData!,
        'date_creation': DateTime.now().toIso8601String(),
      };

      final result = await _restaurantService.addRestaurant(restaurantData);

      if (!mounted) return;

      _showSnackBar(
        '🎉 Restaurant ajouté avec succès!',
        backgroundColor: Colors.green,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pop(result ?? restaurantData);
      }
    } catch (e) {
      if (!mounted) return;

      // FIXED: Use the safe error categorization
      final errorMessage = _categorizeError(e);
      _showSnackBar(errorMessage, backgroundColor: Colors.red);
      _showRetryDialog();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de soumission'),
        content: const Text('Voulez-vous réessayer ou sauvegarder localement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submit();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photo du restaurant", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showImageSourceDialog(),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
                  : _webImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_webImage!, fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'Ajouter une photo\n(Tap pour sélectionner)',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galerie"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Caméra"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mode de paiement", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._paymentOptions.map((option) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: RadioListTile<String>(
            value: option['value'],
            groupValue: _selectedPayment,
            onChanged: (v) => setState(() => _selectedPayment = v),
            title: Text(option['label']),
            secondary: _buildPaymentIcon(option['icon']),
            activeColor: Colors.blue,
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPaymentIcon(String assetPath) {
    return SizedBox(
      width: 45,
      height: 45,
      child: Image.asset(
        assetPath,
        width: 45,
        height: 45,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.payment, size: 45, color: Colors.grey);
        },
      ),
    );
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Ajouter un Restaurant"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _isSubmitting ? null : () {
              if (_validateCurrentStep()) {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _submit();
                }
              }
            },
            onStepCancel: _isSubmitting ? null : () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.of(context).pop();
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    if (_currentStep != 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : details.onStepCancel,
                          child: const Text('Retour'),
                        ),
                      ),
                    if (_currentStep != 0) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : details.onStepContinue,
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(_currentStep == 2 ? 'Soumettre' : 'Continuer'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Informations de base'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nomController,
                        focusNode: _nomFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Nom du Restaurant',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                        onFieldSubmitted: (_) => _localisationFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: localisationController,
                        focusNode: _localisationFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Localisation',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Ex: Lomé, Togo',
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildImagePicker(),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Détails du restaurant'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      focusNode: _descriptionFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Décrivez votre restaurant...',
                      ),
                      maxLines: 3,
                      validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      onFieldSubmitted: (_) => _platFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: platController,
                      focusNode: _platFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nom du plat principal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                        hintText: 'Ex: Riz aux légumes',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
                      onFieldSubmitted: (_) => _priceFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: priceController,
                      focusNode: _priceFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Prix (FCFA)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Ex: 2500',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (double.tryParse(v!) == null) return 'Entrez un prix valide';
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Propriétaire & Paiement'),
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ownerFirstNameController,
                            focusNode: _ownerFirstNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                            onFieldSubmitted: (_) => _ownerLastNameFocusNode.requestFocus(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: ownerLastNameController,
                            focusNode: _ownerLastNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                            onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: phoneController,
                      focusNode: _phoneFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: 'Ex: +228 12 34 56 78',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (!_isValidPhone(v!)) return 'Numéro invalide';
                        return null;
                      },
                      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: 'exemple@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.trim().isEmpty == true) return 'Ce champ est requis';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentOptions(),
                  ],
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Ajout du restaurant en cours...'),
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

  @override
  void dispose() {
    // Dispose controllers
    nomController.dispose();
    localisationController.dispose();
    ownerFirstNameController.dispose();
    ownerLastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    platController.dispose();
    quantityController.dispose();

    // Dispose FocusNodes
    _nomFocusNode.dispose();
    _localisationFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _platFocusNode.dispose();
    _priceFocusNode.dispose();
    _ownerFirstNameFocusNode.dispose();
    _ownerLastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }
}