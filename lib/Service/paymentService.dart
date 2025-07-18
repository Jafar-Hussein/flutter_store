import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/delivery/delivery.dart';
import 'package:flutter_store/models/delivery/deliveryDto.dart';
import 'package:flutter_store/models/products.dart';
import 'package:flutter_store/models/stripePayment.dart';
import 'package:flutter_store/repository/cartRepository.dart';
import 'package:flutter_store/repository/orderRepository.dart';
import 'package:flutter_store/repository/deliveryRepository.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String backendUrl = 'http://localhost:8081/create-payment-intent';
  final String cartCollection = 'cart';
  final String userCollection = 'user';
  final String stripePaymentCollection = 'StripePayment';

  final Deliveryrepository _deliveryRepo = Deliveryrepository();

  Future<String> createPaymentIntent() async {
    try {
      final cartRepo = Cartrepository();
      final cart = await cartRepo.getCart();

      if (cart.items.isEmpty) {
        throw Exception("Kundvagnen är tom");
      }

      final amount = cart.total;

      String currency = 'SEK';
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).toInt(),
          'currency': currency,
        }),
      );
      final clientSecret =
          json.decode(response.body)['clientSecret'] ??
          'pi_test_fake_secret_from_webhook';

      final createOrder = OrderRepository();
      await createOrder.createOrder(cart);

      await paymentInfo(amount, clientSecret);

      print('Webhook skickat. Status: ${response.statusCode}');
      print('Webhook svar: ${response.body}');

      await cartRepo.clearCart();

      return clientSecret;
    } catch (e) {
      print('Fel vid test-paymentIntent: $e');
      rethrow;
    }
  }

  Future<void> paymentInfo(double amount, String clientSecret) async {
    final uid = auth.FirebaseAuth.instance.currentUser!.uid;

    final paymentRef = _firestore.collection(stripePaymentCollection).doc();

    final payment = StripePayment(
      paymentId: paymentRef.id,
      userId: uid,
      amount: amount,
      paymentStatus: Status.Pending,
      createdAt: DateTime.now(),
      clientSecret: clientSecret,
    );
    await paymentRef.set(payment.toJson());
  }

  Future<void> handleSuccessfulPayment({
    required String userId,
    required List<Product> products,
    required String customerId,
    required String deliveryAddress,
    required double deliveryFee,
    required String courierName,
    String? trackingNumber,
    DateTime? dispatchedTime,
    DateTime? deliveredTime,
    String? notes,
  }) async {
    final deliveryDto = DeliveryDto(
      userId: userId,
      products: products,
      deliveryTime: DateTime.now(),
      customerId: customerId,
      deliveryAddress: deliveryAddress,
      status: DeliveryStatus.Pending,
      deliveryFee: deliveryFee,
      courierName: courierName,
      trackingNumber: trackingNumber,
      dispatchedTime: dispatchedTime,
      deliveredTime: deliveredTime,
      notes: notes,
      isPaid: true,
    );
    if (deliveryDto == null) {
      print('Kundvagn är Tom');
      return;
    }
    await _deliveryRepo.createDelivery(deliveryDto);
  }

  Future<void> updatePaymentStatus({
    required String clientSecret,
    required Status status,
    List<dynamic>? products,
    String? customerId,
    String? deliveryAddress,
    double? deliveryFee,
    String? courierName,
    String? trackingNumber,
    DateTime? dispatchedTime,
    DateTime? deliveredTime,
    String? notes,
  }) async {
    try {
      final query = await _firestore
          .collection(stripePaymentCollection)
          .where('clientSecret', isEqualTo: clientSecret)
          .get();

      if (query.docs.isEmpty) {
        print('Ingen betalning hittades med detta clientSecret');
        return;
      }

      final docRef = query.docs.first.reference;
      await docRef.update({'paymentStatus': status.name});
      print('Betalningsstatus uppdaterad till: ${status.name}');

      if (status == Status.Succeeded) {
        final paymentData = query.docs.first.data();
        final userId = paymentData['userId'];

        if (products != null &&
            customerId != null &&
            deliveryAddress != null &&
            deliveryFee != null &&
            courierName != null) {
          // Konvertera List<dynamic> till List<Product>
          final productList = products.map<Product>((p) {
            if (p is Product) {
              return p;
            } else if (p is Map<String, dynamic>) {
              return Product.fromJson(p, p['id']);
            } else {
              throw Exception('Ogiltig produktdata');
            }
          }).toList();

          await handleSuccessfulPayment(
            userId: userId,
            products: productList,
            customerId: customerId,
            deliveryAddress: deliveryAddress,
            deliveryFee: deliveryFee,
            courierName: courierName,
            trackingNumber: trackingNumber,
            dispatchedTime: dispatchedTime,
            deliveredTime: deliveredTime,
            notes: notes,
          );
        } else {
          print('Saknar data för att skapa leverans');
        }
      }
    } catch (e) {
      print('Fel vid uppdatering av betalningsstatus: $e');
      rethrow;
    }
  }

  Future<void> createRefund() async {}
}
