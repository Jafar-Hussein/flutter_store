import 'package:cloud_firestore/cloud_firestore.dart';

class StripePayment {
  final String paymentId;
  final String userId;
  final double amount;
  final Status paymentStatus;
  final DateTime createdAt;
  final String clientSecret;

  StripePayment({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.paymentStatus,
    required this.createdAt,
    required this.clientSecret,
  });

  factory StripePayment.fromJson(Map<String, dynamic> json, String id) {
    return StripePayment(
      paymentId: id,
      userId: json['userId'],
      amount: (json['amount'] as num).toDouble(),
      paymentStatus: Status.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            json['paymentStatus'].toString().toLowerCase(),
        orElse: () => Status.Failed,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      clientSecret: json['clientSecret'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'paymentStatus': paymentStatus.name,
      'createdAt': createdAt,
      'clientSecret': clientSecret,
    };
  }
}

enum Status { Failed, Succeeded, Pending }
