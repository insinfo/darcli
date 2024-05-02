import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/db/db_connect.dart';
import 'package:esic_backend/src/modules/auth/repositories/auth_repository.dart';
import 'package:esic_backend/src/modules/solicitante/repositories/solicitante_repository.dart';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_backend/src/shared/services/envia_email_service.dart';
import 'package:esic_backend/src/shared/utils/utils.dart';

import 'package:esic_core/esic_core.dart';

import 'package:esic_backend/src/shared/extensions/response_context_extensions.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AuthController {
  static const key = '7Fsxc2A865V67';

  static Future<dynamic> authenticateSite(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var loginPayload = LoginPayload.fromMap(req.bodyAsMap);
      var solicitante =
          await AuthRepository(esicDb).authenticateSite(loginPayload);

      const int expirationSec = 32400; //32400 segundo = 9 horas
      //const expiresInDays = 365 * 3;
      final expiry = DateTime.now().add(const Duration(seconds: expirationSec));
      final claimSet = JwtClaim(
        //subject: 'kleak',
        issuer: 'app.site.com',
        issuedAt: DateTime.now(), //Emitido em timestamp de geracao do token
        notBefore: DateTime.now().subtract(
            const Duration(milliseconds: 1)), // token nao é valido Antes de
    
        otherClaims: {
          'data': <String, dynamic>{
            'cpfPessoa': solicitante.cpfCnpj,
            'idPessoa': solicitante.id,
            'idSistema': -1,
            'loginName': loginPayload.login,
          }
        },
        expiry: expiry,
        maxAge: const Duration(seconds: expirationSec),
      );
      final String token = issueJwtHS256(claimSet, key);
      return res.responseJson({
        'accessToken': token,
        'cpfPessoa': solicitante.cpfCnpj,
        'idPessoa': solicitante.id,
        'idSistema': -1,
        'loginName': loginPayload.login,
      });
    } on UserNotActivatedException {
      return res.responseError(StatusMessage.USER_NOT_ACTIVATED,
          statusCode: 403);
    } catch (e, s) {
      print('AuthController@authenticateSite $e $s');
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
      return res.responseJson({'login': true});
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

  /// reseta senha para usuario do site
  static void resetaSenhaSite(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final cpfcnpj = req.bodyAsMap['cpfcnpj'];
      final repository = SolicitanteRepository(esicDb);
      final solicitante = await repository.getByCpfOrCnpj(cpfcnpj);
      //se ja tiver confirmado o cadastro reseta senha no banco e envia o email
      if (solicitante.isConfirmado) {
        var senha = Utils.stringToMd5(solicitante.cpfCnpj).substring(0, 8);
        await repository.updateSenha(senha, solicitante.id);
        final appLink = req.container!.make<AppConfig>().app_link_front;
        //envia e-mail
        final emailService = EnviaEmailService();
        emailService.assunto =
            'office de city - Redefinição de Senha';
        emailService.html = """Caro(a) ${solicitante.nome},\r\n
						   Foi solicitado redefini&ccedil;&atilde;o de senha de acesso ao sistema do E-SIC. Para acessar o sistema entre no endere&ccedil;o $appLink <br>
						   Dados de acesso: <br>
						   Login: $cpfcnpj<br>
						   Senha: $senha""";
        emailService.paraEmail = solicitante.email;
        await emailService.envia();
      }
      //caso nao tenha confirmado, reenvia email de confirmação
      else {
        final app_link_back = req.container!.make<AppConfig>().app_link_back;
        final emailService = EnviaEmailService();
        emailService.assunto =
            'office de city - Confirme seu cadastro no E-SIC';
        emailService.html =
            """Prezado(a) ${solicitante.nome},<br> <br>                                        
             Voc&ecirc; se cadastrou no sistema E-SIC. Para confirmar seu cadastro, favor acesse o seguinte endere&ccedil;o: <br/><br>
             ${app_link_back}/confirmacao/?k=${Utils.toMd5String(solicitante.id)}<br><br>                                            
             Mensagem automatica do E-SIC""";
        emailService.paraEmail = solicitante.email;
        await emailService.envia();
      }
      return res.responseJson(solicitante.toMap());
    } on UserNotFoundException {
      return res.responseError('Não existe cadastro para o CPF/CNPJ informado.',
          statusCode: 400);
    } catch (e) {
      throw AngelHttpException.badRequest(message: '$e');
    }
  }

  static void changeSenhaSite(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final cpfcnpj = req.bodyAsMap['cpfcnpj'];
      final senhaAtual = req.bodyAsMap['senhaAtual'];
      final novaAtual = req.bodyAsMap['novaAtual'];

      final repository = SolicitanteRepository(esicDb);
      final solicitante =
          await repository.getByCpfOrCnpjAndSenha(cpfcnpj, senhaAtual);

      await repository.updateSenha(novaAtual, solicitante.id);
      //final appLink = req.container!.make<AppConfig>().app_link_front;
      //envia e-mail
      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - Modificação de Senha';
      emailService.html = """Caro(a) ${solicitante.nome},\r\n
						   Foi solicitado a troca de senha de acesso ao sistema do E-SIC.<br>
						   Dados de acesso: <br>
						   Login: $cpfcnpj<br>
						   Senha: $novaAtual""";
      emailService.paraEmail = solicitante.email;
      await emailService.envia();

      return res.responseJson(solicitante.toMap());
    } on UserNotFoundException {
      return res.responseError('Não existe cadastro para o CPF/CNPJ informado.',
          statusCode: 400);
    } catch (e) {
      throw AngelHttpException.badRequest(message: '$e');
    }
  }
}
