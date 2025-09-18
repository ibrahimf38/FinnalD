/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_activiteService.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _scrollController = ScrollController();
  final ActiviteService _activiteService = ActiviteService(); // Service pour API

  final TextEditingController nomController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _selectedImage;
  String? _selectedPayment;
  String? _selectedCategory;
  Uint8List? _webImage;
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Randonnée',
    'Concert',
    'Conference',
    'Visite historique',
    'Festival',
    'Excursion',
    'Artisanat local',
    'Gastronomie',
    'Autre',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _webImage = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image sélectionnée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateStep1() {
    bool isValid = true;
    List<String> errors = [];

    if (nomController.text.trim().isEmpty) {
      errors.add('Nom requis');
      isValid = false;
    }
    if (locationController.text.trim().isEmpty) {
      errors.add('Localisation requise');
      isValid = false;
    }
    if (_selectedCategory == null) {
      errors.add('Catégorie requise');
      isValid = false;
    }
    if (_selectedImage == null && _webImage == null) {
      errors.add('Image requise');
      isValid = false;
    }

    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreurs: ${errors.join(', ')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return isValid;
  }

  bool _validateStep2() {
    bool isValid = true;
    List<String> errors = [];

    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description requise');
      isValid = false;
    }
    if (phoneController.text.trim().isEmpty) {
      errors.add('Téléphone requis');
      isValid = false;
    }

    // Validation email si renseigné
    if (emailController.text.trim().isNotEmpty &&
        !emailController.text.contains('@')) {
      errors.add('Email invalide');
      isValid = false;
    }

    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreurs: ${errors.join(', ')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return isValid;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedImage == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Préparer les données d'image
      String? imageData;
      if (_webImage != null) {
        imageData = 'data:image/png;base64,${base64Encode(_webImage!)}';
      } else if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        imageData = 'data:image/png;base64,${base64Encode(bytes)}';
      }

      final activiteData = {
        'nom': nomController.text.trim(),
        'location': locationController.text.trim(),
        'latitude': latitudeController.text.trim().isNotEmpty
            ? double.tryParse(latitudeController.text.trim())
            : null,
        'longitude': longitudeController.text.trim().isNotEmpty
            ? double.tryParse(longitudeController.text.trim())
            : null,
        'phone': phoneController.text.trim(),
        'prix': prixController.text.trim().isNotEmpty
            ? double.tryParse(prixController.text.trim())
            : null,
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'description': descriptionController.text.trim(),
        'payment': _selectedPayment!,
        'category': _selectedCategory!,
        'image': imageData!,
      };

      // Appel API réel (remplacez la simulation)
      await _activiteService.addActivite(activiteData);

      if (!mounted) return;

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité ajoutée avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Retourner à la page précédente avec les données
      Navigator.pop(context, activiteData);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: ${_getErrorMessage(e.toString())}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Connection')) {
      return 'Problème de connexion réseau';
    } else if (error.contains('500')) {
      return 'Erreur serveur, veuillez réessayer';
    } else if (error.contains('422')) {
      return 'Données invalides';
    } else {
      return 'Une erreur inattendue s\'est produite';
    }
  }

  Widget buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mode de paiement",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ChoiceChip(
              label: const Text("Orange Money"),
              selected: _selectedPayment == 'orange',
              onSelected: (selected) => setState(() {
                _selectedPayment = selected ? 'orange' : null;
              }),
              selectedColor: Colors.orange.withOpacity(0.2),
              avatar: const Icon(Icons.phone_android, color: Colors.orange),
            ),
            ChoiceChip(
              label: const Text("Moov Money"),
              selected: _selectedPayment == 'moov',
              onSelected: (selected) => setState(() {
                _selectedPayment = selected ? 'moov' : null;
              }),
              selectedColor: Colors.blue.withOpacity(0.2),
              avatar: const Icon(Icons.phone_android, color: Colors.blue),
            ),
            ChoiceChip(
              label: const Text("Carte bancaire"),
              selected: _selectedPayment == 'carte',
              onSelected: (selected) => setState(() {
                _selectedPayment = selected ? 'carte' : null;
              }),
              selectedColor: Colors.green.withOpacity(0.2),
              avatar: const Icon(Icons.credit_card, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: _currentStep == index ? 32 : 12,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _currentStep >= index
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une activité"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSubmitting) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Étape 1: Informations de base
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informations générales",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'activité *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: 'Localisation *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: latitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Latitude',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.location_city),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: longitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Longitude',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.location_city),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Catégorie *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          validator: (value) => value == null
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Photo de l'activité *",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                              color: Colors.grey.shade50,
                            ),
                            child: _selectedImage != null || _webImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.memory(_webImage!, fit: BoxFit.cover)
                                  : Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Ajouter une photo",
                                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Étape 2: Description et contacts
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description et contacts",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description *',
                            hintText: 'Décrivez l\'activité en détail...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: prixController,
                          decoration: InputDecoration(
                            labelText: 'Prix (FCFA)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email (optionnel)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Étape 3: Paiement et validation
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Finalisation",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        buildPaymentOptions(),
                        const SizedBox(height: 32),
                        if (_isSubmitting)
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Ajout en cours..."),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Valider l'activité",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!_isSubmitting)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Retour"),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    if (_currentStep < 2)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Suivant",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choisir une image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galerie photos"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Prendre une photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null || _webImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Supprimer l'image"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _webImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    prixController.dispose();
    emailController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_activiteService.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _scrollController = ScrollController();
  final ActiviteService _activiteService = ActiviteService(); // Service pour API

  final TextEditingController nomController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _selectedImage;
  String? _selectedPayment;
  String? _selectedCategory;
  Uint8List? _webImage;
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Randonnée',
    'Concert',
    'Conference',
    'Visite historique',
    'Festival',
    'Excursion',
    'Artisanat local',
    'Gastronomie',
    'Autre',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _webImage = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image sélectionnée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateStep1() {
    bool isValid = true;
    List<String> errors = [];

    if (nomController.text.trim().isEmpty) {
      errors.add('Nom requis');
      isValid = false;
    }
    if (locationController.text.trim().isEmpty) {
      errors.add('Localisation requise');
      isValid = false;
    }
    if (_selectedCategory == null) {
      errors.add('Catégorie requise');
      isValid = false;
    }
    if (_selectedImage == null && _webImage == null) {
      errors.add('Image requise');
      isValid = false;
    }

    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreurs: ${errors.join(', ')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return isValid;
  }

  bool _validateStep2() {
    bool isValid = true;
    List<String> errors = [];

    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description requise');
      isValid = false;
    }
    if (phoneController.text.trim().isEmpty) {
      errors.add('Téléphone requis');
      isValid = false;
    }

    // Validation email si renseigné
    if (emailController.text.trim().isNotEmpty &&
        !emailController.text.contains('@')) {
      errors.add('Email invalide');
      isValid = false;
    }

    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreurs: ${errors.join(', ')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return isValid;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedImage == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Préparer les données pour FormData (compatible avec votre backend)
      final activiteData = {
        'nom': nomController.text.trim(),
        'location': locationController.text.trim(),
        'latitude': latitudeController.text.trim().isNotEmpty
            ? double.tryParse(latitudeController.text.trim())
            : null,
        'longitude': longitudeController.text.trim().isNotEmpty
            ? double.tryParse(longitudeController.text.trim())
            : null,
        'phone': phoneController.text.trim(),
        'prix': prixController.text.trim().isNotEmpty
            ? double.tryParse(prixController.text.trim())
            : null,
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'description': descriptionController.text.trim(),
        'payment': _selectedPayment!,
        'category': _selectedCategory!,
        // Passer les données d'image pour FormData (compatible avec multer)
        'imageFile': kIsWeb ? null : _selectedImage, // Fichier pour mobile
        'imageBytes': kIsWeb ? _webImage : null,     // Bytes pour web
      };

      // Appel API avec FormData
      await _activiteService.addActivite(activiteData);

      if (!mounted) return;

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité ajoutée avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Retourner à la page précédente avec les données
      Navigator.pop(context, activiteData);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: ${_getErrorMessage(e.toString())}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Connection')) {
      return 'Problème de connexion réseau';
    } else if (error.contains('500')) {
      return 'Erreur serveur, veuillez réessayer';
    } else if (error.contains('422')) {
      return 'Données invalides';
    } else {
      return 'Une erreur inattendue s\'est produite';
    }
  }

  Widget buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mode de paiement",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ChoiceChip(
              label: const Text("Orange Money"),
              selected: _selectedPayment == 'orange',
              onSelected: (selected) => setState(() {
                _selectedPayment = selected ? 'orange' : null;
              }),
              selectedColor: Colors.orange.withOpacity(0.2),
              avatar: const Icon(Icons.phone_android, color: Colors.orange),
            ),
            ChoiceChip(
              label: const Text("Moov Money"),
              selected: _selectedPayment == 'moov',
              onSelected: (selected) => setState(() {
                _selectedPayment = selected ? 'moov' : null;
              }),
              selectedColor: Colors.blue.withOpacity(0.2),
              avatar: const Icon(Icons.phone_android, color: Colors.blue),
            ),
            ChoiceChip(
              label: const Text("Carte bancaire"),
              selected: _selectedPayment == 'carte',
              onSelected: (selected) => setState(() {
                _selectedPayment = selected ? 'carte' : null;
              }),
              selectedColor: Colors.green.withOpacity(0.2),
              avatar: const Icon(Icons.credit_card, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: _currentStep == index ? 32 : 12,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _currentStep >= index
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une activité"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSubmitting) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Étape 1: Informations de base
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informations générales",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'activité *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: 'Localisation *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: latitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Latitude',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.location_city),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: longitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Longitude',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.location_city),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Catégorie *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          validator: (value) => value == null
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Photo de l'activité *",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                              color: Colors.grey.shade50,
                            ),
                            child: _selectedImage != null || _webImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.memory(_webImage!, fit: BoxFit.cover)
                                  : Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Ajouter une photo",
                                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Étape 2: Description et contacts
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description et contacts",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description *',
                            hintText: 'Décrivez l\'activité en détail...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.trim().isEmpty ?? true
                              ? 'Ce champ est requis'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: prixController,
                          decoration: InputDecoration(
                            labelText: 'Prix (FCFA)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email (optionnel)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Étape 3: Paiement et validation
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Finalisation",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        buildPaymentOptions(),
                        const SizedBox(height: 32),
                        if (_isSubmitting)
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Ajout en cours..."),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Valider l'activité",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!_isSubmitting)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Retour"),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    if (_currentStep < 2)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Suivant",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choisir une image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galerie photos"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Prendre une photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null || _webImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Supprimer l'image"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _webImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    prixController.dispose();
    emailController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}