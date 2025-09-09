
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:MaliDiscover/pages/home_page.dart';
import 'package:MaliDiscover/pages/profil_page.dart';

class AcceilPage extends StatefulWidget {
  const AcceilPage({super.key});

  @override
  State<AcceilPage> createState() => _AcceilPageState();
}

class _AcceilPageState extends State<AcceilPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHoveringHome = false;
  bool _isHoveringProfile = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Version simple et fiable de Lottie
          Positioned.fill(
            child: Lottie.asset(
              'assets/lotties/animation.json',
              controller: _controller,
              fit: BoxFit.cover,
            ),
          ),
      
          // Overlay de dégradé
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.3, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre avec animation
                Text(
                  'MaliDiscover',
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: -0.5, end: 0, duration: 800.ms),

                SizedBox(height: screenHeight * 0.1),

                // Bouton Home avec effets d'interaction
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringHome = true),
                  onExit: (_) => setState(() => _isHoveringHome = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(_isHoveringHome ? 1.05 : 1.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MyHomePage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.025,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: _isHoveringHome ? 8 : 4,
                        shadowColor: Colors.teal.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, size: screenWidth * 0.06),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Explorer',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .slideX(begin: -0.5, end: 0, duration: 800.ms),

                SizedBox(height: screenHeight * 0.04),

                // Bouton Profile avec effets d'interaction
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringProfile = true),
                  onExit: (_) => setState(() => _isHoveringProfile = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(_isHoveringProfile ? 1.05 : 1.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MyProfilePage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.5),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.025,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: _isHoveringProfile ? 8 : 4,
                        shadowColor: Colors.deepOrange.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, size: screenWidth * 0.06),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Mon Profil',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms)
                    .slideX(begin: 0.5, end: 0, duration: 800.ms),

                // Légende avec animation subtile
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.08),
                  child: Text(
                    'Découvrez les merveilles du Mali',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: screenWidth * 0.035,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .shimmer(duration: 1500.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}