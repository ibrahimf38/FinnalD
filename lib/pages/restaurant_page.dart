import 'dart:io';
import 'dart:convert';
import 'package:MaliDiscover/api/api_restaurantService.dart';
import 'package:flutter/material.dart';
import 'package:MaliDiscover/pages/commande.dart';
import 'package:MaliDiscover/pages/formulairerestaurant.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
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


  // Méthode pour charger les hôtels depuis l'API
  /*Future<void> _loadRestaurants() async {
    try {
      setState(() => _isLoading = true);

      final apiRestaurants = await _restaurantService.getRestaurants();

      setState(() {
        // Convertir les données API en objets Restaurant
        restaurants = apiRestaurants.map<restaurant>((data) {
          if (data == null || data is! Map<String, dynamic>) {
            // fallback si les données sont invalides
            return restaurant(
              id_restaurant: 'unknown',
              id_gestionnaire: 'unknown',
              nom: 'Restaurant inconnu',
              adresse: 'Adresse non disponible',
              description: 'Description non disponible',
              email: 'Non disponible',
              localisation: 'Adresse non disponible',
              ownerFirstName: 'N/A',
              ownerLastName: 'N/A',
              phone: 'N/A',
              plat: 'Standard',
              price: '0',
              quantity: 1,
              payment: 'N/A',
              image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
            );
          }

          return restaurant(
            id_restaurant: _getSafeString(data, 'id_restaurant', _getSafeString(data, 'id', 'unknown')),
            id_gestionnaire: _getSafeString(data, 'id_gestionnaire', 'unknown'),
            nom: _getSafeString(data, 'nom', 'Nom non disponible'),
            adresse: _getSafeString(data, 'adresse', 'Adresse non disponible'),
            description: _getSafeString(data, 'description', 'Description non disponible'),
            email: _getSafeString(data, 'email', 'Non disponible'),
            localisation: _getSafeString(data, 'localisation', 'Adresse non disponible'),
            ownerFirstName: _getSafeString(data, 'ownerFirstName', 'N/A'),
            ownerLastName: _getSafeString(data, 'ownerLastName', 'N/A'),
            phone: _getSafeString(data, 'phone', 'N/A'),
            plat: _getSafeString(data, 'plat', 'Standard'),
            price: _getSafeString(data, 'price', '0'),
            quantity: _getSafeInt(data, 'quantity', 1),
            payment: _getSafeString(data, 'payment', 'N/A'),
            image: _getSafeString(data, 'image', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'),
          );
        }).toList();

        _isLoading = false;

        print('✨ Données transformées en Restaurant avec succès !');
        print('📝 Nombre de restaurants: ${restaurants.length}');
        if (restaurants.isNotEmpty) {
          print('🏨 Premier restaurant: ${restaurants[0].nom}');
        }
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

      // Fallback avec un ou deux restaurants
      setState(() {
        restaurants = [
          restaurant(
            id_restaurant: '1',
            id_gestionnaire: '1',
            nom: 'Restaurant Maria',
            adresse: 'Bamako',
            description: 'Restaurant traditionnel',
            email: 'maria@restaurant.com',
            localisation: 'Bamako, Mali',
            ownerFirstName: 'Maria',
            ownerLastName: 'Diakité',
            phone: '+223 12345678',
            plat: 'Plat du jour',
            price: '2500',
            quantity: 1,
            payment: 'Cash',
            image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
          ),
        ];
        _isLoading = false;
      });
    }
  }*/

  Future<void> _loadRestaurants() async {
    try {
      setState(() => _isLoading = true);

      /*print('🌐 URL de base utilisée: ${_hotelService._api.baseUrl}');*/

      final apiRestaurants = await _restaurantService.getRestaurants();

      if (apiRestaurants.isNotEmpty) {
        //print('🏨 Premier hôtel reçu: ${apiHotels[0]}');
        //print('🔑 Clés disponibles dans le premier hôtel: ${(apiHotels[0] as Map).keys.toList()}');
      }

      setState(() {
        // Convertir les données API au format attendu par votre interface
        restaurants = apiRestaurants.map<Map<String, dynamic>>((restaurant) {
          // Vérifier que hotel n'est pas null et est bien un Map
          if (restaurant == null || restaurant is! Map<String, dynamic>) {
            return {
              'id_restaurant': 'unknown',
              'id_gestionnaire': 'unknown',
              'nom': 'Restaurant inconnu',
              'adresse': 'Adresse non disponible',
              'description': 'Description non disponible',
              'email': 'Non disponible',
              'localisation': 'Adresse non disponible',
              'ownerFirstName': 'N/A',
              'ownerLastName': 'N/A',
              'phone': 'N/A',
              'plat': 'Standard',
              'price': '0',
              'quantity': 1,
              'payment': 'N/A',
              'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
            };
          }

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

        print('✨ Données transformées avec succès!');
        print('📝 Nombre d\'hôtels traités: ${restaurants.length}');
        if (restaurants.isNotEmpty) {
          print('🏨 Premier hôtel après transformation: ${restaurants[0]}');
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      // Optionnel : afficher une snackbar d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Pas de connexion backend. Données de test affichées.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }

      // Données de fallback en cas d'erreur réseau
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
            'phone': '+223 12345678',
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


  List<Map<String, dynamic>> get _filteredRestaurants {
    List<Map<String, dynamic>> result = restaurants.where((resto) {
      final nameMatch = resto['nom'].toLowerCase().contains(_searchQuery.toLowerCase());
      final locationMatch = resto['localisation'].toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || locationMatch;
    }).toList();

    if (_selectedFilter == 1) {
      result.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else if (_selectedFilter == 2) {
      // Simuler un tri par distance
      result.sort((a, b) => a['nom'].length.compareTo(b['nom'].length));
    }

    return result;
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadRestaurants();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newRestaurant = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (_) => const AddRestaurantPage()),
          );
          if (newRestaurant != null) {
            setState(() => restaurants.add(newRestaurant));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantOrderPage(restaurant: restaurant),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Image.network(
                  restaurant['image'],
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
                          restaurant['nom'],
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
                          restaurant['localisation'],
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    restaurant['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plat: ${restaurant['plat']}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${restaurant['price']} FCFA',
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