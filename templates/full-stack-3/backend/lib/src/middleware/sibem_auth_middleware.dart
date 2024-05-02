import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';

class SibemAuthMiddleware {
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

      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, AUTH_KEY);
      decClaimSet.validate(issuer: 'app.site.com');
      var data = decClaimSet['data'];
      data['expiry'] = decClaimSet.expiry;

      req.container!.registerSingleton<AuthPayload>(AuthPayload.fromMap(data));

      return true;
    } on JwtException catch (e) {
      switch (e) {
        case JwtException.tokenExpired:
          throw AngelHttpException.fromMap(
              {'message': e.message, 'statusCode': 401});
        default:
          throw AngelHttpException.notAuthenticated();
      }
    } catch (e, s) {
      print('SibemAuthMiddleware@handleRequest: $e $s ');
      throw AngelHttpException.notAuthenticated();
    }
  }
}
