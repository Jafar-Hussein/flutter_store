import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_store/models/FavouriteProduct%20.dart';

class FavouritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String productCollection = 'product';
  final String favouriteCollection = 'favourite';

  // Skapar en favoritlista om det inte redan finns en för användaren
  Future<void> createFavouriteList() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      // Referens till favoritlistans dokument
      final favouriteRef = _firestore.collection(favouriteCollection).doc(uid);

      // Hämta dokumentet
      final favouriteSnapshot = await favouriteRef.get();

      // Om det inte finns, skapa en tom lista
      if (!favouriteSnapshot.exists) {
        await favouriteRef.set({
          'userId': uid,
          'products': [], // fixat stavning från 'prducts' till 'products'
        });
        print('Favoritlista skapad för användare $uid');
      } else {
        print('Favoritlista finns redan för användare $uid');
      }
    } catch (e) {
      print('Fel: $e');
      rethrow;
    }
  }

  // Lägger till en produkt i favoritlistan
  Future<void> addProductToFavourites({
    required String favouriteId,
    required FavouriteProduct product,
  }) async {
    try {
      if (favouriteId.isEmpty) {
        throw Exception('Favorit-ID får inte vara tomt');
      }

      // Referens till dokumentet i "favourite"
      final favouriteRef = _firestore
          .collection(favouriteCollection)
          .doc(favouriteId);

      // Hämta aktuell favoritlista
      final favouriteDoc = await favouriteRef.get();

      if (!favouriteDoc.exists) {
        throw Exception('Favoritlistan finns inte');
      }

      final data = favouriteDoc.data()!;
      List<dynamic> currentProducts = data['products'] ?? [];

      // Kontrollera om produkten redan finns i listan (baserat på id)
      final alreadyExists = currentProducts.any(
        (item) => item['id'] == product.favouriteId,
      );

      if (alreadyExists) {
        print('Produkten finns redan i favoritlistan.');
        return;
      }

      // Lägg till den nya produkten
      currentProducts.add(product.toJson());

      // Uppdatera Firestore
      await favouriteRef.update({'products': currentProducts});

      print('Produkten lades till i favoritlistan.');
    } catch (e) {
      print('Fel vid tillägg till favoritlista: $e');
      rethrow;
    }
  }

  Future<List<FavouriteProduct>> getFavouriteProducts(
    String favouriteId,
  ) async {
    try {
      if (favouriteId.isEmpty) {
        print("Favorit listan finns inte");
      }

      final doc = await _firestore
          .collection(favouriteCollection)
          .doc(favouriteId)
          .get();

      if (!doc.exists) {
        print('Favoritlistan finns inte');
        return [];
      }
      final data = doc.data();
      final List<dynamic> productsJson = data?['products'] ?? [];

      List<FavouriteProduct> favouriteProducts = productsJson.map((item) {
        return FavouriteProduct.fromJson(item);
      }).toList();

      if (favouriteProducts.isEmpty) {
        print('Listan är tom');
      }

      return favouriteProducts;
    } catch (e) {
      print('Fel: $e');
      rethrow;
    }
  }

  Future<void> deleteItemFromList(String favouriteId, String productId) async {
    try {
      if (favouriteId.isEmpty || productId.isEmpty) {
        throw Exception('favorit id eller produkt id får inte vara tom');
      }

      final favouriteRef = _firestore
          .collection(favouriteCollection)
          .doc(favouriteId);

      final favouriteDoc = await favouriteRef.get();

      if (!favouriteDoc.exists) {
        throw Exception('listan finns inte');
      }

      final data = favouriteDoc.data()!;

      List<dynamic> products = data['products'];

      final updatedList = products.where((product) {
        return product['id'] != productId;
      }).toList();

      await favouriteRef.update({'products': updatedList});
    } catch (e) {
      print('Fel: $e');
      rethrow;
    }
  }
}
