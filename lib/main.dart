import 'package:flutter/material.dart';
import 'package:MaliDiscover/pages/loading_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDJTtf-7Oo2jlto0PswUp677Q2jJ1tx234',
      appId: '1:296783292850:android:e15a9801c6a07739b35cab',
      messagingSenderId: '296783292850',
      projectId: 'discover-a5ac1',
      storageBucket: 'discover-a5ac1.firebasestorage.app',
      databaseURL: 'https://console.firebase.google.com/u/0/project/discover-a5ac1/firestore/databases/-default-/data'
    ),
  );
  // Chargement des préférences de thème
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? false;

  runApp(MyApp(darkMode: darkMode));
}

class MyApp extends StatelessWidget {
  final bool darkMode;

  const MyApp({super.key, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MaliDiscover',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green[800],
        ),
      ),
      darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green[800]!,
    brightness: Brightness.dark,
    ),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    elevation: 0,
    centerTitle: true,
    ),
  //cardTheme: CardTheme(
   // color: Colors.grey[800], // Changé de [850] à [800]
    //elevation: 2,
    //margin: const EdgeInsets.all(8),
    //),
),
      home: const MyloadingPage(title: 'loading'),
    );
  }
}