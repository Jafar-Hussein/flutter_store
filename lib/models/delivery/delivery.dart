import 'package:flutter_store/models/products.dart';

class Delivery {
  final String deliveryId;
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
  final String? startCity; // Nytt fält: startplats (butikens stad)
  final String? endCity; // Nytt fält: slutdestination (kundens stad)

  Delivery({
    required this.deliveryId,
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
    this.startCity,
    this.endCity,
  });

  factory Delivery.fromJson(Map<String, dynamic> json, String id) {
    return Delivery(
      deliveryId: id,
      userId: json['userId'],
      products: (json['products'] as List)
          .map(
            (productJson) => Product.fromJson(productJson, productJson['id']),
          )
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
      'deliveryId': deliveryId,
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

  Delivery copyWith({
    String? deliveryId,
    String? userId,
    List<Product>? products,
    DateTime? deliveryTime,
    String? customerId,
    String? deliveryAddress,
    DeliveryStatus? status,
    double? deliveryFee,
    String? courierName,
    String? trackingNumber,
    DateTime? dispatchedTime,
    DateTime? deliveredTime,
    String? notes,
    bool? isPaid,
    String? currentCity,
    String? startCity,
    String? endCity,
  }) {
    return Delivery(
      deliveryId: deliveryId ?? this.deliveryId,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      customerId: customerId ?? this.customerId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      courierName: courierName ?? this.courierName,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      dispatchedTime: dispatchedTime ?? this.dispatchedTime,
      deliveredTime: deliveredTime ?? this.deliveredTime,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      currentCity: currentCity ?? this.currentCity,
      startCity: startCity ?? this.startCity,
      endCity: endCity ?? this.endCity,
    );
  }
}

enum DeliveryStatus { Pending, Shipped, Delivered, Canceled, Returned }
