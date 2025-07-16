import 'package:stripe_server/stripe_server.dart' as stripe_server;

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

void main() async {
  final env = DotEnv()..load(); // Laddar .env

  final app = Router();

  app.post('/create-payment-intent', (Request request) async {
    final body = await request.readAsString();
    final data = json.decode(body);

    final amount = data['amount'];
    final currency = data['currency'];

    final stripeSecret = env['STRIPE_KEY'];

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

    return Response.ok(
      response.body,
      headers: {'Content-Type': 'application/json'},
    );
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await serve(handler, 'localhost', 8080);
  print('sStripe-backend körs på http://${server.address.host}:${server.port}');
}
