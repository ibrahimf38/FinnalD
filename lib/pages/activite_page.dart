/*
import 'package:MaliDiscover/api/api_activiteService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ActiviteService _activiteService = ActiviteService();
  final MapController mapController = MapController();
  final List<Map<String, dynamic>> locations = [];
  final LatLng _maliCenter = LatLng(17.5707, -3.9962);

  double _zoom = 6.6;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
  }

  void _initializeLocations() async {
    // Données statiques comme fallback
    final staticData = [
      {"lat": 12.6392, "lng": -8.0029, "title": "Monument de l'Indépendance", "color": Colors.yellow, "image": "assets/images/independance.jpg", "isBackendData": false},
      {"lat": 12.6530, "lng": -8.0020, "title": "Monument de la Paix", "color": Colors.yellow, "image": "assets/images/paix.jpg", "isBackendData": false},
      {"lat": 16.2700, "lng": -0.0433, "title": "Tombeau des Askia", "color": Colors.yellow, "image": "assets/images/tombeau.jpg", "isBackendData": false},
      {"lat": 14.4433, "lng": -11.4367, "title": "Porte de Tombouctou", "color": Colors.yellow, "image": "assets/images/porte.jpg", "isBackendData": false},
      {"lat": 12.6470, "lng": -8.0038, "title": "Statue de Kwame Nkrumah", "color": Colors.yellow, "image": "assets/images/nkuruma.jpg", "isBackendData": false},
      {"lat": 14.4974, "lng": -4.2019, "title": "Monument de la Bataille de Ségou", "color": Colors.yellow, "image": "assets/images/monument_bataille_segou.jpg", "isBackendData": false},
      {"lat": 13.9086, "lng": -4.5556, "title": "Stèle de Soundiata Keïta", "color": Colors.yellow, "image": "assets/images/stele_soundiata.jpg", "isBackendData": false},
      {"lat": 11.3172, "lng": -5.6662, "title": "Statue de Babemba Traoré", "color": Colors.yellow, "image": "assets/images/statue_babemba.jpg", "isBackendData": false},
      {"lat": 12.8600, "lng": -5.4689, "title": "Monument Samory Touré", "color": Colors.yellow, "image": "assets/images/samoryMonument.jpg", "isBackendData": false},
      {"lat": 14.5126, "lng": -4.1186, "title": "Place de la Liberté (Ségou)", "color": Colors.yellow, "image": "assets/images/place_liberte.jpg", "isBackendData": false},
      {"lat": 12.6152, "lng": -7.9844, "title": "Tour d'Afrique", "color": Colors.yellow, "image": "assets/images/tour_afrique.jpg", "isBackendData": false},
      {"lat": 12.6496, "lng": -8.0002, "title": "Monument des Martyrs", "color": Colors.yellow, "image": "assets/images/monument_martyrs.jpg", "isBackendData": false},
      {"lat": 16.7739, "lng": -3.0074, "title": "Fort de Médine", "color": Colors.yellow, "image": "assets/images/fort_medine.jpg", "isBackendData": false},
      {"lat": 14.4560, "lng": -11.4394, "title": "Tombouctou", "color": Colors.green, "image": "assets/images/tombouctouN.jpg", "isBackendData": false},
      {"lat": 14.3526, "lng": -10.7810, "title": "Grande Mosquée de Djenné", "color": Colors.green, "image": "assets/images/mosquee_djenne.jpg", "isBackendData": false},
      {"lat": 13.4450, "lng": -9.4858, "title": "Falaise de Bandiagara", "color": Colors.green, "image": "assets/images/falaise_bandiagara.jpg", "isBackendData": false},
      {"lat": 13.9058, "lng": -3.5269, "title": "Ville ancienne de Ségou", "color": Colors.green, "image": "assets/images/segou.jpg", "isBackendData": false},
      {"lat": 14.3333, "lng": -3.5833, "title": "Pays Dogon", "color": Colors.green, "image": "assets/images/pays_dogon.jpg", "isBackendData": false},
      {"lat": 13.9049, "lng": -4.5532, "title": "Delta intérieur du Niger", "color": Colors.green, "image": "assets/images/delta_niger.jpg", "isBackendData": false},
      {"lat": 13.5500, "lng": -5.1000, "title": "Lac Débo", "color": Colors.green, "image": "assets/images/lac_debo.jpg", "isBackendData": false},
      {"lat": 13.6333, "lng": -5.5000, "title": "Réserve de la Boucle du Baoulé", "color": Colors.green, "image": "assets/images/boucle_baoule.jpg", "isBackendData": false},
      {"lat": 12.6125, "lng": -7.9747, "title": "Parc national de Bamako", "color": Colors.green, "image": "assets/images/parc_bamako.jpg", "isBackendData": false},
      {"lat": 16.6858, "lng": -2.8844, "title": "Désert de l'Adrar", "color": Colors.green, "image": "assets/images/desert_adrar.jpg", "isBackendData": false},
      {"lat": 15.9167, "lng": -4.9167, "title": "Lac Faguibine", "color": Colors.green, "image": "assets/images/lac_faguibine.jpg", "isBackendData": false},
      {"lat": 14.2500, "lng": -3.2500, "title": "Plateau Dogon", "color": Colors.green, "image": "assets/images/plateau_dogon.jpg", "isBackendData": false},
      {"lat": 13.8000, "lng": -10.8333, "title": "Cascade de Banfora", "color": Colors.green, "image": "assets/images/cascade_banfora.jpg", "isBackendData": false},
      {"lat": 16.2667, "lng": -0.0500, "title": "Marché de Gao", "color": Colors.green, "image": "assets/images/marche_gao.jpg", "isBackendData": false},
      {"lat": 15.1167, "lng": -1.3333, "title": "Dune Rose de Koyma", "color": Colors.green, "image": "assets/images/dune_rose_koyma.jpg", "isBackendData": false},
      {"lat": 15.2786, "lng": -1.6925, "title": "Main de Fatima (Hombori Tondo)", "color": Colors.green, "image": "assets/images/main_fatima.jpg", "isBackendData": false},
    ];

    bool usingBackendData = false;
    List<Map<String, dynamic>> backendData = [];

    try {
      final apiActivites = await _activiteService.getActivites();
      print("ACTIVITE BACKEND : $apiActivites");

      if (apiActivites != null && apiActivites.isNotEmpty) {
        for (var activite in apiActivites) {
          if (activite != null && activite is Map<String, dynamic>) {
            double lat = _getSafeDouble(activite, 'latitude');
            double lng = _getSafeDouble(activite, 'longitude');

            if (_isValidCoordinate(lat, lng)) {
              String category = _getSafeString(activite, 'category', 'autre').toLowerCase();
              Color markerColor = Colors.blue;

              if (category.contains('monument')) {
                markerColor = Colors.yellow;
              } else if (category.contains('site') || category.contains('touristique')) {
                markerColor = Colors.green;
              } else if (category.contains('restaurant')) {
                markerColor = Colors.red;
              } else if (category.contains('hotel')) {
                markerColor = Colors.purple;
              } else if (category.contains('balade')) {
                markerColor = Colors.orange;
              }

              backendData.add({
                "lat": lat,
                "lng": lng,
                "title": _getSafeString(activite, 'nom', 'Activité'),
                "color": markerColor,
                "image": _getSafeString(activite, 'image', 'assets/default_activity.jpg'),
                "description": _getSafeString(activite, 'description', ''),
                "prix": _getSafeString(activite, 'prix', ''),
                "phone": _getSafeString(activite, 'phone', ''),
                "email": _getSafeString(activite, 'email', ''),
                "category": category,
                "isBackendData": true,
              });
            }
          }
        }
      }
    } catch (e) {
      print("Erreur de chargement des données depuis l'API: $e");
    }

    // PRIORITÉ AUX DONNÉES DU BACKEND
    if (backendData.isNotEmpty) {
      usingBackendData = true;
      setState(() {
        locations.clear();
        locations.addAll(backendData);
      });
      if (backendData.first["lat"] != null && backendData.first["lng"] != null) {
        _centerOnLocation(backendData.first["lat"], backendData.first["lng"]);
      }
    } else {
      setState(() {
        locations.clear();
        locations.addAll(staticData);
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usingBackendData
                ? "Données du serveur chargées (${locations.length} activités)"
                : "Données locales chargées (${locations.length} lieux). Aucune donnée serveur trouvée.",
          ),
          duration: Duration(seconds: 4),
          backgroundColor: usingBackendData ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // Helpers
  double _getSafeDouble(Map<String, dynamic> data, String key, [double defaultValue = 0.0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat >= 10.0 && lat <= 25.0 && lng >= -12.0 && lng <= 4.0;
  }

  String _getSafeString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  // UI
  List<Marker> get _markers => locations.map((loc) {
    final double lat = loc["lat"] ?? 0.0;
    final double lng = loc["lng"] ?? 0.0;

    return Marker(
      point: LatLng(lat, lng),
      width: 40,
      height: 40,
      child: Tooltip(
        message: (loc["title"] ?? "Lieu inconnu").toString(),
        child: IconButton(
          icon: Icon(Icons.location_on, color: loc["color"] ?? Colors.grey, size: 30),
          onPressed: () => _showLocationDetails(loc),
        ),
      ),
    );
  }).toList();

// =====================================================================
// FONCTION CRITIQUEMENT CORRIGÉE
// =====================================================================
  void _showReservationForm(String activityTitle) async {
    final _formKey = GlobalKey<FormState>();
    String _name = '';
    String _email = '';
    int _placeCount = 1;

    final TextEditingController _dateController = TextEditingController();
    String? _reservationDate;

    // Await pour attendre la fermeture complète du dialogue
    final bool? reservationConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Réserver pour\n$activityTitle"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom Complet'),
                    validator: (value) {
                      if (value == null || value.isEmpty) { return 'Veuillez entrer votre nom'; }
                      return null;
                    },
                    onSaved: (value) { _name = value ?? ''; },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) { return 'Veuillez entrer un email valide'; }
                      return null;
                    },
                    onSaved: (value) { _email = value ?? ''; },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nombre de places'),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null || int.parse(value!) <= 0) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _placeCount = int.tryParse(value ?? '1') ?? 1;
                    },
                  ),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date de Réservation',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
                        _dateController.text = formattedDate;
                        _reservationDate = formattedDate;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) { return 'Veuillez sélectionner une date'; }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Confirmer la Réservation'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    // 1. Dispose le contrôleur (résout 'A TextEditingController was used after being disposed')
    _dateController.dispose();

    // 2. Utilisation de addPostFrameCallback pour forcer l'exécution APRÈS le nettoyage du dialogue (résout assert(_dependents.isEmpty))
    if (reservationConfirmed == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Réservation pour $_name ($_placeCount places) le ${_reservationDate ?? ''} confirmée pour $activityTitle !"),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

// =====================================================================
// _showLocationDetails
// =====================================================================
  void _showLocationDetails(Map<String, dynamic> location) async {
    final String phone = location["phone"] ?? '';
    final String email = location["email"] ?? '';
    final String title = location["title"] ?? "Titre inconnu";

    final bool? shouldOpenReservation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location["image"] != null)
                location["image"].startsWith('assets/')
                    ? Image.asset(location["image"], height: 150, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(
                  location["image"],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.image_not_supported, size: 40)),
                  ),
                ),
              SizedBox(height: 16),
              Text(
                "Coordonnées: ${location["lat"]}, ${location["lng"]}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              if (location["description"] != null && location["description"].toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  "Description: ${location["description"]}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
              if (location["prix"] != null && location["prix"].toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.money, size: 18, color: Colors.green),
                    SizedBox(width: 4),
                    Text("Prix: ${location["prix"]}"),
                  ],
                ),
              ],
              if (phone.isNotEmpty || email.isNotEmpty) ...[
                SizedBox(height: 16),
                Divider(),
                Text("Contact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                if (phone.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Téléphone: $phone"),
                    ],
                  ),
                if (email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.email, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Flexible(child: Text("Email: $email")),
                      ],
                    ),
                  ),
              ],
              SizedBox(height: 16),
              location["isBackendData"] == true
                  ? Chip(
                label: Text("Données serveur"),
                backgroundColor: Colors.blue[100],
              )
                  : Chip(
                label: Text("Données locales"),
                backgroundColor: Colors.green[100],
              ),
            ],
          ),
        ),
        actions: [
          // Bouton de Réservation
          TextButton.icon(
            icon: Icon(Icons.event_available, color: Colors.orange),
            label: Text("Réserver une place"),
            onPressed: () {
              // Pop et retourne true pour indiquer qu'il faut ouvrir le formulaire de réservation
              Navigator.pop(context, true);
            },
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, false), // Pop et retourne false
              child: Text("Fermer")
          ),
        ],
      ),
    );

    // Si le résultat est 'true', on ouvre le deuxième dialogue.
    if (shouldOpenReservation == true) {
      _showReservationForm(title);
    }
  }


  void _zoomIn() {
    setState(() {
      _zoom += 0.5;
      mapController.move(mapController.center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 0.5;
      mapController.move(mapController.center, _zoom);
    });
  }

  void _resetMap() {
    setState(() {
      _zoom = 6.6;
      mapController.move(_maliCenter, _zoom);
    });
  }

  void _centerOnLocation(double lat, double lng) {
    setState(() {
      _zoom = 8.5;
      mapController.move(LatLng(lat, lng), _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des Activités (${locations.length})"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _initializeLocations(),
            tooltip: "Actualiser les données",
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(center: _maliCenter, zoom: _zoom, interactiveFlags: InteractiveFlag.all),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(heroTag: 'zoom_in', mini: true, onPressed: _zoomIn, child: Icon(Icons.zoom_in)),
                SizedBox(height: 8),
                FloatingActionButton(heroTag: 'zoom_out', mini: true, onPressed: _zoomOut, child: Icon(Icons.zoom_out)),
                SizedBox(height: 8),
                FloatingActionButton(heroTag: 'reset', mini: true, onPressed: _resetMap, child: Icon(Icons.my_location)),
              ],
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.white.withOpacity(0.85),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return GestureDetector(
                    onTap: () => _centerOnLocation(loc["lat"], loc["lng"]),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _showLocationDetails(loc),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: loc["color"]),
                              SizedBox(width: 6),
                              Text(
                                loc["title"] ?? "Lieu",
                                style: TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (loc["isBackendData"] == true) ...[
                                SizedBox(width: 4),
                                Icon(Icons.cloud, size: 12, color: Colors.yellow),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

import 'package:MaliDiscover/api/api_activiteService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // NOTE: Assuming ActiviteService is correctly defined and available
  final ActiviteService _activiteService = ActiviteService();
  final MapController mapController = MapController();
  final List<Map<String, dynamic>> locations = [];
  final LatLng _maliCenter = LatLng(17.5707, -3.9962);
  // Le TextEditingController doit être créé AVANT le dialogue
  final TextEditingController _dateController = TextEditingController();

  double _zoom = 6.6;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
  }

  // BONNE PRATIQUE: Toujours disposer les ressources pour éviter les fuites mémoire
  @override
  void dispose() {
    //mapController.dispose();
    // Le reste des contrôleurs est créé localement dans les méthodes et disposé immédiatement après.
    _dateController.dispose();
    super.dispose();
  }

  void _initializeLocations() async {
    // Données statiques comme fallback
    final staticData = [
      {"lat": 12.6392, "lng": -8.0029, "title": "Monument de l'Indépendance", "color": Colors.yellow, "image": "assets/images/independance.jpg", "isBackendData": false},
      {"lat": 12.6530, "lng": -8.0020, "title": "Monument de la Paix", "color": Colors.yellow, "image": "assets/images/paix.jpg", "isBackendData": false},
      {"lat": 16.2700, "lng": -0.0433, "title": "Tombeau des Askia", "color": Colors.yellow, "image": "assets/images/tombeau.jpg", "isBackendData": false},
      {"lat": 14.4433, "lng": -11.4367, "title": "Porte de Tombouctou", "color": Colors.yellow, "image": "assets/images/porte.jpg", "isBackendData": false},
      {"lat": 12.6470, "lng": -8.0038, "title": "Statue de Kwame Nkrumah", "color": Colors.yellow, "image": "assets/images/nkuruma.jpg", "isBackendData": false},
      {"lat": 14.4974, "lng": -4.2019, "title": "Monument de la Bataille de Ségou", "color": Colors.yellow, "image": "assets/images/monument_bataille_segou.jpg", "isBackendData": false},
      {"lat": 13.9086, "lng": -4.5556, "title": "Stèle de Soundiata Keïta", "color": Colors.yellow, "image": "assets/images/stele_soundiata.jpg", "isBackendData": false},
      {"lat": 11.3172, "lng": -5.6662, "title": "Statue de Babemba Traoré", "color": Colors.yellow, "image": "assets/images/statue_babemba.jpg", "isBackendData": false},
      {"lat": 12.8600, "lng": -5.4689, "title": "Monument Samory Touré", "color": Colors.yellow, "image": "assets/images/samoryMonument.jpg", "isBackendData": false},
      {"lat": 14.5126, "lng": -4.1186, "title": "Place de la Liberté (Ségou)", "color": Colors.yellow, "image": "assets/images/place_liberte.jpg", "isBackendData": false},
      {"lat": 12.6152, "lng": -7.9844, "title": "Tour d'Afrique", "color": Colors.yellow, "image": "assets/images/tour_afrique.jpg", "isBackendData": false},
      {"lat": 12.6496, "lng": -8.0002, "title": "Monument des Martyrs", "color": Colors.yellow, "image": "assets/images/monument_martyrs.jpg", "isBackendData": false},
      {"lat": 16.7739, "lng": -3.0074, "title": "Fort de Médine", "color": Colors.yellow, "image": "assets/images/fort_medine.jpg", "isBackendData": false},
      {"lat": 14.4560, "lng": -11.4394, "title": "Tombouctou", "color": Colors.green, "image": "assets/images/tombouctouN.jpg", "isBackendData": false},
      {"lat": 14.3526, "lng": -10.7810, "title": "Grande Mosquée de Djenné", "color": Colors.green, "image": "assets/images/mosquee_djenne.jpg", "isBackendData": false},
      {"lat": 13.4450, "lng": -9.4858, "title": "Falaise de Bandiagara", "color": Colors.green, "image": "assets/images/falaise_bandiagara.jpg", "isBackendData": false},
      {"lat": 13.9058, "lng": -3.5269, "title": "Ville ancienne de Ségou", "color": Colors.green, "image": "assets/images/segou.jpg", "isBackendData": false},
      {"lat": 14.3333, "lng": -3.5833, "title": "Pays Dogon", "color": Colors.green, "image": "assets/images/pays_dogon.jpg", "isBackendData": false},
      {"lat": 13.9049, "lng": -4.5532, "title": "Delta intérieur du Niger", "color": Colors.green, "image": "assets/images/delta_niger.jpg", "isBackendData": false},
      {"lat": 13.5500, "lng": -5.1000, "title": "Lac Débo", "color": Colors.green, "image": "assets/images/lac_debo.jpg", "isBackendData": false},
      {"lat": 13.6333, "lng": -5.5000, "title": "Réserve de la Boucle du Baoulé", "color": Colors.green, "image": "assets/images/boucle_baoule.jpg", "isBackendData": false},
      {"lat": 12.6125, "lng": -7.9747, "title": "Parc national de Bamako", "color": Colors.green, "image": "assets/images/parc_bamako.jpg", "isBackendData": false},
      {"lat": 16.6858, "lng": -2.8844, "title": "Désert de l'Adrar", "color": Colors.green, "image": "assets/images/desert_adrar.jpg", "isBackendData": false},
      {"lat": 15.9167, "lng": -4.9167, "title": "Lac Faguibine", "color": Colors.green, "image": "assets/images/lac_faguibine.jpg", "isBackendData": false},
      {"lat": 14.2500, "lng": -3.2500, "title": "Plateau Dogon", "color": Colors.green, "image": "assets/images/plateau_dogon.jpg", "isBackendData": false},
      {"lat": 13.8000, "lng": -10.8333, "title": "Cascade de Banfora", "color": Colors.green, "image": "assets/images/cascade_banfora.jpg", "isBackendData": false},
      {"lat": 16.2667, "lng": -0.0500, "title": "Marché de Gao", "color": Colors.green, "image": "assets/images/marche_gao.jpg", "isBackendData": false},
      {"lat": 15.1167, "lng": -1.3333, "title": "Dune Rose de Koyma", "color": Colors.green, "image": "assets/images/dune_rose_koyma.jpg", "isBackendData": false},
      {"lat": 15.2786, "lng": -1.6925, "title": "Main de Fatima (Hombori Tondo)", "color": Colors.green, "image": "assets/images/main_fatima.jpg", "isBackendData": false},
    ];

    bool usingBackendData = false;
    List<Map<String, dynamic>> backendData = [];

    try {
      final apiActivites = await _activiteService.getActivites();
      print("ACTIVITE BACKEND : $apiActivites");

      if (apiActivites != null && apiActivites.isNotEmpty) {
        for (var activite in apiActivites) {
          if (activite != null && activite is Map<String, dynamic>) {
            double lat = _getSafeDouble(activite, 'latitude');
            double lng = _getSafeDouble(activite, 'longitude');

            if (_isValidCoordinate(lat, lng)) {
              String category = _getSafeString(activite, 'category', 'autre').toLowerCase();
              Color markerColor = Colors.blue;

              if (category.contains('monument')) {
                markerColor = Colors.yellow;
              } else if (category.contains('site') || category.contains('touristique')) {
                markerColor = Colors.green;
              } else if (category.contains('restaurant')) {
                markerColor = Colors.red;
              } else if (category.contains('hotel')) {
                markerColor = Colors.purple;
              } else if (category.contains('balade')) {
                markerColor = Colors.orange;
              }

              backendData.add({
                "lat": lat,
                "lng": lng,
                "title": _getSafeString(activite, 'nom', 'Activité'),
                "color": markerColor,
                "image": _getSafeString(activite, 'image', 'assets/default_activity.jpg'),
                "description": _getSafeString(activite, 'description', ''),
                "prix": _getSafeString(activite, 'prix', ''),
                "phone": _getSafeString(activite, 'phone', ''),
                "email": _getSafeString(activite, 'email', ''),
                "category": category,
                "isBackendData": true,
              });
            }
          }
        }
      }
    } catch (e) {
      print("Erreur de chargement des données depuis l'API: $e");
    }

    // --- PRISE EN COMPTE DES DONNÉES ET MISE À JOUR DE L'ÉTAT ---

    // Vérification de 'mounted' avant tout setState dans une fonction asynchrone
    if (!mounted) return;

    // PRIORITÉ AUX DONNÉES DU BACKEND
    if (backendData.isNotEmpty) {
      usingBackendData = true;
      setState(() {
        locations.clear();
        locations.addAll(backendData);
      });
      // Nouvelle vérification avant de centrer la carte
      if (mounted && backendData.first["lat"] != null && backendData.first["lng"] != null) {
        _centerOnLocation(backendData.first["lat"], backendData.first["lng"]);
      }
    } else {
      setState(() {
        locations.clear();
        locations.addAll(staticData);
      });
    }

    // SnackBar après la mise à jour (vérification 'mounted' déjà présente, c'est parfait)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usingBackendData
                ? "Données du serveur chargées (${locations.length} activités)"
                : "Données locales chargées (${locations.length} lieux). Aucune donnée serveur trouvée.",
          ),
          duration: Duration(seconds: 4),
          backgroundColor: usingBackendData ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // Helpers
  double _getSafeDouble(Map<String, dynamic> data, String key, [double defaultValue = 0.0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat >= 10.0 && lat <= 25.0 && lng >= -12.0 && lng <= 4.0;
  }

  String _getSafeString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  // UI
  List<Marker> get _markers => locations.map((loc) {
    final double lat = loc["lat"] ?? 0.0;
    final double lng = loc["lng"] ?? 0.0;

    return Marker(
      point: LatLng(lat, lng),
      width: 40,
      height: 40,
      child: Tooltip(
        message: (loc["title"] ?? "Lieu inconnu").toString(),
        child: IconButton(
          icon: Icon(Icons.location_on, color: loc["color"] ?? Colors.grey, size: 30),
          onPressed: () => _showLocationDetails(loc),
        ),
      ),
    );
  }).toList();

  void _showReservationForm(String activityTitle) async {
    final _formKey = GlobalKey<FormState>();
    String _name = '';
    String _email = '';
    int _placeCount = 1;

    String? _reservationDate;

    // Await pour attendre la fermeture complète du dialogue
    final bool? reservationConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Réserver pour\n$activityTitle"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom Complet'),
                    validator: (value) {
                      if (value == null || value.isEmpty) { return 'Veuillez entrer votre nom'; }
                      return null;
                    },
                    onSaved: (value) { _name = value ?? ''; },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) { return 'Veuillez entrer un email valide'; }
                      return null;
                    },
                    onSaved: (value) { _email = value ?? ''; },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nombre de places'),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null || int.parse(value!) <= 0) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _placeCount = int.tryParse(value ?? '1') ?? 1;
                    },
                  ),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date de Réservation',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
                        // Assurez-vous que le dialogue est toujours ouvert avant de mettre à jour le contrôleur
                        if (Navigator.canPop(context)) {
                          _dateController.text = formattedDate;
                          _reservationDate = formattedDate;
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) { return 'Veuillez sélectionner une date'; }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Confirmer la Réservation'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    // 1. DISPOSE DU CONTRÔLEUR : Résout 'A TextEditingController was used after being disposed.'
    _dateController.dispose();

    // 2. addPostFrameCallback : Résout l'assertion '_dependents.isEmpty'.
    // Ceci s'assure que le SnackBar est affiché APRÈS le nettoyage complet du dialogue.
    if (reservationConfirmed == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Réservation pour $_name ($_placeCount places) le ${_reservationDate ?? ''} confirmée pour $activityTitle !"),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

// =====================================================================
// _showLocationDetails
// =====================================================================
  void _showLocationDetails(Map<String, dynamic> location) async {
    final String phone = location["phone"] ?? '';
    final String email = location["email"] ?? '';
    final String title = location["title"] ?? "Titre inconnu";

    // Utilisation de 'await' pour s'assurer que le premier dialogue est fermé avant d'en ouvrir un autre
    final bool? shouldOpenReservation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location["image"] != null)
                location["image"].startsWith('assets/')
                    ? Image.asset(location["image"], height: 150, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(
                  location["image"],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.image_not_supported, size: 40)),
                  ),
                ),
              SizedBox(height: 16),
              Text(
                "Coordonnées: ${location["lat"]}, ${location["lng"]}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              if (location["description"] != null && location["description"].toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  "Description: ${location["description"]}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
              if (location["prix"] != null && location["prix"].toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.money, size: 18, color: Colors.green),
                    SizedBox(width: 4),
                    Text("Prix: ${location["prix"]}"),
                  ],
                ),
              ],
              if (phone.isNotEmpty || email.isNotEmpty) ...[
                SizedBox(height: 16),
                Divider(),
                Text("Contact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                if (phone.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Téléphone: $phone"),
                    ],
                  ),
                if (email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.email, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Flexible(child: Text("Email: $email")),
                      ],
                    ),
                  ),
              ],
              SizedBox(height: 16),
              location["isBackendData"] == true
                  ? Chip(
                label: Text("Données serveur"),
                backgroundColor: Colors.blue[100],
              )
                  : Chip(
                label: Text("Données locales"),
                backgroundColor: Colors.green[100],
              ),
            ],
          ),
        ),
        actions: [
          // Bouton de Réservation
          TextButton.icon(
            icon: Icon(Icons.event_available, color: Colors.orange),
            label: Text("Réserver une place"),
            onPressed: () {
              // Pop et retourne true pour indiquer qu'il faut ouvrir le formulaire de réservation
              Navigator.pop(context, true);
            },
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, false), // Pop et retourne false
              child: Text("Fermer")
          ),
        ],
      ),
    );

    // Si le résultat est 'true', on ouvre le deuxième dialogue.
    if (shouldOpenReservation == true) {
      _showReservationForm(title);
    }
  }


  void _zoomIn() {
    // Vérification 'mounted' n'est pas nécessaire ici car elle est synchrone et appelée par l'UI
    setState(() {
      _zoom += 0.5;
      mapController.move(mapController.center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 0.5;
      mapController.move(mapController.center, _zoom);
    });
  }

  void _resetMap() {
    setState(() {
      _zoom = 6.6;
      mapController.move(_maliCenter, _zoom);
    });
  }

  void _centerOnLocation(double lat, double lng) {
    setState(() {
      _zoom = 8.5;
      mapController.move(LatLng(lat, lng), _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des Activités (${locations.length})"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _initializeLocations(),
            tooltip: "Actualiser les données",
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(center: _maliCenter, zoom: _zoom, interactiveFlags: InteractiveFlag.all),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(heroTag: 'zoom_in', mini: true, onPressed: _zoomIn, child: Icon(Icons.zoom_in)),
                SizedBox(height: 8),
                FloatingActionButton(heroTag: 'zoom_out', mini: true, onPressed: _zoomOut, child: Icon(Icons.zoom_out)),
                SizedBox(height: 8),
                FloatingActionButton(heroTag: 'reset', mini: true, onPressed: _resetMap, child: Icon(Icons.my_location)),
              ],
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.white.withOpacity(0.85),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return GestureDetector(
                    onTap: () => _centerOnLocation(loc["lat"], loc["lng"]),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _showLocationDetails(loc),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: loc["color"]),
                              SizedBox(width: 6),
                              Text(
                                loc["title"] ?? "Lieu",
                                style: TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (loc["isBackendData"] == true) ...[
                                SizedBox(width: 4),
                                Icon(Icons.cloud, size: 12, color: Colors.yellow),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}