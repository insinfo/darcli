import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/services/envia_email_service.dart';

class UsuarioWebController {
  // static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
  //   try {
  //     final repo = req.container!.make<UsuarioRepository>();
  //     final data = await repo.getAll(filtros: req.filtros);

  //     return res.responseDataFrame(data);
  //   } catch (e, s) {
  //     print('UsuarioWebController@getAll $e $s');
  //     return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
  //         exception: e, stackTrace: s);
  //   }
  // }

  // static Future<dynamic> getById(
  //     RequestContext req, ResponseContext res) async {
  //   final id = int.parse(req.params['id'].toString());

  //   try {
  //     final repo = req.container!.make<UsuarioWebRepository>();
  //     final data = await repo.getByIdAsMap(id);
  //     return res.responseJson(data);
  //   } catch (e, s) {
  //     print('UsuarioWebController@getById $e $s');
  //     return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
  //         exception: e, stackTrace: s);
  //   }
  // }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<UsuarioWebRepository>();
      final user = UsuarioWeb.fromMap(await req.dataAsMap());
      final isExist = await repo.isExistByLogin(user.login);
      if (isExist) {
        return res.responseError(
          user.isCandidato
              ? 'Este candidato já está cadastrado!'
              : 'Este empregador já está cadastrado!',
        );
      }

      await repo.create(user);

      //envia email
      final app_link_back = req.container!.make<AppConfig>().appLinkBack;

      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - Confirme seu cadastro no SIBEM';
      emailService.html =
          """Prezado(a) ${user.nome},<br> <br>                                        
             Voc&ecirc; se cadastrou no sistema SIBEM. Para confirmar seu cadastro, favor acesse o seguinte endere&ccedil;o: <br/><br>
             ${app_link_back}/web/api/v1/usuarios-web/confirmacao/?k=${Criptografia.toMd5String(user.id)}<br><br>                                            
             Mensagem automatica do SIBEM""";
      emailService.paraEmail = user.email;
      await emailService.envia();

      res.responseSuccess();
    } catch (e, s) {
      print('UsuarioWebController@create $e $s');
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> confirmaCadastro(
      RequestContext req, ResponseContext res) async {
    try {
      final idSolicitanteMd5 = req.queryParameters['k'];
      final repo = req.container!.make<UsuarioWebRepository>();
      var user = await repo.confirmaCadastro(idSolicitanteMd5);
      //final appLink = req.container!.make<AppConfig>().app_link_front;
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <title>SIBEM</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  
  <link rel="icon" type="image/png" href="favicon.png"> 
</head>
<body style="background-color: #fff;align-items: center;font-size: 1.2rem;padding-top: 50px;">
 <p  style="text-align: center;"> 
  Prezado(a) ${user.nome} <br> <br>
  Seu cadastro no SIBEM foi confirmado com sucesso. <br>  
  Usu&aacute;rio: ${user.login}<br><br>
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
      emailService.paraEmail = user.email;
      await emailService.envia();

      res.responseHtml(html);
    } catch (e, s) {
      print('SolicitanteController@confirmaCadastro $e $s');
      return res.responseErrorHtml('$e');
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<UsuarioWebRepository>();
      await repo.update(UsuarioWeb.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('UsuarioWebController@update $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future removeAll(RequestContext req, ResponseContext res) async {
    try {
      final data = await req.dataAsList();
      // final id = int.tryParse(req.params['id'].toString());
      // if (id == null) {
      //   throw Exception('O parametro id tem que ser um número inteiro valido');
      // }
      final repo = req.container!.make<UsuarioWebRepository>();
      final items = data.map((e) => UsuarioWeb.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('UsuarioWebController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
