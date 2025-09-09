
import 'package:MaliDiscover/pages/formulaireActiviter.dart';
import 'package:MaliDiscover/pages/formulairehotel.dart';
import 'package:MaliDiscover/pages/formulairerestaurant.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:MaliDiscover/pages/data_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  Map<String, int> stats = {
    'hotels': 2,
    'restaurants': 2,
    'activities': 0,
    'users': 4
  };
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
       final stats = await db.getDashboardStats();
      
      setState(() {
        this.stats = stats;
        isLoading = false;
      });
    } catch (e) {
      _showToast('Erreur de chargement: $e');
      setState(() => isLoading = false);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Widget _buildStatCard(String title, int? value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('${value ?? 0}', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: List.generate(4, (index) => Card(
                child: Container(height: 120),
              )),
            ),
            SizedBox(height: 20),
            Card(child: Container(height: 300)),
            SizedBox(height: 20),
            Card(child: Container(height: 200)),
          ],
        ),
      ),
    );
  }

  void _navigateToAddForm(String type) {
    Widget page;
    switch (type) {
      case 'hotel':
        page = AddHotelPage();
        break;
      case 'restaurant':
        page = AddRestaurantPage();
        break;
      case 'activity':
        page = AddActivityPage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord - MaliDiscover'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingShimmer()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard('Hôtels', stats['hotels'], Icons.hotel, Colors.blue),
                      _buildStatCard('Restaurants', stats['restaurants'], Icons.restaurant, Colors.green),
                      _buildStatCard('Activités', stats['activities'], Icons.map, Colors.orange),
                      _buildStatCard('Utilisateurs', stats['users'], Icons.people, Colors.purple),
                    ],
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Répartition Hommes/Femmes', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Container(
                            height: 300,
                            child: SfCircularChart(
                              series: <CircularSeries>[
                                PieSeries<Map<String, dynamic>, String>(
                                  dataSource: [
                                    {'gender': 'Hommes', 'value': 60, 'color': Colors.blue},
                                    {'gender': 'Femmes', 'value': 40, 'color': Colors.pink},
                                  ],
                                  xValueMapper: (data, _) => data['gender'],
                                  yValueMapper: (data, _) => data['value'],
                                  pointColorMapper: (data, _) => data['color'],
                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Actions rapides', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _navigateToAddForm('hotel'),
                            child: Text('Ajouter un hôtel'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _navigateToAddForm('restaurant'),
                            child: Text('Ajouter un restaurant'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _navigateToAddForm('activity'),
                            child: Text('Ajouter une activité'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}