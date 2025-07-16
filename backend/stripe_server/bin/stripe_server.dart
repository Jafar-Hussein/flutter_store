import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:stripe_server/routes/stripeRoutes.dart';
import 'package:stripe_server/services/stripeService.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  // Skicka en lista med sökvägar (även om det är bara en)
  final env = dotenv.DotEnv()..load(['.env']);

  final stripeService = StripeService(env);
  final stripeRoutes = StripeRoutes(stripeService);

  final router = Router()..mount('/', stripeRoutes.router);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, 8081);
  print('✅ Servern kör på http://${server.address.host}:${server.port}');
}
