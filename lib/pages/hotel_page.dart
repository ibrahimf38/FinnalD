import 'package:flutter/material.dart';
import 'formulairehotel.dart';
import 'resevation.dart';
import '../api/api_hotelService.dart'; // Ajout de l'import

class HotelPage extends StatefulWidget {
  @override
  _HotelPageState createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> {
  final HotelService _hotelService = HotelService(); // Instance du service
  List<Map<String, dynamic>> hotels = [];
  bool isLoading = true; // Indicateur de chargement
  int _selectedFilter = 0; // 0: Tous, 1: Populaires, 2: Proches
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHotels(); // Chargement des hôtels au démarrage
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  Future<void> _loadHotels() async {
    try {
      setState(() => isLoading = true);

      /*print('🌐 URL de base utilisée: ${_hotelService._api.baseUrl}');*/

      final apiHotels = await _hotelService.getHotels();

      if (apiHotels.isNotEmpty) {
        //print('🏨 Premier hôtel reçu: ${apiHotels[0]}');
        //print('🔑 Clés disponibles dans le premier hôtel: ${(apiHotels[0] as Map).keys.toList()}');
      }

      setState(() {
        // Convertir les données API au format attendu par votre interface
        hotels = apiHotels.map<Map<String, dynamic>>((hotel) {
          // Vérifier que hotel n'est pas null et est bien un Map
          if (hotel == null || hotel is! Map<String, dynamic>) {
            return {
              'id': 'unknown',
              'name': 'Hôtel inconnu',
              'location': 'Adresse non disponible',
              'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
              'type_hotel': 'Standard',
              'email': 'Non disponible',
              'description': 'Description non disponible',
              'room ': 1,
              'price': '0', // Ajout pour compatibilité avec l'affichage
            };
          }

          return {
            'id': _getSafeString(hotel, 'id', _getSafeString(hotel, '_id', 'unknown')),
            'name': _getSafeString(hotel, 'name', 'Nom non disponible'),
            'location': _getSafeString(hotel, 'location', 'Adresse non disponible'),
            'image': _getSafeString(hotel, 'image', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'),
            'type_hotel': _getSafeString(hotel, 'type_hotel', 'Standard'),
            'email': _getSafeString(hotel, 'email', 'Non disponible'),
            'description': _getSafeString(hotel, 'description', 'Description non disponible'),
            'room': _getSafeInt(hotel, 'room', 1),
            'price': _getSafeString(hotel, 'price', _getSafeString(hotel, 'price', '0')), // Support pour 'prix' aussi
            'rating': _getSafeDouble(hotel, 'rating', 3.0), // Ajout du rating pour compatibilité
          };
        }).toList();

        print('✨ Données transformées avec succès!');
        print('📝 Nombre d\'hôtels traités: ${hotels.length}');
        if (hotels.isNotEmpty) {
          print('🏨 Premier hôtel après transformation: ${hotels[0]}');
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

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
        hotels = [
          {
            'id': '1',
            'name': 'Hôtel Maria',
            'location': 'Bamako',
            'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
            'price': '25000',
            'type_hotel': 'Deluxe',
            'email': 'maria@hotel.com',
            'description': 'Hôtel 4 étoiles avec piscine et spa',
            'room': 50,
            'rating': 4.5,
          },
          {
            'id': '2',
            'name': 'Hôtel bord de l\'eau',
            'location': 'Bamako',
            'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
            'price': '20000',
            'type_hotel': 'Standard',
            'email': 'contact@hotelbordeau.com',
            'description': 'Hôtel 3 étoiles avec piscine',
            'room': 30,
            'rating': 3.5,
          },
        ];
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredHotels {
    if (_searchQuery.isEmpty) return hotels;
    return hotels.where((hotel) {
      final name = hotel['name']?.toString().toLowerCase() ?? '';
      final location = hotel['location']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hôtels Disponibles",
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          /* IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: HotelSearchDelegate(hotels: hotels),
              );
            },
          ),*/
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
                        title: const Text('Tous les hotels'),
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un hôtel...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadHotels(); // Recharger depuis l'API lors du pull-to-refresh
              },
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredHotels.isEmpty
                  ? const Center(
                child: Text(
                  'Aucun hôtel trouvé',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: filteredHotels.length,
                itemBuilder: (context, index) {
                  final hotel = filteredHotels[index];
                  return _buildHotelCard(context, hotel);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Map<String, dynamic> hotel) {
    // Valeurs par défaut sécurisées
    final name = hotel['name']?.toString() ?? 'Nom non disponible';
    final location = hotel['location']?.toString() ?? 'Adresse non disponible';
    final description = hotel['description']?.toString() ?? 'Description non disponible';
    final image = hotel['image']?.toString() ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4';
    final room = hotel['room']?.toString() ?? '0';
    final price = hotel['price']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelReservationPage(hotel: hotel),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                image,
                height: 180,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
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
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.hotel, color: Colors.blue, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            room,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$price FCFA/nuit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelReservationPage(hotel: hotel),
                            ),
                          );
                        },
                        child: const Text('Réserver'),
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

class HotelSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> hotels;

  HotelSearchDelegate({required this.hotels});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = hotels.where((hotel) {
      final nom = hotel['name']?.toString().toLowerCase() ?? '';
      final adresse = hotel['location']?.toString().toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return nom.contains(queryLower) || adresse.contains(queryLower);
    }).toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = hotels.where((hotel) {
      final nom = hotel['name']?.toString().toLowerCase() ?? '';
      final adresse = hotel['location']?.toString().toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return nom.contains(queryLower) || adresse.contains(queryLower);
    }).toList();

    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final hotel = results[index];
        final nom = hotel['name']?.toString() ?? 'Nom non disponible';
        final adresse = hotel['location']?.toString() ?? 'Adresse non disponible';
        final image = hotel['image']?.toString() ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4';
        final price = hotel['price']?.toString() ?? '0';

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(image),
          ),
          title: Text(nom),
          subtitle: Text(adresse),
          trailing: Text('$price FCFA'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HotelReservationPage(hotel: hotel),
              ),
            );
          },
        );
      },
    );
  }
}