import 'package:flutter_store/models/CartProduct.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartProduct> items;
  final double total;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json, String id) {
    return Cart(
      id: id,
      userId: json['userId'],
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartProduct.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'total': total,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
