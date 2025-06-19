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
}
