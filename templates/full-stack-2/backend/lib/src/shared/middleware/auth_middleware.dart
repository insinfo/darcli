import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_core/esic_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

//import 'package:riodasostrasapp_core/riodasostrasapp_core.dart';

class AuthMiddleware {
  static const key = '7Fsxc2A865V67';
  Future<bool> handleRequest(RequestContext req, ResponseContext res) async {
    try {
      //res.json({'message': StatusMessage.ACESSO_NAO_AUTORIZADO});
      //Authorization: Bearer
      if (req.headers == null ||
          req.headers!['Authorization'] == null ||
          req.headers!['Authorization'].toString() == '') {
        final exception = AngelHttpException.notAuthenticated(
            message: 'Acesso não permitido, header sem token!');
        exception.statusCode = 403;
        throw exception;
      }
      final token = req.headers!['Authorization']![0]
          .toString()
          .replaceAll('Bearer ', '');
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, key);
      decClaimSet.validate(issuer: 'app.site.com');
      final authTokenModel = AuthTokenJubarte.fromMap(decClaimSet['data']);
      req.container?.registerSingleton<AuthTokenJubarte>(authTokenModel);
      

      return true;
    } on JwtException catch (e) {
      if (e.toString().contains('expired')) {
        final exception =
            AngelHttpException.notAuthenticated(message: 'Sessão expirada!');
        exception.statusCode = 440;
        throw exception;
      } else {
        final exception = AngelHttpException.notAuthenticated(
            message: 'Acesso não permitido, token inválido!');
        exception.statusCode = 403;
        throw exception;
      }
    } catch (e) {
      throw AngelHttpException.notAuthenticated(message: '$e');
    }
  }
}
