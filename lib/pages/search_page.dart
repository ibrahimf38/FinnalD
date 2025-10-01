import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> data = [
    "Hotel Maria",
    "Festival culturel à Bamako",
    "Restaurant Kati",
    "Randonnée à Ségou",
    "Restaurant Soleil",
    "Exploration du Pays Dogon",
    "Restaurant delicia",
    "Restaurant Sofia",
    "Hotel doumb",
    "Hasalah Hotel"
  ];
  
  List<String> results = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconForType(String text) {
    if (text.toLowerCase().contains('hotel')) {
      return Icons.hotel;
    } else if (text.toLowerCase().contains('restaurant')) {
      return Icons.restaurant;
    } else {
      return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Recherche", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Column(  // Correction: body au lieu de Body
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              results = [];
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                    results = data
                        .where((element) =>
                            element.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ),

          // Résultats
          Expanded(
            child: results.isNotEmpty
                ? ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            _getIconForType(results[index]),
                            color: Colors.green.shade700,
                          ),
                          title: Text(results[index]),
                          onTap: () {
                            // Action au clic
                          },
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      _isSearching ? "Aucun résultat" : "Commencez à rechercher",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}