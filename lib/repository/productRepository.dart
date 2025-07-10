import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/CartProduct.dart';
import 'package:flutter_store/models/Orderproduct.dart';
import 'package:flutter_store/models/cart.dart';
import 'package:flutter_store/models/products.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String productCollection = 'product';
  final String cartCollection = 'cart';

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

  Future<List<Product>> getProductsSortedByPrice({
    bool descending = false,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(productCollection)
          .orderBy('price', descending: descending)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Produkter finns inte');
      }

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error in getProductsSortedByPrice: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsSortedByRating({
    bool descending = true,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(productCollection)
          .orderBy('rating', descending: descending)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Produkter finns inte');
      }

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error in getProductsSortedByRating: $e');
      rethrow;
    }
  }

  Future<void> addProductToCart(
    String productId,
    String cartId,
    int quantity,
  ) async {
    try {
      // Hämta aktuell användares UID
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      // Hämta produktdokumentet från Firestore
      final productDoc = await _firestore
          .collection(productCollection)
          .doc(productId)
          .get();

      // Referens till kundvagnens dokument
      final cartRef = _firestore.collection(cartCollection).doc(cartId);

      // Hämta kundvagnens dokument
      final cartDoc = await cartRef.get();

      // Om kundvagnen inte finns – skapa den med initial data
      if (!cartDoc.exists) {
        await cartRef.set({
          'userId': uid,
          'createdAt': Timestamp.now(),
          'total': 0, // totalpris = 0 till en början
        });
      }

      // Säkerställ att produktdata finns
      final productData = productDoc.data();
      if (productData == null) {
        throw Exception('Produkten saknar data');
      }

      // Skapa ett Product-objekt från Firestore-datan
      final product = Product.fromJson(productData, uid);

      // Referens till produktens rad i kundvagnens subcollection "items"
      final itemRef = cartRef.collection('items').doc(product.id);

      // Hämta existerande produkt (om den redan finns i kundvagnen)
      final existingItem = await itemRef.get();

      // Räkna ut ny kvantitet:
      int newQuantity = quantity;
      if (existingItem.exists) {
        final existingData = existingItem.data();
        final currentQuantity = existingData?['quantity'] ?? 0;
        newQuantity =
            currentQuantity + quantity; // lägg till i existerande antal
      }

      // Skapa datan som ska sparas för produkten i kundvagnen
      final cartProductData = {
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'quantity': newQuantity,
        'image': product.image,
      };

      // Lägg till eller uppdatera produkten i "items" subcollection
      await itemRef.set(cartProductData, SetOptions(merge: true));

      // Hämta alla produkter i kundvagnens "items" för att kunna räkna om totalpris
      final itemsSnapshot = await cartRef.collection('items').get();

      // Beräkna nya totalpriset: summan av (pris * kvantitet) för alla produkter
      double total = 0.0;
      for (var doc in itemsSnapshot.docs) {
        final item = doc.data();
        total += (item['price'] as num) * (item['quantity'] as num);
      }

      // Uppdatera kundvagnens huvuddokument med nya totalpriset
      await cartRef.update({'total': total});

      print('Produkt tillagd i kundvagn');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

 
}
