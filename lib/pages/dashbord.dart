

/*
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Importez vos services
import '../api/api_hotelService.dart';
import '../api/api_restaurantService.dart';
import '../api/api_activiteService.dart';
// ⚠️ Assurez-vous d'importer vos formulaires pour la modification
// (Ces imports sont essentiels pour le passage à la modification)
import 'package:MaliDiscover/pages/formulairehotel.dart';
import 'formulairerestaurant.dart';
import 'formulaireActiviter.dart';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Services
  final HotelService _hotelService = HotelService();
  final RestaurantService _restaurantService = RestaurantService();
  final ActiviteService _activiteService = ActiviteService();

  // 1. ✅ État pour stocker les données
  bool isLoading = true;
  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _activities = [];
  Map<String, int> stats = {'hotels': 0, 'restaurants': 0, 'activities': 0, 'users': 0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 2. ✅ Fonction pour la récupération des données
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      // Récupération des listes via les services API
      final hotels = await _hotelService.getHotels();
      final restaurants = await _restaurantService.getRestaurants();
      final activities = await _activiteService.getActivites();

      setState(() {
        // Le .cast est nécessaire si les services retournent List<dynamic>
        _hotels = hotels.cast<Map<String, dynamic>>();
        _restaurants = restaurants.cast<Map<String, dynamic>>();
        _activities = activities.cast<Map<String, dynamic>>();

        // Mise à jour des statistiques
        stats['hotels'] = _hotels.length;
        stats['restaurants'] = _restaurants.length;
        stats['activities'] = _activities.length;
        // ... (Statistiques utilisateurs si disponible)

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Erreur de chargement: $e");
    }
  }

  // 3. ✅ Fonction pour la suppression (action DELETE)
  Future<void> _deleteItem(String type, String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Êtes-vous sûr de vouloir supprimer ce/cette $type ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        switch (type) {
          case 'hotel':
            await _hotelService.deleteHotel(id);
            break;
          case 'restaurant':
            await _restaurantService.deleteRestaurant(id);
            break;
          case 'activity':
            await _activiteService.deleteActivite(id);
            break;
        }
        Fluttertoast.showToast(msg: "$type supprimé avec succès!");
        _loadData(); // Recharger les données après la suppression
      } catch (e) {
        Fluttertoast.showToast(msg: "Erreur de suppression: $e");
      }
    }
  }

  // 4. ✅ Fonction pour la modification (action PUT - navigation vers le formulaire)
  void _editItem(String type, Map<String, dynamic> item) async {
    Widget formPage;
    // Utiliser 'id' ou '_id' selon ce que votre back-end retourne pour l'ID de Firestore/MongoDB
    final String docId = item['id'] ?? item['_id'] ?? '';

    if (docId.isEmpty) {
      Fluttertoast.showToast(msg: "ID de l'élément manquant pour la modification.");
      return;
    }

    switch (type) {
      case 'hotel':
      // ⚠️ Le formulaire doit accepter l'objet existant (initialData) et l'ID (docId)
        formPage = AddHotelPage(initialData: item, docId: docId);
        break;
      case 'restaurant':
        formPage = AddRestaurantPage(initialData: item, docId: docId);
        break;
      case 'activity':
        formPage = AddActivityPage(initialData: item, docId: docId);
        break;
      default:
        return;
    }

    // Navigue et attend un résultat (true si la modification a réussi)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formPage),
    );

    if (result == true) {
      _loadData(); // Recharger les données si le formulaire a réussi la modification
    }
  }

  // 5. ✅ Widget pour afficher la liste avec actions (le corps de la section CRUD)
  Widget _buildItemListSection(String title, String type, List<Map<String, dynamic>> items) {
    // Clé pour afficher le nom (généralement 'nom' ou 'name')
    final keyName = (type == 'hotel') ? 'name' : 'nom';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Aucun $type trouvé.", style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ...items.map((item) {
              final id = item['id'] ?? item['_id'] ?? 'unknown_id';
              final name = item[keyName] ?? 'Nom inconnu';

              return ListTile(
                title: Text(name),
                subtitle: Text('ID: $id'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton de modification
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editItem(type, item),
                    ),
                    // Bouton de suppression
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(type, id),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de Bord Admin')),
      body: isLoading
          ? _buildLoadingShimmer() // Votre widget Shimmer pour le chargement
          : RefreshIndicator(
        onRefresh: _loadData, // Permet de rafraîchir en tirant
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section des statistiques
            // ... (Votre GridView des statistiques)
            const SizedBox(height: 20),

            // Affichage des listes avec les actions CRUD
            _buildItemListSection('Gestion des Hôtels (${_hotels.length})', 'hotel', _hotels),
            const SizedBox(height: 20),

            _buildItemListSection('Gestion des Restaurants (${_restaurants.length})', 'restaurant', _restaurants),
            const SizedBox(height: 20),

            _buildItemListSection('Gestion des Activités (${_activities.length})', 'activity', _activities),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Implémentez ou conservez ces méthodes pour la complétude
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ListTile(title: Text('Chargement...'))
        )
    );
  }
}*/










