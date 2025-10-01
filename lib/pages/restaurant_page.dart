import 'dart:io';
import 'dart:convert';
import 'package:MaliDiscover/api/api_restaurantService.dart';
import 'package:flutter/material.dart';
import 'package:MaliDiscover/pages/commande.dart';
import 'package:MaliDiscover/pages/formulairerestaurant.dart';
import 'package:MaliDiscover/pages/profil_page.dart'; // Import ajouté
import 'package:shared_preferences/shared_preferences.dart'; // Import ajouté

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Map<String, dynamic>> restaurants = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Tous, 1: Populaires, 2: Proches
  bool _isUserLoggedIn = false; // Nouvelle variable pour suivre l'état de connexion

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _checkUserLoginStatus(); // Vérifier le statut de connexion
  }

  // Vérifier si l'utilisateur est connecté
  Future<void> _checkUserLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isUserLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  // Fonction utilitaire pour obtenir une valeur sûre
  String _getSafeString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  double _getSafeDouble(Map<String, dynamic> data, String key, [double defaultValue = 0.0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  int _getSafeInt(Map<String, dynamic> data, String key, [int defaultValue = 0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() => _isLoading = true);

      final apiRestaurants = await _restaurantService.getRestaurants();

      setState(() {
        // Filtrer les données pour s'assurer qu'elles sont de type Map<String, dynamic>
        restaurants = apiRestaurants.where((restaurant) => restaurant is Map<String, dynamic>).map<Map<String, dynamic>>((restaurant) {
          return {
            'id_restaurant': _getSafeString(restaurant, 'id_restaurant', _getSafeString(restaurant, 'id', 'unknown')),
            'id_gestionnaire': _getSafeString(restaurant, 'id_gestionnaire', 'unknown'),
            'nom': _getSafeString(restaurant, 'nom', 'Nom non disponible'),
            'adresse': _getSafeString(restaurant, 'adresse', 'Adresse non disponible'),
            'description': _getSafeString(restaurant, 'description', 'Description non disponible'),
            'email': _getSafeString(restaurant, 'email', 'Non disponible'),
            'localisation': _getSafeString(restaurant, 'localisation', 'Adresse non disponible'),
            'ownerFirstName': _getSafeString(restaurant, 'ownerFirstName', 'N/A'),
            'ownerLastName': _getSafeString(restaurant, 'ownerLastName', 'N/A'),
            'phone': _getSafeString(restaurant, 'phone', 'N/A'),
            'plat': _getSafeString(restaurant, 'plat', 'Standard'),
            'price': _getSafeString(restaurant, 'price', '0'),
            'quantity': _getSafeInt(restaurant, 'quantity', 1),
            'payment': _getSafeString(restaurant, 'payment', 'N/A'),
            'image': _getSafeString(restaurant, 'image', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'),
          };
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Pas de connexion backend. Données de test affichées.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }

      setState(() {
        restaurants = [
          {
            'id': '1',
            'id_restaurant': '1',
            'id_gestionnaire': '1',
            'nom': 'Restaurant Maria',
            'adresse': 'Bamako',
            'description': 'Restaurant traditionnel',
            'email': 'maria@restaurant.com',
            'localisation': 'Bamako, Mali',
            'ownerFirstName': 'Maria',
            'ownerLastName': 'Diakité',
            'phone': '+223 12345678',
            'plat': 'Plat du jour',
            'price': '2500',
            'quantity': 1,
            'payment': 'Cash',
            'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
          },
          {
            'id': '2',
            'id_restaurant': '1',
            'id_gestionnaire': '1',
            'nom': 'Restaurant Maria',
            'adresse': 'Bamako',
            'description': 'Restaurant traditionnel',
            'email': 'maria@restaurant.com',
            'localisation': 'Bamako, Mali',
            'ownerFirstName': 'Maria',
            'ownerLastName': 'Diakité',
            'phone': '+223 72345678',
            'plat': 'Plat du jour',
            'price': '2500',
            'quantity': 1,
            'payment': 'Cash',
            'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
          },
        ];
        _isLoading = false;
      });
    }
  }

  // Fonction pour gérer le clic sur un restaurant
  void _handleRestaurantTap(Map<String, dynamic> restaurant) async {
    // Vérifier si l'utilisateur est connecté
    if (!_isUserLoggedIn) {
      // Rediriger vers la page de profil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez vous connecter pour commander'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MyProfilePage()),
      );
    } else {
      // Récupérer les données de l'utilisateur connecté
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('name') ?? '';
      final userPrenom = prefs.getString('prenom') ?? '';
      final userPhone = prefs.getString('phoneNumber') ?? '';
      final userEmail = prefs.getString('email') ?? '';

      final fullName = '$userPrenom $userName'.trim();

      // Aller à la page de commande avec les données de l'utilisateur
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantOrderPage(
            restaurant: restaurant,
            userName: fullName,
            userPhone: userPhone,
            userEmail: userEmail,
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredRestaurants {
    List<Map<String, dynamic>> result = restaurants.where((resto) {
      final nameMatch = (resto['nom'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final locationMatch = (resto['localisation'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || locationMatch;
    }).toList();

    if (_selectedFilter == 1) {
      result.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else if (_selectedFilter == 2) {
      result.sort((a, b) => a['nom'].length.compareTo(b['nom'].length));
    }

    return result;
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadRestaurants();
    await _checkUserLoginStatus(); // Re-vérifier le statut de connexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurants"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filtrer par', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      RadioListTile<int>(
                        value: 0,
                        groupValue: _selectedFilter,
                        onChanged: (v) {
                          setState(() => _selectedFilter = v!);
                          Navigator.pop(context);
                        },
                        title: const Text('Tous les restaurants'),
                      ),
                      RadioListTile<int>(
                        value: 1,
                        groupValue: _selectedFilter,
                        onChanged: (v) {
                          setState(() => _selectedFilter = v!);
                          Navigator.pop(context);
                        },
                        title: const Text('Les plus populaires'),
                      ),
                      RadioListTile<int>(
                        value: 2,
                        groupValue: _selectedFilter,
                        onChanged: (v) {
                          setState(() => _selectedFilter = v!);
                          Navigator.pop(context);
                        },
                        title: const Text('Les plus proches'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRestaurants.isEmpty
                  ? const Center(child: Text('Aucun restaurant trouvé'))
                  : ListView.builder(
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return _buildRestaurantCard(restaurant);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    // Vérifier si la carte du restaurant est null avant de la construire
    if (restaurant == null) {
      return const SizedBox.shrink(); // ou un widget d'erreur/placeholder
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _handleRestaurantTap(restaurant);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Image.network(
                  // Utiliser l'opérateur de nullité ?? pour fournir une image par défaut
                  restaurant['image'] ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          // Utiliser l'opérateur de nullité ?? pour gérer les valeurs nulles
                          restaurant['nom'] ?? 'Nom inconnu',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text('${restaurant['quantity'] ?? 'N/A'}'),
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.amber),
                        avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          restaurant['localisation'] ?? 'Localisation non disponible',
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    restaurant['description'] ?? 'Description non disponible',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plat: ${restaurant['plat'] ?? 'Standard'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${restaurant['price'] ?? '0'} FCFA',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}