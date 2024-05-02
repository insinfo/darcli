import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'package:shelf/shelf.dart';

//https://stackoverflow.com/questions/65901123/dart-shelf-middleware-and-handler-execution-order
abstract class AuthMiddleware {
  static const secret = '7Fsxc2A865V67';
  static Middleware handleRequest() => (innerHandler) {
        return (request) async {
          try {
            var token = '';
            if (request.url.queryParameters.containsKey('t') &&
                request.url.queryParameters['t'] != null &&
                request.url.queryParameters['t']!.isNotEmpty) {
              token = request.url.queryParameters['t']!;
            } else {
              if (!request.headers.containsKey('authorization')) {
                return unauthorized(exception: 'faltando authorization header');
              }
              final authorization = request.headers['authorization'];
              if (authorization == null) {
                return unauthorized(
                    exception: 'Authorization header não pode ser nulo');
              }
              token = authorization.replaceAll('Bearer ', '');
            }

            final claim = verifyJwtHS256Signature(token, secret);
            claim.validate(issuer: 'app.site.com');
            //print(' claim.payload ${claim['data']}');
            return await innerHandler(request.change(
                context: {...request.context, 'tokenData': claim['data']}));
          } catch (e, s) {
            print('Middleware@handleRequest $e $s');
            return unauthorized(exception: e);
          }
        };
      };
}
