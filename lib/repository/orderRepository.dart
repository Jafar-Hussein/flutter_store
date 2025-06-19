import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/CartProduct.dart';
import 'package:flutter_store/models/Orderproduct.dart';
import 'package:flutter_store/models/cart.dart';
import 'package:flutter_store/models/order.dart' as model;

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String orderCollection = 'order';
  final String cartCollection = 'cart';

  Future<void> createOrder(Cart cart) async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      // 1. hämta användarens cart
      final cartDoc = await _firestore
          .collection(cartCollection)
          .doc(uid)
          .get();

      if (!cartDoc.exists) {
        throw Exception('Ingen kundvagn hittades.');
      }

      final cartData = cartDoc.data()!;

      final cart = Cart.fromJson(cartData, cartDoc.id);

      if (cart.items.isEmpty) {
        throw Exception('Kundvagnen är tom');
      }

      //2. Konvertera CartProduct till OrderProduct
      List<OrderProduct> orderProducts = cart.items
          .map(
            (item) => OrderProduct(
              id: item.id,
              title: item.title,
              price: item.price,
              quantity: item.quantity,
            ),
          )
          .toList();

      // 3. Skapa Order-objekt
      final newOrder = model.Order(
        id: '', // genereras av Firestore
        userId: uid,
        createdAt: DateTime.now(),
        products: orderProducts,
        total: cart.total,
      );

      // 4. Spara ordern
      await _firestore.collection(orderCollection).add(newOrder.toJson());

      // 5. Töm kundvagnen
      await _firestore.collection(cartCollection).doc(uid).update({
        'items': [],
        'total': 0.0,
      });

      print('Order skapad och kundvagn rensad.');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<model.Order>> getOrders() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser!.uid;

      // Hämta alla orders där användaren är userId
      final snapshot = await _firestore
          .collection(orderCollection)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      // Konvertera varje dokument till model.Order
      List<model.Order> orders = snapshot.docs.map((doc) {
        return model.Order.fromJson(doc.data(), doc.id);
      }).toList();

      return orders;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<model.Order> getOrder(String orderId) async {
    try {
      // hämtar specifik order med en orderId
      final orderDoc = await _firestore
          .collection(orderCollection)
          .doc(orderId)
          .get();
      // om det inte finns skickas en fel meddelande
      if (!orderDoc.exists) {
        throw Exception('Order finns inte');
      }
      // sparar datan från  dokumentet  till en variabel
      final data = orderDoc.data()!;
      // returnerar det
      return model.Order.fromJson(data, orderDoc.id);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
