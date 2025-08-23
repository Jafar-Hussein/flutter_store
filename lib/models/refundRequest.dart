import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_store/models/products.dart';

class RefundRequest {
  final String refundId;
  final String paymentId;
  final String userId;
  final DateTime requestedAt;
  final RefundStatus status;
  final double amount;
  final String currency;
  final List<Product> products;

  RefundRequest({
    required this.refundId,
    required this.paymentId,
    required this.userId,
    required this.requestedAt,
    required this.status,
    required this.amount,
    required this.currency,
    required this.products,
  });

  factory RefundRequest.fromJson(Map<String, dynamic> json, String id) {
    return RefundRequest(
      refundId: id,
      paymentId: json['paymentId'],
      userId: json['userId'],
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      status: RefundStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => RefundStatus.Failed,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item, item['id']))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'requestedAt': requestedAt,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

enum RefundStatus { Accepted, Failed, Pending }