import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Importez vos services
import '../api/api_hotelService.dart';
import '../api/api_restaurantService.dart';
import '../api/api_activiteService.dart';
//import '../api/api_userService.dart';
// Import des formulaires
import 'package:MaliDiscover/pages/formulairehotel.dart';
import 'formulairerestaurant.dart';
import 'formulaireActiviter.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Services
  final HotelService _hotelService = HotelService();
  final RestaurantService _restaurantService = RestaurantService();
  final ActiviteService _activiteService = ActiviteService();
  //final UserService _userService = UserService();

  // État pour stocker les données
  bool isLoading = true;
  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _activities = [];
  Map<String, int> stats = {'hotels': 0, 'restaurants': 0, 'activities': 0, 'users': 0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fonction pour la récupération des données
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      // Récupération des listes via les services API
      final hotels = await _hotelService.getHotels();
      final restaurants = await _restaurantService.getRestaurants();
      final activities = await _activiteService.getActivites();
      //final users = await _userService.getUsers();

      setState(() {
        _hotels = hotels.cast<Map<String, dynamic>>();
        _restaurants = restaurants.cast<Map<String, dynamic>>();
        _activities = activities.cast<Map<String, dynamic>>();

        // Mise à jour des statistiques
        stats['hotels'] = _hotels.length;
        stats['restaurants'] = _restaurants.length;
        stats['activities'] = _activities.length;
        // Note: Pour les utilisateurs, vous devrez implémenter une méthode spécifique
        stats['users'] = 6; // À remplacer par votre logique utilisateur

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Erreur de chargement: $e");
    }
  }

  // Fonction pour la suppression
  Future<void> _deleteItem(String type, String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Êtes-vous sûr de vouloir supprimer ce/cette $type ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        switch (type) {
          case 'hotel':
            await _hotelService.deleteHotel(id);
            break;
          case 'restaurant':
            await _restaurantService.deleteRestaurant(id);
            break;
          case 'activity':
            await _activiteService.deleteActivite(id);
            break;
        }
        Fluttertoast.showToast(msg: "$type supprimé avec succès!");
        _loadData();
      } catch (e) {
        Fluttertoast.showToast(msg: "Erreur de suppression: $e");
      }
    }
  }

  // Fonction pour la modification
  void _editItem(String type, Map<String, dynamic> item) async {
    Widget formPage;
    final String docId = item['id'] ?? item['_id'] ?? '';

    if (docId.isEmpty) {
      Fluttertoast.showToast(msg: "ID de l'élément manquant pour la modification.");
      return;
    }

    switch (type) {
      case 'hotel':
        formPage = AddHotelPage(initialData: item, docId: docId);
        break;
      case 'restaurant':
        formPage = AddRestaurantPage(initialData: item, docId: docId);
        break;
      case 'activity':
        formPage = AddActivityPage(initialData: item, docId: docId);
        break;
      default:
        return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formPage),
    );

    if (result == true) {
      _loadData();
    }
  }

  // Fonction pour l'ajout
  void _navigateToAddForm(String type) {
    Widget page;
    switch (type) {
      case 'hotel':
        page = AddHotelPage(initialData: {}, docId: '',);
        break;
      case 'restaurant':
        page = AddRestaurantPage(initialData: {}, docId: '',);
        break;
      case 'activity':
        page = AddActivityPage(initialData: {}, docId: '',);
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) => _loadData());
  }

 //cart statistique
  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12), // Réduire le padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color), // Réduire la taille de l'icône
            const SizedBox(height: 8), // Réduire l'espacement
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Réduire la police
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
                '$value',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold) // Réduire la police
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les boutons d'action rapide
  Widget _buildQuickActionButton(String text, IconData icon, Color color, String type) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(text),
      onPressed: () => _navigateToAddForm(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget pour afficher la liste avec actions (SANS bouton Ajouter)
  Widget _buildItemListSection(String title, String type, List<Map<String, dynamic>> items) {
    final keyName = (type == 'hotel') ? 'name' : 'nom';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre seul sans bouton Ajouter
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 10),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Aucun $type trouvé.",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),

            ...items.map((item) {
              final id = item['id'] ?? item['_id'] ?? 'unknown_id';
              final name = item[keyName] ?? 'Nom inconnu';
              final location = item['location'] ?? item['localisation'] ?? 'Localisation inconnue';

              return ListTile(
                title: Text(name),
                subtitle: Text(location),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editItem(type, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(type, id),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Admin'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingShimmer()
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section des statistiques
            const Text(
              'Statistiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard('Hôtels', stats['hotels']!, Icons.hotel, Colors.blue),
                _buildStatCard('Restaurants', stats['restaurants']!, Icons.restaurant, Colors.green),
                _buildStatCard('Activités', stats['activities']!, Icons.map, Colors.orange),
                _buildStatCard('Utilisateurs', stats['users']!, Icons.people, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // Section des actions rapides
            const Text(
              'Actions Rapides',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Ajouter un nouvel élément',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton('Nouvel Hôtel', Icons.hotel, Colors.blue, 'hotel'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionButton('Nouveau Restaurant', Icons.restaurant, Colors.green, 'restaurant'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildQuickActionButton('Nouvelle Activité', Icons.map, Colors.orange, 'activity'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sections de gestion (SANS boutons Ajouter intégrés)
            _buildItemListSection('Gestion des Hôtels (${_hotels.length})', 'hotel', _hotels),
            const SizedBox(height: 20),

            _buildItemListSection('Gestion des Restaurants (${_restaurants.length})', 'restaurant', _restaurants),
            const SizedBox(height: 20),

            _buildItemListSection('Gestion des Activités (${_activities.length})', 'activity', _activities),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget de chargement Shimmer
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Shimmer pour les statistiques
          const Text('Statistiques', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: List.generate(4, (index) => Card(child: Container(height: 100))),
          ),
          const SizedBox(height: 24),

          // Shimmer pour les actions rapides
          const Text('Actions Rapides', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(child: Container(height: 120)),
          const SizedBox(height: 24),

          // Shimmer pour les listes
          ...List.generate(3, (index) => Column(
            children: [
              Card(child: Container(height: 200)),
              const SizedBox(height: 20),
            ],
          )),
        ],
      ),
    );
  }
}