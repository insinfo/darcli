import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';

class JubarteAuthMiddleware {
  /// Middleware para uso com o roteador customizado
  static Future Function(RequestContext req, ResponseContext res) handle(
      innerHandler) {
    return (RequestContext req, ResponseContext res) async {
      try {
        if (req.headers != null && req.headers!['Authorization'] == null ||
            req.headers!['Authorization'] == '') {
          throw AngelHttpException.notAuthenticated(
              message: StatusMessage.ACESSO_NAO_AUTORIZADO);
        }
        final token = req.headers!['Authorization']![0]
            .toString()
            .replaceAll('Bearer ', '');
        //print('token: $token');
        final JwtClaim decClaimSet = verifyJwtHS256Signature(token, AUTH_KEY);
        decClaimSet.validate(issuer: 'app.site.com');
        //req.headers.add('tokenData', decClaimSet.payload);
        // print(decClaimSet.containsKey('data'));
        //print('token data: ${decClaimSet['data']}');

        req.container!.registerSingleton<JubarteToken>(
            JubarteToken.fromMap(decClaimSet['data']));

        final innerResp = await innerHandler(req, res);
        return innerResp;
      } on JwtException catch (e) {
        switch (e) {
          case JwtException.tokenExpired:
            throw AngelHttpException.fromMap(
                {'message': e.message, 'statusCode': 401});
          default:
            throw AngelHttpException.notAuthenticated();
        }
      } catch (e) {
        //print('AuthMiddleware@handleRequest: $s ');
        //message: '$e'
        throw AngelHttpException.notAuthenticated();
      }
    };
  }

  Future handleRequest(RequestContext req, ResponseContext res) async {
    try {
      if (req.headers != null && req.headers!['Authorization'] == null ||
          req.headers!['Authorization'] == '') {
        throw AngelHttpException.notAuthenticated(
            message: StatusMessage.ACESSO_NAO_AUTORIZADO);
      }
      final token = req.headers!['Authorization']![0]
          .toString()
          .replaceAll('Bearer ', '');
      //print('token: $token');
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, AUTH_KEY);
      decClaimSet.validate(issuer: 'app.site.com');
      //req.headers.add('tokenData', decClaimSet.payload);
      // print(decClaimSet.containsKey('data'));
      //print('token data: ${decClaimSet['data']}');

      req.container!.registerSingleton<JubarteToken>(
          JubarteToken.fromMap(decClaimSet['data']));

      return true;
    } on JwtException catch (e) {
      switch (e) {
        case JwtException.tokenExpired:
          throw AngelHttpException.fromMap(
              {'message': e.message, 'statusCode': 401});
        default:
          throw AngelHttpException.notAuthenticated();
      }
    } catch (e) {
      //print('AuthMiddleware@handleRequest: $s ');
      //message: '$e'
      throw AngelHttpException.notAuthenticated();
    }
  }
}
