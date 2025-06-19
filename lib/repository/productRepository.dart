import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/CartProduct.dart';
import 'package:flutter_store/models/Orderproduct.dart';
import 'package:flutter_store/models/cart.dart';
import 'package:flutter_store/models/products.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String productCollection = 'product';

  Future<Product> getProduct(String productId) async {
    try {
      //hämta specifik produkt
      final productDoc = await _firestore
          .collection(productCollection)
          .doc(productId)
          .get();

      // om det inte finns skicka fel meddelandet
      if (!productDoc.exists) {
        throw Exception('Produkt finns inte');
      }

      final data = productDoc.data()!;

      return Product.fromJson(data, productDoc.id);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      //hämtar alla produkter
      final snapshot = await _firestore
          .collection(productCollection)
          .orderBy('rating', descending: true)
          .get();

      //konvertera varje dokument till produkt model
      List<Product> products = snapshot.docs.map((doc) {
        return Product.fromJson(doc.data(), doc.id);
      }).toList();

      return products;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getproductsByCategory(String category) async {
    try {
      //hämtar alla produkter
      final snapshot = await _firestore
          .collection(productCollection)
          .where('category', isEqualTo: category)
          .get();

      //konvertera varje dokument till produkt model
      List<Product> products = snapshot.docs.map((doc) {
        return Product.fromJson(doc.data(), doc.id);
      }).toList();

      return products;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection(productCollection).get();

      // Extrahera kategori från varje dokument
      final categories = snapshot.docs.map((doc) {
        return doc['category'] as String;
      }).toList();

      // Ta bort dubbletter
      final uniqueCategories = categories.toSet().toList();

      return uniqueCategories;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Product> getProductByName(String productName) async {
    try {
      //hämta specifik produkt
      final snapshot = await _firestore
          .collection(productCollection)
          .where('title', isEqualTo: productName)
          .limit(1)
          .get();

      // om det inte finns skicka fel meddelandet
      if (snapshot.docs.isEmpty) {
        throw Exception('Produkt finns inte');
      }

      final doc = snapshot.docs.first;
      return Product.fromJson(doc.data(), doc.id);
      
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
