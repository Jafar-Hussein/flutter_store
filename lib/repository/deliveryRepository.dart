import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/delivery/delivery.dart';
import 'package:flutter_store/models/delivery/deliveryDto.dart';

class Deliveryrepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String deliveryCollection = 'delivery';

  /// Skapar en ny leverans. currentCity sätts till startCity automatiskt.
  Future<void> createDelivery(DeliveryDto dto) async {
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
        currentCity: dto.startCity, // Startar där användaren har valt
        startCity: dto.startCity,
        endCity: dto.endCity,
      );

      await deliveryRef.set(delivery.toJson());
      print('Delivery created with ID: ${deliveryRef.id}');
    } catch (e) {
      print('Error creating delivery: $e');
      rethrow;
    }
  }

  /// Hämtar alla leveranser för inloggad användare
  Future<List<Delivery>?> getDeliveries() async {
    try {
      final uid = auth.FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print('Ingen inloggad användare');
        return null;
      }

      final snapshot = await _firestore
          .collection(deliveryCollection)
          .where('userId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isEmpty) {
        print('Inga leveranser hittades');
        return null;
      }

      return snapshot.docs
          .map((doc) => Delivery.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Fel vid hämtning av leveranser: $e');
      rethrow;
    }
  }

  /// Hämtar en specifik leverans med ID
  Future<Delivery?> getDeliveryById(String id) async {
    if (id.isEmpty) {
      print('Leverans-ID får inte vara tomt');
      return null;
    }
    try {
      final snapshot = await _firestore
          .collection(deliveryCollection)
          .doc(id)
          .get();

      if (!snapshot.exists) {
        print('Leveransen finns inte');
        return null;
      }

      return Delivery.fromJson(snapshot.data()!, snapshot.id);
    } catch (e) {
      print('Fel vid hämtning av leverans: $e');
      rethrow;
    }
  }

  /// Simulerar leveransstatus och kan uppdatera currentCity manuellt
  Future<DeliveryDto?> deliveryStatus(String deliveryId) async {
    if (deliveryId.isEmpty) {
      print('Leverans-ID får inte vara tomt');
      return null;
    }

    try {
      final snapshot = await _firestore
          .collection(deliveryCollection)
          .doc(deliveryId)
          .get();

      if (!snapshot.exists) {
        print('Leverans finns inte');
        return null;
      }

      final data = snapshot.data()!;
      return DeliveryDto.fromJson(data);
    } catch (e) {
      print('Fel vid hämtning av leveransstatus: $e');
      rethrow;
    }
  }

  /// Portfoliosyfte: tillåter manuell uppdatering av currentCity
  Future<void> simulateCityUpdate(String deliveryId, String nextCity) async {
    try {
      await _firestore.collection(deliveryCollection).doc(deliveryId).update({
        'currentCity': nextCity,
      });
      print('currentCity uppdaterad till $nextCity');
    } catch (e) {
      print('Kunde inte uppdatera currentCity: $e');
      rethrow;
    }
  }
}
