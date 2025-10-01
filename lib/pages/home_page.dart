import 'package:MaliDiscover/pages/admin_login.dart';
import 'package:MaliDiscover/pages/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MaliDiscover/pages/acceil_page.dart';
import 'package:MaliDiscover/pages/activite_page.dart';
import 'package:MaliDiscover/pages/hotel_page.dart';
import 'package:MaliDiscover/pages/login_page.dart';
import 'package:MaliDiscover/pages/profil_page.dart';
import 'package:MaliDiscover/pages/restaurant_page.dart';
import 'package:MaliDiscover/pages/search_page.dart';
import 'package:MaliDiscover/pages/setting_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int pageIndex = 0;
  String name = "Invité";
  String email = "guest@example.com";
  String profilePictureUrl = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDrawerOpen = false;

  final List<Widget> pages = [
     HotelPage(),
     RestaurantPage(),
     MapPage()
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Initialisation des animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "Invité";
      email = prefs.getString('email') ?? "guest@example.com";
      profilePictureUrl = prefs.getString('profilePictureUrl') ?? "";
    });
  }

  Future<void> _logout() async {
    await _animationController.reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      pageIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: pages[pageIndex],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: profilePictureUrl.isNotEmpty
                ? Hero(
                    tag: 'profile-picture',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profilePictureUrl),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.green.shade700,
                    ),
                  ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            text: "Accueil",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AcceilPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: "Profil",
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MyProfilePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
              await _loadUserData();
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            text: "Paramètres",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),_buildDrawerItem(
            icon: Icons.admin_panel_settings,
            text: "Administrateur",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  AdminLoginPage()),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: "Déconnexion",
            onTap: _logout,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade700),
      title: Text(text, style: TextStyle(color: color ?? Colors.black)),
      onTap: () {
        Navigator.pop(context); // Ferme le drawer
        onTap();
      },
      hoverColor: Colors.green.shade100,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green.shade700,
      elevation: 4.0,
      title: Row(
        children: [
          const Icon(Icons.explore, color: Colors.white),
          const SizedBox(width: 10),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            child: const Text("MaliDiscover"),
          ),
        ],
      ),
      actions: [
      /*  IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            _loadUserData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Actualisation des données..."),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),*/
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const SearchPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'Aide') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Aide"),
                  content: const Text("Bienvenue sur MaliDiscover. Explorez les meilleurs hôtels, restaurants et activités du Mali."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else if (value == 'À propos') {
              showAboutDialog(
                context: context,
                applicationName: "MaliDiscover",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.explore, color: Colors.green),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return ['Aide', 'À propos'].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        child: NavigationBar(
          selectedIndex: pageIndex,
          onDestinationSelected: _onPageChanged,
          backgroundColor: Colors.green.shade700,
          indicatorColor: Colors.white.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 400),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.hotel, color: Colors.white70),
              selectedIcon: const Icon(Icons.hotel, color: Colors.white),
              label: "Hôtels",
            ),
            NavigationDestination(
              icon: const Icon(Icons.restaurant, color: Colors.white70),
              selectedIcon: const Icon(Icons.restaurant, color: Colors.white),
              label: "Restaurants",
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_activity, color: Colors.white70),
              selectedIcon: const Icon(Icons.local_activity, color: Colors.white),
              label: "Activités",
            ),
          ],
        ),
      ),
    );
  }
}