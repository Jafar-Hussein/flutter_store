import 'package:flutter_store/models/delivery/delivery.dart';
import 'package:flutter_store/models/products.dart';


class DeliveryDto {
  final String userId;
  final List<Product> products;
  final DateTime deliveryTime;
  final String customerId;
  final String deliveryAddress;
  final DeliveryStatus status;
  final double deliveryFee;
  final String courierName;
  final String? trackingNumber;
  final DateTime? dispatchedTime;
  final DateTime? deliveredTime;
  final String? notes;
  final bool isPaid;

  DeliveryDto({
    required this.userId,
    required this.products,
    required this.deliveryTime,
    required this.customerId,
    required this.deliveryAddress,
    required this.status,
    required this.deliveryFee,
    required this.courierName,
    this.trackingNumber,
    this.dispatchedTime,
    this.deliveredTime,
    this.notes,
    required this.isPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'products': products.map((p) => p.toJson()).toList(),
      'deliveryTime': deliveryTime.toIso8601String(),
      'customerId': customerId,
      'deliveryAddress': deliveryAddress,
      'deliveryStatus': status.name,
      'deliveryFee': deliveryFee,
      'courierName': courierName,
      'trackingNumber': trackingNumber,
      'dispatchedTime': dispatchedTime?.toIso8601String(),
      'deliveredTime': deliveredTime?.toIso8601String(),
      'notes': notes,
      'isPaid': isPaid,
    };
  }
}
