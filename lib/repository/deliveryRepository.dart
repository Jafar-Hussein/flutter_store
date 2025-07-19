import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_store/models/delivery/delivery.dart';
import 'package:flutter_store/models/delivery/deliveryDto.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
        currentCity: dto.currentCity,
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
        print('Leverans finns inte');
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

  Future<Delivery?> getDeliveryById(String id) async {
    if (id.isEmpty) {
      print('id får inte vara tom');
      return null;
    }
    try {
      final snapshot = await _firestore
          .collection(deliveryCollection)
          .where('deliveryId', isEqualTo: id)
          .get();

      if (snapshot.docs.isEmpty) {
        print('Leverans finns inte');
        return null;
      }

      return Delivery.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      print('Fel vid hämtning av leverans: $e');
      rethrow;
    }
  }

  Future<DeliveryDto?> deliveryStatus(String deliveryId) async {
    if (deliveryId.isEmpty) {
      print('Leverans-ID får inte vara tomt');
      return null;
    }

    try {
      final currentCity = await getCurrentCity();
      print('Aktuell stad är: $currentCity');

      final snapshot = await _firestore
          .collection(deliveryCollection)
          .doc(deliveryId)
          .get();

      if (!snapshot.exists) {
        print('Leverans finns inte');
        return null;
      }

      final data = snapshot.data()!;

      // Uppdatera currentCity i Firestore om den har ändrats
      if (currentCity != null && currentCity != data['currentCity']) {
        await _firestore.collection(deliveryCollection).doc(deliveryId).update({
          'currentCity': currentCity,
        });
        data['currentCity'] = currentCity; // uppdatera även lokalt
      }

      return DeliveryDto.fromJson(data);
    } catch (e) {
      print('Fel vid hämtning av leverans: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Platsbehörighet nekad');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.locality;
      }

      return null;
    } catch (e) {
      print('Fel vid platsinhämtning: $e');
      return null;
    }
  }
}
