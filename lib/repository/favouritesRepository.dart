import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<void> addProductToFavourites(
    String productId,
    String favouriteId,
  ) async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      // Hämta produktens data
      final productDoc = await _firestore
          .collection(productCollection)
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Produkten finns inte');
      }

      final productData = productDoc.data();

      if (productData == null) {
        throw Exception('Produktens data saknas');
      }

      // Referens till favoritlistans dokument
      final favouriteRef = _firestore
          .collection(favouriteCollection)
          .doc(favouriteId);

      // Lägg till produkten i favoritlistans array (utan dubbletter)
      await favouriteRef.update({
        'products': FieldValue.arrayUnion([
          {
            'id': productId,
            'title': productData['title'],
            'price': productData['price'],
            'image': productData['image'],
          },
        ]),
      });

      print('Produkt tillagd i favoritlista');
    } catch (e) {
      print('Fel: $e');
      rethrow;
    }
  }
}
