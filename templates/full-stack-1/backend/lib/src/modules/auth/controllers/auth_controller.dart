import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:new_sali_backend/new_sali_backend.dart';

import 'package:new_sali_core/new_sali_core.dart';

class AuthController {
  static const key = '7Fsxc2A865V67';

  static Future<dynamic> authenticate(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final loginPayload = LoginPayload.fromMap(req.bodyAsMap);
      // o anoExercicio é sempre o ano atual
      loginPayload.anoExercicio = DateTime.now().year.toString();

      conn = await req.dbConnect();
      final authPayload = await AuthRepository(conn).authenticate(loginPayload);

      //const expiresInDays = 365 * 3;
      /// hora que o token vai expirar
      const int expirationSec = 32400; //32400 segundo = 9 horas
      final expiry = DateTime.now().add(const Duration(seconds: expirationSec));

      final claimSet = JwtClaim(
        //subject: 'kleak',
        issuer: 'app.site.com',
        issuedAt: DateTime.now(), //Emitido em timestamp de geracao do token
        notBefore: DateTime.now().subtract(
            const Duration(milliseconds: 1)), // token nao é valido Antes de
        // audience: <String>['app.site.com'],
        otherClaims: {
          'data': <String, dynamic>{
            'nom_cgm': authPayload.nomCgm,
            'cpf': authPayload.cpf,
            'numcgm': authPayload.numCgm,
            'username': authPayload.username,
            'ano_exercicio': loginPayload.anoExercicio,
            'cod_setor': authPayload.codSetor,
            'id_setor': authPayload.idSetor,
            'cod_orgao': authPayload.codOrgao,
            'cod_unidade': authPayload.codUnidade,
            'cod_departamento': authPayload.codDepartamento,
            'ano_exercicio_setor': authPayload.anoExercicioSetor,
          }
        },
        expiry: expiry,
        maxAge: const Duration(seconds: expirationSec),
      );
      final String token = issueJwtHS256(claimSet, key);

      await AuditoriaRepository(conn).insert(Auditoria(
          numCgm: authPayload.numCgm,
          codAcao: 1,
          timestamp: DateTime.now(),
          objeto: 'login app: ${authPayload.username}'));

      await conn.disconnect();

      return res.responseJson({
        'accessToken': token,
        'nom_cgm': authPayload.nomCgm,
        'cpf': authPayload.cpf,
        'numcgm': authPayload.numCgm,
        'username': authPayload.username,
        'ano_exercicio': loginPayload.anoExercicio,
        'cod_setor': authPayload.codSetor,
        'id_setor': authPayload.idSetor,
        'cod_orgao': authPayload.codOrgao,
        'cod_unidade': authPayload.codUnidade,
        'cod_departamento': authPayload.codDepartamento,
        'nom_setor': authPayload.nomSetor,
        'expiry': expiry.toIso8601String(),
        'ano_exercicio_setor': authPayload.anoExercicioSetor,
      });
    } on SocketException catch (e) {
      await conn?.disconnect();
      return res.responseError('Não foi possivel se conectar ao banco de dados',
          exception: UnableToConnectToDatabaseException(
            osError: e.osError != null ? '${e.osError}' : null,
            address: e.address?.host,
          ),
          statusCode: 403);
    } on UserNotFoundException {
      await conn?.disconnect();
      return res.responseError(StatusMessage.USER_NOT_FOUND,
          exception: UserNotFoundException, statusCode: 403);
    } catch (e, s) {
      await conn?.disconnect();
      // print('AuthController@authenticate $e $s');
      return res.responseError(StatusMessage.NOT_AUTHORIZED,
          statusCode: 401, exception: e, stackTrace: s);
    }
  }

  static void checkToken(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;
      if (!payload.containsKey('accessToken')) {
        throw AngelHttpException.badRequest(message: 'Faltando token.');
      }
      final token = payload['accessToken'].toString();
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, key);

      // print(decClaimSet);
      decClaimSet.validate(issuer: 'app.site.com');
      /* if (decClaimSet.jwtId != null) {
        print(decClaimSet.jwtId);
      }
      if (decClaimSet.containsKey('idsolicitante')) {
        final idsolicitante = decClaimSet['idsolicitante'];
        print(idsolicitante);
      }*/
      return res.responseJson(
          {'login': true, 'expiry': decClaimSet.expiry.toString()});
    } on JwtException catch (e) {
      //throw AngelHttpException.notAuthenticated(message: 'JwtException $e');
      //expired
      //SessionExpiredException
      if (e.toString().contains('expired')) {
        return res.responseError('Sessão expirada!', statusCode: 440);
      } else {
        //UnauthorizedException
        return res.responseError('Acesso não permitido!, Invalid JWT token',
            statusCode: 403);
      }
    } catch (e) {
      //throw AngelHttpException.notAuthenticated(message: '$e');
      return res.responseError('Acesso não permitido!, $e', statusCode: 401);
    }
  }

  ///
  static void checkTokenNew(RequestContext req, ResponseContext res) async {
    try {
      final token = req.queryParameters['t'];
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, key);

      // print(decClaimSet);
      decClaimSet.validate(issuer: 'app.site.com');
      /* if (decClaimSet.jwtId != null) {
        print(decClaimSet.jwtId);
      }
      if (decClaimSet.containsKey('idsolicitante')) {
        final idsolicitante = decClaimSet['idsolicitante'];
        print(idsolicitante);
      }*/
      return res.responseJson(
          {'login': true, 'expiry': decClaimSet.expiry.toString()});
    } on JwtException catch (e) {
      //throw AngelHttpException.notAuthenticated(message: 'JwtException $e');
      //expired
      //SessionExpiredException
      if (e.toString().contains('expired')) {
        return res.responseError('Sessão expirada!', statusCode: 440);
      } else {
        //UnauthorizedException
        return res.responseError('Acesso não permitido!, Invalid JWT token',
            statusCode: 403);
      }
    } catch (e) {
      //throw AngelHttpException.notAuthenticated(message: '$e');
      return res.responseError('Acesso não permitido!, $e', statusCode: 401);
    }
  }

  static void checkPermissao(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final codAcao = int.tryParse(req.queryParameters['a'].toString());
      final codFuncionalidade =
          int.tryParse(req.queryParameters['f'].toString());
      final codModulo = int.tryParse(req.queryParameters['m'].toString());
      final codGestao = int.tryParse(req.queryParameters['g'].toString());

      if (codAcao == null) {
        throw Exception('queryParameter codAcao não pode ser nulo');
      }
      

      final token = req.container!.make<AuthPayload>();
      conn = await req.dbConnect();

    
      final anoExercicio = '2023'; 
      final permissao = await PermissaoRepository(conn)
          .getByExercicioAndCgmAndAcao(codAcao, codFuncionalidade, codModulo,
              codGestao, anoExercicio, token.numCgm);

      await conn.disconnect();

      return res.responseSuccess(
          message:
              'Permissão concedida para exercício: ${permissao.anoExercicio} e ação: ${permissao.nomAcao} numCgm: ${token.numCgm}');
    } catch (e, s) {
      await conn?.disconnect();
      print('AuthController@checkPermissao $e $s');
      return res.responseError('Acesso não permitido!, $e', statusCode: 401);
    }
  }

  static void trocaSenha(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;

      final tokenData = req.container!.make<AuthPayload>();
      final senhaAtual = payload['senhaAtual'];
      final novaSenha = payload['novaSenha'];
      final username = payload['username'];

      /// o usario logado é admin ?
      final isAdmin = req.authToken.username.trim().toLowerCase() == 'admin';
      conn = await req.dbConnect();
      if (isAdmin == true) {
        await AuthRepository(conn).trocaSenhaQualqueUser(novaSenha, username);
      } else {
        await AuthRepository(conn)
            .trocaSenha(senhaAtual, novaSenha, tokenData.username);
      }
      await conn.disconnect();
      return res.responseSuccess();
    } catch (e, s) {
      await conn?.disconnect();
      print('AuthController@trocaSenha $e $s');
      return res.responseError('Error!',
          exception: e, statusCode: 400, stackTrace: s);
    }
  }
}
