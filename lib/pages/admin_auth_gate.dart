import 'package:MaliDiscover/pages/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:MaliDiscover/pages/admin_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Vérifiez si l'utilisateur est un admin
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _checkIfAdmin(snapshot.data!.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (adminSnapshot.data == true) {
                return  DashboardPage();
              } else {
                return const AdminLoginPage(
                  errorMessage: 'Accès réservé aux administrateurs',
                );
              }
            },
          );
        }
        
        return const AdminLoginPage();
      },
    );
  }

  Future<bool> _checkIfAdmin(String uid) async {
    // Implémentation du logique de vérification admin ici
    //  vérifiez dans Firestore
    final doc = await FirebaseFirestore.instance
        .collection('admin')
        .doc(uid)
        .get();
        
    return doc.exists;
  }
}