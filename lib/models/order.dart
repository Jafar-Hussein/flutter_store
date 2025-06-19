import 'package:flutter_store/models/Orderproduct.dart';

class Order {
  final String id;
  final String userId;
  final DateTime createdAt;
  final List<OrderProduct> products;
  final double total;

  Order({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.products,
    required this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json, String id) {
    return Order(
      id: id,
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      total: (json['total'] as num).toDouble(),
      products: (json['products'] as List<dynamic>)
          .map((item) => OrderProduct.fromJson(item, id))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'total': total,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
