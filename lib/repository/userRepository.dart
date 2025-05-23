import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/returnProduct.dart';
import 'package:flutter_store/models/returnRequest.dart';

import 'package:flutter_store/models/user.dart';
import 'package:flutter_store/models/order.dart' as model;

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userCollection = 'user';

  Future<User> getUserInformation() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _firestore
          .collection(userCollection)
          .doc(uid)
          .get();

      if (snapshot.exists) {
        return User.fromJson(snapshot.data()!, snapshot.id);
      } else {
        throw Exception('Användardata finns inte.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedProducts() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await _firestore
          .collection(userCollection)
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Användaren finns inte');
      }

      final userData = userDoc.data()!;
      final savedProductIds = List<String>.from(
        userData['savedProducts'] ?? [],
      );

      final List<Map<String, dynamic>> savedProducts = [];

      for (final productId in savedProductIds) {
        final productDoc = await _firestore
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final data = productDoc.data()!;
          data['id'] = productDoc.id; // Lägg till dokumentets ID
          savedProducts.add(data);
        }
      }

      return savedProducts;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<model.Order>> getUserOrders() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return model.Order.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Fel vid hämtning av beställningar: $e');
      rethrow;
    }
  }

  Future<void> submitReturn(
    String orderId,
    List<ReturnProduct> products,
  ) async {
    try {
      // Hämtar inloggad användares UID
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      // Ser till att orderId och produktlistan inte är tomma
      if (orderId.isNotEmpty && products.isNotEmpty) {
        // Referens till 'returns'-collection i Firestore
        final returnsRef = _firestore.collection('returns');

        // Skapar en returförfrågan med användarens data och produkterna
        final request = ReturnRequest(
          id: '',
          userId: uid,
          orderId: orderId,
          returnedProducts: products,
          requestedAt: DateTime.now(),
          status: 'Pending',
        );

        // Sparar returförfrågan i Firestore
        final docRef = await returnsRef.add(request.toJson());

        print('Retur skapad med ID: ${docRef.id}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
