import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authrepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final String userCollection = 'user';

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String lastName,
    DateTime dateOfBirth,
  ) async {
    try {
      // Skapa auth-konto
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;

      // Skapa användardata att spara i Firestore
      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'savedProducts': [],
      };

      await _firestore.collection(userCollection).doc(uid).set(userData);

      // Returnera relevant data till frontend
      return {
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      };
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = result.user!.uid;

        final doc = await _firestore.collection(userCollection).doc(uid).get();
        final data = doc.data();

        if (doc.exists && data != null) {
          return {
            'uid': uid,
            'email': data['email'],
            'firstName': data['firstName'],
            'lastName': data['lastName'],
          };
        } else {
          throw Exception('Användardata kunde inte hittas.');
        }
      } else {
        throw Exception('Fält får inte vara tomma.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
