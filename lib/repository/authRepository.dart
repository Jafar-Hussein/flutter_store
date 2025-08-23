import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_store/repository/favouritesRepository.dart';
import 'package:flutter_store/models/user.dart';

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
  UserRole role,
) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = result.user!.uid;

    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'savedProducts': [],
      'lastViewedProductIds': [],
      'role': role.toString().split('.').last, // Spara vald roll
    };

    await _firestore.collection(userCollection).doc(uid).set(userData);

    await FavouritesRepository().createFavouriteList();

    print('Användare och favoritlista skapade.');

    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last, // Returnera roll
    };
  } catch (e) {
    print('Fel: $e');
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
          'role': data['role'] ?? 'customer', // Returnera roll
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
