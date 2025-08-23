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
  final String currentCity;

  // Nya fält
  final String startCity; // T.ex. "Stockholm"
  final String endCity; // T.ex. "Upplands Väsby"

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
    required this.currentCity,
    required this.startCity,
    required this.endCity,
  });

  factory DeliveryDto.fromJson(Map<String, dynamic> json) {
    return DeliveryDto(
      userId: json['userId'],
      products: (json['products'] as List<dynamic>)
          .map((p) => Product.fromJson(p, p['id']))
          .toList(),
      deliveryTime: DateTime.parse(json['deliveryTime']),
      customerId: json['customerId'],
      deliveryAddress: json['deliveryAddress'],
      status: DeliveryStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            json['deliveryStatus'].toString().toLowerCase(),
        orElse: () => DeliveryStatus.Pending,
      ),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      courierName: json['courierName'],
      trackingNumber: json['trackingNumber'],
      dispatchedTime: json['dispatchedTime'] != null
          ? DateTime.parse(json['dispatchedTime'])
          : null,
      deliveredTime: json['deliveredTime'] != null
          ? DateTime.parse(json['deliveredTime'])
          : null,
      notes: json['notes'],
      isPaid: json['isPaid'],
      currentCity: json['currentCity'],
      startCity: json['startCity'],
      endCity: json['endCity'],
    );
  }
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
      'currentCity': currentCity,
      'startCity': startCity,
      'endCity': endCity,
    };
  }
}
