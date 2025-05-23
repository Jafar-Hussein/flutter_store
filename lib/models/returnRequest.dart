import 'package:flutter_store/models/returnProduct.dart';

class ReturnRequest {
  final String id;
  final String userId;
  final String orderId;
  final List<ReturnProduct> returnedProducts;
  final DateTime requestedAt;
  final String status; // t.ex. 'pending', 'approved', 'rejected'

  ReturnRequest({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.returnedProducts,
    required this.requestedAt,
    required this.status,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json, String id) {
    return ReturnRequest(
      id: id,
      userId: json['userId'],
      orderId: json['orderId'],
      requestedAt: DateTime.parse(json['requestedAt']),
      status: json['status'],
      returnedProducts: (json['returnedProducts'] as List<dynamic>)
          .map((item) => ReturnProduct.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderId': orderId,
      'requestedAt': requestedAt.toIso8601String(),
      'status': status,
      'returnedProducts': returnedProducts
          .map((product) => product.toJson())
          .toList(),
    };
  }
}
