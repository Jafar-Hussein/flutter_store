import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/delivery/delivery.dart';
import 'package:flutter_store/models/delivery/deliveryDto.dart';

class Deliveryrepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String deliveryCollection = 'delivery';

  Future<void> createDelivery(DeliveryDto dto) async {
    if (dto == null) {
      print('Den är tom');
      return;
    }
    try {
      final deliveryRef = _firestore.collection(deliveryCollection).doc();

      final delivery = Delivery(
        deliveryId: deliveryRef.id,
        userId: dto.userId,
        products: dto.products,
        deliveryTime: dto.deliveryTime,
        customerId: dto.customerId,
        deliveryAddress: dto.deliveryAddress,
        status: dto.status,
        deliveryFee: dto.deliveryFee,
        courierName: dto.courierName,
        trackingNumber: dto.trackingNumber,
        dispatchedTime: dto.dispatchedTime,
        deliveredTime: dto.deliveredTime,
        notes: dto.notes,
        isPaid: dto.isPaid,
      );
      if (delivery == null) {
        print('Kundvagn är tom');
        return;
      }
      await deliveryRef.set(delivery.toJson());
      print('Delivery created with ID: ${deliveryRef.id}');
    } catch (e) {
      print('Error creating delivery: $e');
      rethrow;
    }
  }

  Future<List<Delivery>?> getDeliveries() async {
    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Ingen inloggad användare');
        return null;
      }

      final uid = user.uid;
      final snapshot = await _firestore
          .collection(deliveryCollection)
          .where('userId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isEmpty) {
        print('leverans finns inte');
        return null;
      }

      List<Delivery> deliveries = snapshot.docs.map((doc) {
        return Delivery.fromJson(
          doc.data(),
          doc.id,
        ); // använd doc.id om det behövs
      }).toList();

      return deliveries;
    } catch (e) {
      print('Fel vid hämtning av leveranser: $e');
      rethrow;
    }
  }

  Future<Delivery?> getDeliveryById(String id) async {
    if (id.isEmpty) {
      print('id får inte vara tom');
    }
    try {
      final snapshot = await _firestore
          .collection(deliveryCollection)
          .where('id', isEqualTo: id)
          .get();

      if (snapshot.docs.isEmpty) {
        print('leverans finns inte');
        return null;
      }

      final doc = snapshot.docs.first;
      return Delivery.fromJson(doc.data(), doc.id);
    } catch (e) {
      print('Fel vid hämtning av leverans: $e');
      rethrow;
    }
  }
}
