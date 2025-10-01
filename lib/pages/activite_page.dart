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

  @override
  void dispose() {
    // mapController.dispose(); // déjà commenté
    super.dispose();
  }

  void _initializeLocations() async {
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
    ];

    bool usingBackendData = false;
    List<Map<String, dynamic>> backendData = [];

    try {
      final apiActivites = await _activiteService.getActivites();
      if (apiActivites != null && apiActivites.isNotEmpty) {
        for (var activite in apiActivites) {
          if (activite is Map<String, dynamic>) {
            double lat = _getSafeDouble(activite, 'latitude');
            double lng = _getSafeDouble(activite, 'longitude');
            if (_isValidCoordinate(lat, lng)) {
              String category = _getSafeString(activite, 'category', 'autre').toLowerCase();
              Color markerColor = Colors.blue;
              if (category.contains('monument')) markerColor = Colors.yellow;
              else if (category.contains('site') || category.contains('touristique')) markerColor = Colors.green;
              else if (category.contains('restaurant')) markerColor = Colors.red;
              else if (category.contains('hotel')) markerColor = Colors.purple;
              else if (category.contains('balade')) markerColor = Colors.orange;

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
      debugPrint("Erreur de chargement API: $e");
    }

    if (!mounted) return;

    if (backendData.isNotEmpty) {
      usingBackendData = true;
      setState(() {
        locations..clear()..addAll(backendData);
      });
      if (mounted) {
        _centerOnLocation(backendData.first["lat"], backendData.first["lng"]);
      }
    } else {
      setState(() {
        locations..clear()..addAll(staticData);
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usingBackendData
                ? "Données serveur chargées (${locations.length})"
                : "Données locales chargées (${locations.length})",
          ),
          backgroundColor: usingBackendData ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  double _getSafeDouble(Map<String, dynamic> data, String key, [double defaultValue = 0.0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat >= 10 && lat <= 25 && lng >= -12 && lng <= 4;
  }

  String _getSafeString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  List<Marker> get _markers => locations.map((loc) {
    return Marker(
      point: LatLng(loc["lat"] ?? 0, loc["lng"] ?? 0),
      width: 40,
      height: 40,
      child: Tooltip(
        message: loc["title"] ?? "Lieu",
        child: IconButton(
          icon: Icon(Icons.location_on, color: loc["color"] ?? Colors.grey, size: 30),
          onPressed: () => _showLocationDetails(loc),
        ),
      ),
    );
  }).toList();

  // ✅ corrigé : plus de dispose()
  void _showReservationForm(String activityTitle) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _dateController = TextEditingController();

    String _name = '';
    String _email = '';
    int _placeCount = 1;
    String? _reservationDate;

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
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom Complet'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer votre nom' : null,
                    onSaved: (v) => _name = v ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                    onSaved: (v) => _email = v ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre de places'),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (v) {
                      if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                    onSaved: (v) => _placeCount = int.tryParse(v ?? '1') ?? 1,
                  ),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date de Réservation',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        String formatted = DateFormat('dd/MM/yyyy').format(picked);
                        _dateController.text = formatted;
                        _reservationDate = formatted;
                      }
                    },
                    validator: (v) => (v == null || v.isEmpty) ? 'Sélectionnez une date' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );

    if (reservationConfirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Réservation $_name ($_placeCount places) le ${_reservationDate ?? ''} confirmée pour $activityTitle"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showLocationDetails(Map<String, dynamic> location) async {
    final String title = location["title"] ?? "Titre inconnu";
    final String phone = location["phone"] ?? '';
    final String email = location["email"] ?? '';

    final bool? openReservation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location["image"] != null)
                location["image"].toString().startsWith('assets/')
                    ? Image.asset(location["image"], height: 150, fit: BoxFit.cover)
                    : Image.network(location["image"], height: 150, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50)),
              const SizedBox(height: 10),
              Text("Coordonnées: ${location["lat"]}, ${location["lng"]}"),
              if ((location["description"] ?? '').toString().isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 8), child: Text(location["description"])),
              if ((location["prix"] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [const Icon(Icons.money), Text(" ${location["prix"]}")]),
                ),
              if (phone.isNotEmpty || email.isNotEmpty) ...[
                const Divider(),
                if (phone.isNotEmpty) Text("Téléphone: $phone"),
                if (email.isNotEmpty) Text("Email: $email"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.event_available, color: Colors.orange),
            label: const Text("Réserver"),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Fermer")),
        ],
      ),
    );

    if (openReservation == true) {
      _showReservationForm(title);
    }
  }

  void _zoomIn() => setState(() { _zoom += 0.5; mapController.move(mapController.center, _zoom); });
  void _zoomOut() => setState(() { _zoom -= 0.5; mapController.move(mapController.center, _zoom); });
  void _resetMap() => setState(() { _zoom = 6.6; mapController.move(_maliCenter, _zoom); });
  void _centerOnLocation(double lat, double lng) => setState(() { _zoom = 8.5; mapController.move(LatLng(lat, lng), _zoom); });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte des Activités (${locations.length})"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeLocations),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(center: _maliCenter, zoom: _zoom, interactiveFlags: InteractiveFlag.all),
            children: [
              TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 20, right: 10,
            child: Column(
              children: [
                FloatingActionButton(heroTag: 'zoom_in', mini: true, onPressed: _zoomIn, child: const Icon(Icons.zoom_in)),
                const SizedBox(height: 8),
                FloatingActionButton(heroTag: 'zoom_out', mini: true, onPressed: _zoomOut, child: const Icon(Icons.zoom_out)),
                const SizedBox(height: 8),
                FloatingActionButton(heroTag: 'reset', mini: true, onPressed: _resetMap, child: const Icon(Icons.my_location)),
              ],
            ),
          ),
          Positioned(
            bottom: 70, left: 0, right: 0,
            child: Container(
              height: 100,
              color: Colors.white.withOpacity(0.85),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length,
                itemBuilder: (context, i) {
                  final loc = locations[i];
                  return GestureDetector(
                    onTap: () => _centerOnLocation(loc["lat"], loc["lng"]),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: InkWell(
                        onTap: () => _showLocationDetails(loc),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: loc["color"]),
                              const SizedBox(width: 6),
                              Text(loc["title"] ?? "Lieu", overflow: TextOverflow.ellipsis),
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
