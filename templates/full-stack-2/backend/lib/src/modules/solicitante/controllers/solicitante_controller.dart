import 'package:angel3_framework/angel3_framework.dart';

import 'package:esic_backend/src/db/db_connect.dart';
import 'package:esic_backend/src/modules/solicitante/repositories/solicitante_repository.dart';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_backend/src/shared/services/envia_email_service.dart';
import 'package:esic_backend/src/shared/utils/utils.dart';

import 'package:esic_core/esic_core.dart';
import 'package:esic_backend/src/shared/extensions/request_context_extensions.dart';
import 'package:esic_backend/src/shared/extensions/response_context_extensions.dart';

class SolicitanteController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await SolicitanteRepository(esicDb).getAllAsMap(filtros: filtros);

      return res.responsePage(page);
    } catch (e, s) {
      print('SolicitanteController@getAll $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    try {
      var item =
          await SolicitanteRepository(esicDb).getByIdAsMap(req.getParamId()!);
      return res.responseJson(item);
    } catch (e, s) {
      print('SolicitanteController@getById $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getByIdToken(
      RequestContext req, ResponseContext res) async {
    try {
      final token = req.container!.make<AuthTokenJubarte>();
      var item =
          await SolicitanteRepository(esicDb).getByIdAsMap(token.idPessoa);
      return res.responseJson(item);
    } catch (e, s) {
      print('SolicitanteController@getByIdToken $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> insert(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var solicitante = Solicitante.fromMap(req.bodyAsMap);
      solicitante.cpfCnpj =
          solicitante.cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '');
      solicitante.cep = solicitante.cep.replaceAll(RegExp(r'[^0-9]'), '');
      solicitante.chave = Utils.stringToMd5(solicitante.chave);

      final solicitanteRepository = SolicitanteRepository(esicDb);

      var isCadastrado =
          await solicitanteRepository.userExistByCpfOrCnpj(solicitante.cpfCnpj);
      if (isCadastrado) {
        return res.responseError('Usuário já está cadastrado!',
            statusCode: 400);
      }

      //grava no banco
      final idSolicitante = await solicitanteRepository.insert(solicitante);

      //envia email
      final app_link_back = req.container!.make<AppConfig>().app_link_back;

      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - Confirme seu cadastro no E-SIC';
      emailService.html =
          """Prezado(a) ${solicitante.nome},<br> <br>                                        
             Voc&ecirc; se cadastrou no sistema E-SIC. Para confirmar seu cadastro, favor acesse o seguinte endere&ccedil;o: <br/><br>
             ${app_link_back}/confirmacao/?k=${Utils.toMd5String(idSolicitante)}<br><br>                                            
             Mensagem automatica do E-SIC""";
      emailService.paraEmail = solicitante.email;
      await emailService.envia();

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitanteController@insert $e $s');
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> confirmaCadastro(
      RequestContext req, ResponseContext res) async {
    try {
      final idSolicitanteMd5 = req.queryParameters['k'];
      var solicitante = await SolicitanteRepository(esicDb)
          .confirmaCadastro(idSolicitanteMd5);
      final appLink = req.container!.make<AppConfig>().app_link_front;
      final html =
          '''
<!DOCTYPE html>
<html>
<head>
  <title>E-SIC</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  
  <link rel="icon" type="image/png" href="favicon.png"> 
</head>
<body style="background-color: #fff;align-items: center;font-size: 1.2rem;padding-top: 50px;">
 <p  style="text-align: center;"> 
  Prezado(a) ${solicitante.nome} <br> <br>
  Seu cadastro no E-Sic foi confirmado com sucesso. <br>
  Link de acesso: <a href="$appLink">$appLink</a><br>
  Usu&aacute;rio: ${solicitante.cpfCnpj}<br><br>
 **A senha de acesso &eacute; aquela informada no cadastro. <br>
 Caso n&atilde;o se lembre, solicite o envio de uma nova senha pelo 
 link "Esqueci a senha" no formul&aacute;rio de login do sistema.
 </p> 
</body>
</html>
''';

      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - Cadastro realizado com sucesso!';
      emailService.html = html;
      emailService.paraEmail = solicitante.email;
      await emailService.envia();

      res.responseHtml(html);
    } catch (e, s) {
      print('SolicitanteController@confirmaCadastro $e $s');
      return res.responseErrorHtml('$e');
    }
  }

  /*static Future<dynamic> insertWithAnexos(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();

      var data = await req.getDataFieldFromFormData();
      var fac = Fac.fromMap(data);

      //final isColaborador = await req.isColaborador();

      //obtem o id do usuario logado

      fac.idPessoa = req.authToken.idPessoa;

      await FacsRepository(esicDb).insertWithAnexos(fac);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> updateWithAnexos(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();

      var data = await req.getDataFieldFromFormData();
      var fac = Fac.fromMap(data);

      //final idSecretaria = await req.getIdSecretaria();
      //final isColaborador = await req.isColaborador();

      //obtem o id do usuario logado
      //fac.idSecretaria = idSecretaria;
      //fac.idPessoa = req.authToken.idPessoa;

      await FacsRepository(esicDb).updateWithAnexos(fac);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }*/

  static Future<dynamic> update(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var solicitante = Solicitante.fromMap(req.bodyAsMap);
      solicitante.cpfCnpj =
          solicitante.cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '');
      await SolicitanteRepository(esicDb).update(solicitante);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitanteController@update $e $s');
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> delete(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var solicitante = Solicitante.fromMap(req.bodyAsMap);

      await SolicitanteRepository(esicDb).delete(solicitante);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> deleteAll(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var items = req.bodyAsList!.map((e) => Solicitante.fromMap(e)).toList();
      await SolicitanteRepository(esicDb).deleteAll(items);

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      return res.responseError(StatusMessage.ERROR_DELETING_DATA,
          exception: e, stackTrace: s);
    }
  }
}
