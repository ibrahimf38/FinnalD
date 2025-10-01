
import 'package:flutter/foundation.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetup {
  static Future<void> createDefaultAdmin() async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'admin@malidiscover.ml',
        password: 'AdminMali123!',
      );
      
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(cred.user!.uid)
          .set({
            'email': 'admin@malidiscover.ml',
            'isSuperAdmin': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
      
      if (kDebugMode) {
        debugPrint('Compte admin créé avec succès');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        if (e.code == 'email-already-in-use') {
          debugPrint('Le compte admin existe déjà');
        } else {
          debugPrint('Erreur de création admin: ${e.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue: $e');
      }
    }
  }
}