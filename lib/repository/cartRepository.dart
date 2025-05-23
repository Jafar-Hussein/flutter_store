import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
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
}
