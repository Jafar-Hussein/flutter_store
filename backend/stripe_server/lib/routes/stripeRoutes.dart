import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:stripe_server/services/stripeService.dart';


class StripeRoutes {
  final StripeService _stripeService;

  StripeRoutes(this._stripeService);

  Router get router {
    final router = Router();

    // POST /create-payment-intent
    router.post('/create-payment-intent', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final amount = data['amount'];
        final currency = data['currency'];

        if (amount == null || currency == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'amount och currency krävs'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final result = await _stripeService.createPaymentIntent(
          amount: amount,
          currency: currency,
        );

        return Response.ok(
          jsonEncode(result),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // POST /create-refund
    router.post('/create-refund', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final paymentIntentId = data['paymentIntentId'];
        if (paymentIntentId == null || paymentIntentId.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'error': 'paymentIntentId krävs'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final refund = await _stripeService.createRefund(paymentIntentId);
        return Response.ok(
          jsonEncode(refund),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
