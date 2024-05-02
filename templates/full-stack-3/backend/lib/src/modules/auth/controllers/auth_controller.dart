import 'package:angel3_framework/angel3_framework.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/services/envia_email_service.dart';

class AuthController {
  static Future<dynamic> authenticateSite(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final loginPayload = LoginPayload.fromMap(req.bodyAsMap);

      final repo = req.container!.make<AuthRepository>();

      final user = await repo.authenticateSite(loginPayload);

      var jaCadastrado = false;
      int? idPessoa;

      CandidatoStatus? candidatoStatus;

      if (user.isCandidato) {
        final repoCandidato = req.container!.make<CandidatoRepository>();
        //verifica se quen esta logando é um candidato ja cadastrado previamente no banco de emprego fisicamente
        final isExistCandidato =
            await repoCandidato.isExisteByCpfAsMap(user.login);

        idPessoa =
            isExistCandidato != null ? isExistCandidato['idPessoa'] : null;

        if (isExistCandidato != null) {
          jaCadastrado = true;
          candidatoStatus =
              CandidatoStatus.fromString(isExistCandidato['status']);
          idPessoa = isExistCandidato['idPessoa'];
        }
      } else if (user.isEmpregador) {
        final repoEmpre = req.container!.make<EmpregadorRepository>();
        final isExistEmpregador = await repoEmpre.isExisteByCpfOrCnpjAsMap(
            user.login, user.tipoPessoa);
        jaCadastrado = isExistEmpregador != null;
        idPessoa =
            isExistEmpregador != null ? isExistEmpregador['idPessoa'] : null;
      }

      const int expirationSec = 32400; //32400 segundo = 9 horas

      final expiry = DateTime.now().add(const Duration(seconds: expirationSec));
      final claimSet = JwtClaim(
        //subject: 'kleak',
        issuer: 'app.site.com',
        issuedAt: DateTime.now(), //Emitido em timestamp de geracao do token
        notBefore: DateTime.now().subtract(
            const Duration(milliseconds: 1)), // token nao é valido Antes de
        otherClaims: {
          'data': <String, dynamic>{
            'idUsuario': user.id,
            'login': loginPayload.login,
            'nome': user.nome,
            'tipo': user.tipo,
            'isValidado': user.isValidado,
            'jaCadastrado': jaCadastrado,
            'idPessoa': idPessoa
          }
        },
        expiry: expiry,
        maxAge: const Duration(seconds: expirationSec),
      );
      final String token = issueJwtHS256(claimSet, AUTH_KEY);

      final authPlayload = AuthPayload(
        accessToken: token,
        idUsuario: user.id,
        login: loginPayload.login,
        nome: user.nome,
        tipo: user.tipo,
        isValidado: user.isValidado,
        expiry: expiry,
        email: user.email,
        jaCadastrado: jaCadastrado,
        idPessoa: idPessoa,
        candidatoStatus: candidatoStatus,
      );

      return res.responseJson(authPlayload.toJson());
    } on UserNotFoundException {
      return res.responseError(StatusMessage.USER_NOT_NOT_FOUND,
          statusCode: 404);
    } on UserNotActivatedException {
      return res.responseError(StatusMessage.USER_NOT_ACTIVATED,
          statusCode: 403);
    } catch (e, s) {
      //print('AuthController@authenticateSite $e $s');
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
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, AUTH_KEY);
      // print(decClaimSet);
      decClaimSet.validate(issuer: 'app.site.com');

      return res.responseJson({'login': true, 'expiry': decClaimSet.expiry});
    } on JwtException catch (e) {
      if (e.toString().contains('expired')) {
        return res.responseError('Sessão expirada!', statusCode: 440);
      } else {
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

      final login = req.bodyAsMap['login'] as String;

      final repo = req.container!.make<AuthRepository>();
      final usuario = await repo.getByLogin(login);

      //se ja tiver confirmado o cadastro reseta senha no banco e envia o email
      if (usuario.isConfirmado) {
        var senha = Criptografia.stringToMd5(usuario.login).substring(0, 8);
        await repo.updateSenha(senha, usuario.id);
        //final appLink = req.container!.make<AppConfig>().app_link_front;
        //envia e-mail
        final emailService = EnviaEmailService();
        emailService.assunto =
            'office de city - Redefinição de Senha';
        emailService.html = """Caro(a) ${usuario.nome},\r\n
						   Foi solicitado redefini&ccedil;&atilde;o de senha de acesso ao sistema do SIBEM.<br>
						   Dados de acesso: <br>
						   Login: $login<br>
						   Senha: $senha""";
        emailService.paraEmail = usuario.email;
        await emailService.envia();
      }
      //caso nao tenha confirmado, reenvia email de confirmação
      else {
        final appLinkBack = req.container!.make<AppConfig>().appLinkBack;
        final emailService = EnviaEmailService();
        emailService.assunto =
            'office de city - Confirme seu cadastro no SIBEM';
        emailService.html =
            """Prezado(a) ${usuario.nome},<br> <br>                                        
             Voc&ecirc; se cadastrou no sistema SIBEM. Para confirmar seu cadastro, favor acesse o seguinte endere&ccedil;o: <br/><br>
             ${appLinkBack}/confirmacao/?k=${Criptografia.toMd5String(usuario.id)}<br><br>                                            
             Mensagem automatica do SIBEM""";
        emailService.paraEmail = usuario.email;
        await emailService.envia();
      }
      return res.responseJson(usuario.toMap());
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
      final login = req.sibemToken.login; //req.bodyAsMap['login'];
      final senhaAtual = req.bodyAsMap['senhaAtual'];
      final novaSenha = req.bodyAsMap['novaSenha'];
      print('changeSenhaSite login $login');

      final repo = req.container!.make<AuthRepository>();
      final user = await repo.getByLoginAndSenha(login, senhaAtual);

      await repo.updateSenha(novaSenha, user.id);

      //envia e-mail
      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - Modificação de Senha';
      emailService.html = """Caro(a) ${user.nome},\r\n
						   Foi solicitado a troca de senha de acesso ao sistema do SIBEM.<br>
						   Dados de acesso: <br>
						   Login: $login<br>
						   Senha: $novaSenha""";
      emailService.paraEmail = user.email;
      await emailService.envia();

      return res.responseJson(user.toMap());
    } on UserNotFoundException {
      return res.responseError('Não existe cadastro para o CPF/CNPJ informado.',
          statusCode: 400);
    } catch (e, s) {
      throw AngelHttpException.badRequest(message: '$e $s');
    }
  }
}
