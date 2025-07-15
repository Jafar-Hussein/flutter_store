import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/CartProduct.dart';
import 'package:flutter_store/models/cart.dart';

class Cartrepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cartCollection = 'cart';

  Future<void> createCart() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;
      final cartRef = _firestore.collection(cartCollection).doc(uid);
      final cartSnapshot = await cartRef.get();

      if (!cartSnapshot.exists) {
        await cartRef.set({'userId': uid, 'total': 0, 'items': []});
        print('Cart skapad för användare $uid');
      } else {
        print('Cart finns redan för användare $uid');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Cart> getCart() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;
      final cartDoc = await _firestore
          .collection(cartCollection)
          .doc(uid)
          .get();

      if (!cartDoc.exists) {
        throw Exception('Cart finns inte för användare $uid');
      }

      final data = cartDoc.data()!;
      return Cart.fromJson(data, cartDoc.id);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<CartProduct> updateCartProductQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;
      final cartRef = _firestore.collection(cartCollection).doc(uid);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart finns inte');
      }

      final data = cartDoc.data()!;
      List<dynamic> items = data['items'];

      bool productFound = false;
      List<Map<String, dynamic>> updatedItems = [];

      for (var item in items) {
        if (item['id'] == productId) {
          item['quantity'] = quantity;
          productFound = true;
        }
        updatedItems.add(Map<String, dynamic>.from(item));
      }

      if (!productFound) {
        throw Exception('Produkt med id $productId finns inte i kundvagnen.');
      }

      double newTotal = updatedItems.fold(0, (sum, item) {
        return sum + (item['price'] * item['quantity']);
      });

      await cartRef.update({'items': updatedItems, 'total': newTotal});

      final updatedItem = updatedItems.firstWhere(
        (item) => item['id'] == productId,
      );
      return CartProduct.fromJson(updatedItem);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> deleteProductFromCart(String productId) async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;
      final cartRef = _firestore.collection(cartCollection).doc(uid);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart finns inte.');
      }

      final data = cartDoc.data()!;
      List<dynamic> items = data['items'];

      final updatedItems = items
          .where((item) => item['id'] != productId)
          .toList();

      double newTotal = updatedItems.fold(0, (sum, item) {
        return sum + (item['price'] * item['quantity']);
      });

      await cartRef.update({'items': updatedItems, 'total': newTotal});

      print('Produkt $productId togs bort från cart.');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;
      final cartRef = _firestore.collection(cartCollection).doc(uid);
      final cartDoc = await cartRef.get();

      final data = cartDoc.data();
      final items = data?['items'] as List<dynamic>?;

      if (!cartDoc.exists || items == null || items.isEmpty) {
        print("Kundvagnen är redan tom eller finns inte.");
        return;
      }

      await cartRef.update({'items': [], 'total': 0});
      print('Kundvagnen rensad för användare $uid');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
