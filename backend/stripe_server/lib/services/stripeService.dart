import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

class StripeService {
  final String stripeSecret;

  StripeService(DotEnv env) : stripeSecret = env['STRIPE_SECRET_KEY'] ?? '' {
    if (stripeSecret.isEmpty) {
      throw Exception('Stripe secret key not found in .env');
    }
  }
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $stripeSecret',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Stripe PaymentIntent failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createRefund(String paymentIntentId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/refunds'),
        headers: {
          'Authorization': 'Bearer $stripeSecret',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'payment_intent': paymentIntentId},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Stripe refund failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in createRefund: $e');
    }
  }
}
