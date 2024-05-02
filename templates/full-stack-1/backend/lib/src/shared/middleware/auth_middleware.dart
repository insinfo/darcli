import 'dart:async';
import 'dart:convert';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class AuthMiddleware {
  static Future Function(RequestContext req, ResponseContext res) handleRequest(
      innerHandler) {
    return (RequestContext req, ResponseContext res) async {
      try {
        if (req.headers!['Authorization'] == null ||
            req.headers!['Authorization'] == '') {
          // throw AngelHttpException.notAuthenticated(
          //     message: StatusMessage.ACESSO_NAO_AUTORIZADO);
          res.statusCode = 401;
          res.headers['Content-Type'] = 'application/json;charset=utf-8';
          return res.write(jsonEncode({
            'is_error': true,
            'status_code': 401,
            'message': StatusMessage.ACESSO_NAO_AUTORIZADO,
          }));
        }
        final token = req.headers!['Authorization']![0]
            .toString()
            .replaceAll('Bearer ', '');
        //print('token: $token');
        final decClaimSet = verifyJwtHS256Signature(token, AuthController.key);
        decClaimSet.validate(issuer: 'app.site.com');
        //req.headers.add('tokenData', decClaimSet.payload);
        // print(decClaimSet.containsKey('data'));
        //print('token data: ${decClaimSet['data']}');
        var map = decClaimSet['data'];
        map['expiry'] = decClaimSet.expiry;
        req.container!.registerSingleton<AuthPayload>(AuthPayload.fromMap(map));

        // req.container!.registerNamedSingleton<TokenData>(
        //     'tokenData', TokenData.fromMap(decClaimSet['data']));
        final innerResp = await innerHandler(req, res);
        return innerResp;
      } catch (e, s) {
        res.statusCode = 401;
        res.headers['Content-Type'] = 'application/json;charset=utf-8';
        return res.write(jsonEncode({
          'is_error': true,
          'status_code': 401,
          'message': '$e $s',
        }));
      }
    };
  }

  static Future<bool> handleRequestAngel(
      RequestContext req, ResponseContext res) async {
    try {
      //Authorization: Bearer
      if (req.headers!['Authorization'] == null ||
          req.headers!['Authorization'] == '') {
        throw AngelHttpException.notAuthenticated(
            message: StatusMessage.ACESSO_NAO_AUTORIZADO);
      }
      final token = req.headers!['Authorization']![0]
          .toString()
          .replaceAll('Bearer ', '');
      //print('token: $token');
      final decClaimSet = verifyJwtHS256Signature(token, AuthController.key);
      decClaimSet.validate(issuer: 'app.site.com');
      //req.headers.add('tokenData', decClaimSet.payload);
      // print(decClaimSet.containsKey('data'));
      //print('token data: ${decClaimSet['data']}');
      var map = decClaimSet['data'];
      map['expiry'] = decClaimSet.expiry;
      req.container!.registerSingleton<AuthPayload>(AuthPayload.fromMap(map));
      // req.container!.registerNamedSingleton<TokenData>(
      //     'tokenData', TokenData.fromMap(decClaimSet['data']));

      return true;
    } catch (e, s) {
      // print('AuthMiddleware@handleRequest: $s $s');
      throw AngelHttpException.notAuthenticated(message: '$e $s');
    }
  }
}
