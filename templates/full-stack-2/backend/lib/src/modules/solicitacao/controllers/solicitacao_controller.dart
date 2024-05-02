import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/db/db_connect.dart';
import 'package:esic_backend/src/modules/solicitacao/repositories/solicitacao_repository.dart';
import 'package:esic_backend/src/modules/solicitante/repositories/solicitante_repository.dart';
import 'package:esic_backend/src/modules/usuario/repositories/usuario_repository.dart';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_backend/src/shared/services/envia_email_service.dart';

import 'package:esic_core/esic_core.dart';
import 'package:esic_backend/src/shared/extensions/request_context_extensions.dart';
import 'package:esic_backend/src/shared/extensions/response_context_extensions.dart';

class SolicitacaoController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await SolicitacaoRepository(esicDb).getAllAsMap(filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('SolicitacaoController@getAll $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllOfPessoa(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      final token = req.container!.make<AuthTokenJubarte>();
      //print(token.idPessoa);
      var page = await SolicitacaoRepository(esicDb)
          .getAllOfPessoa(token.idPessoa, filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('SolicitacaoController@getAllOfPessoa $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    try {
      var item = await SolicitacaoRepository(esicDb).getById(req.getParamId()!);
      return res.responseJson(item);
    } catch (e, s) {
      print('SolicitacaoController@getById $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getByIdOfPessoa(
      RequestContext req, ResponseContext res) async {
    try {
      final token = req.container!.make<AuthTokenJubarte>();
      var item = await SolicitacaoRepository(esicDb)
          .getByIdOfPessoa(token.idPessoa, req.getParamId()!);
      return res.responseJson(item);
    } catch (e, s) {
      print('SolicitacaoController@getByIdOfPessoa $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> insert(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();

      final appConfig = req.container!.make<AppConfig>();
      final token = req.container!.make<AuthTokenJubarte>();

      var solicitacao = Solicitacao.fromMap(req.bodyAsMap);
      solicitacao.dataSolicitacao = DateTime.now();
      solicitacao.idsolicitante = token.idPessoa;
      solicitacao.dataPrevisaoResposta =
          DateTime.now().add(Duration(days: appConfig.prazoResposta));

      await SolicitacaoRepository(esicDb).insert(solicitacao);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitacaoController@insert $e $s');
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }

  //Confirma recebimento da solicitação
  static Future<dynamic> receber(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();

      //final appConfig = req.container!.make<AppConfig>();
      final token = req.container!.make<AuthTokenJubarte>();
      var usuario = await UsuarioRepository(esicDb).getByCpf(token.cpfPessoa);

      var solicitacao = Solicitacao.fromMap(req.bodyAsMap);
      solicitacao.dataRecebimentoSolicitacao = DateTime.now();
      solicitacao.idUsuarioRecebimento = usuario.id;

      await SolicitacaoRepository(esicDb).receber(solicitacao);

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitacaoController@receber $e $s');
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> update(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var solicitacao = Solicitacao.fromMap(req.bodyAsMap);
      await SolicitacaoRepository(esicDb).update(solicitacao);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitacaoController@update $e $s');
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> delete(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var solicitante = Solicitacao.fromMap(req.bodyAsMap);
      await SolicitacaoRepository(esicDb).delete(solicitante);
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
      var items = req.bodyAsList!.map((e) => Solicitacao.fromMap(e)).toList();
      await SolicitacaoRepository(esicDb).deleteAll(items);

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      return res.responseError(StatusMessage.ERROR_DELETING_DATA,
          exception: e, stackTrace: s);
    }
  }

  /// prorrogação de solicitação
  static Future<dynamic> prorrogar(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();

      final token = req.container!.make<AuthTokenJubarte>();
      final appConfig = req.container!.make<AppConfig>();

      var solicitacao = Solicitacao.fromMap(req.bodyAsMap);

      var prazoresposta = 0;
      //se não for prorrogação de primeira instancia
      if (solicitacao.tipoSolicitacao!.instancia != "I") {
        prazoresposta = appConfig.qtdeProrrogacaoRecurso;
      } else {
        prazoresposta = appConfig.qtdProrrogacaoResposta;
      }

      var usuario = await UsuarioRepository(esicDb).getByCpf(token.cpfPessoa);

      solicitacao.idUsuarioProrrogacao = usuario.id;
      solicitacao.dataProrrogacao = DateTime.now();
      //solicitacao.motivoProrrogacao =
      solicitacao.dataPrevisaoResposta =
          solicitacao.dataPrevisaoResposta.add(Duration(days: prazoresposta));

      var repository = SolicitacaoRepository(esicDb);
      await repository.prorrogar(solicitacao);

      var solicitante = await SolicitanteRepository(esicDb)
          .getById(solicitacao.idsolicitante);

      //envia email de aviso de prorrogação ao solicitante
      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - A resposta a sua solicitação foi prorrogada';
      emailService.html = """Prezado(a) ${solicitante.nome},<br> <br>
O atendimento a sua solicita&ccedil;&atilde;o <b>${solicitacao.protocoloText}</b>
 foi prorrogado, data de previs&atilde;o de resposta: ${solicitacao.dataPrevisaoRespostaTextBr}. 
 <br>  Para mais informa&ccedil;&otilde;es acesse o sistema e-SIC - city.<br><br>
Mensagem Autom&aacute;tica do Sistema e-SIC - city.
        """;
      emailService.paraEmail = solicitante.email;
      await emailService.envia();

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitacaoController@prorrogar $e $s');
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> responder(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      // var anexos = <Anexo>[];
      // if (req.uploadedFiles != null) {
      //   for (UploadedFile file in req.uploadedFiles!) {
      //     var anexo = Anexo(
      //         idsolicitacao: 0,
      //         nome: 'teste.txt',
      //         datainclusao: DateTime.now(),
      //         idusuarioinclusao: 0,
      //         bytes: await file.readAsBytes(),
      //         type: 'plain/text',
      //         size: 0);

      //     anexos.add(anexo);
      //   }
      // }
      // anexos.forEach((a) => print(a.bytes));

      final token = req.container!.make<AuthTokenJubarte>();
      //final appConfig = req.container!.make<AppConfig>();

      var data = await req.getDataFieldFromFormData();
      var solicitacao = Solicitacao.fromMap(data);

      var usuario = await UsuarioRepository(esicDb).getByCpf(token.cpfPessoa);

      solicitacao.idUsuarioResposta = usuario.id;
      solicitacao.dataResposta = DateTime.now();
      solicitacao.idSecretariaResposta = usuario.idSecretaria;
      solicitacao.situacao = 'R';

      //mescla as referencias de arquivos ao model solicitacao
      if (req.uploadedFiles != null) {
        for (UploadedFile file in req.uploadedFiles!) {
          for (Anexo anexo in solicitacao.anexos) {
            if (file.filename == anexo.nome) {
              anexo.bytes = await file.readAsBytes();
              anexo.idusuarioinclusao = usuario.id;
            }
          }
        }
      }

      var solicitante = await SolicitanteRepository(esicDb)
          .getById(solicitacao.idsolicitante);

      var repository = SolicitacaoRepository(esicDb);
      await repository.responder(solicitacao);

      //envia email de aviso de reposta ao solicitante
      final emailService = EnviaEmailService();
      emailService.assunto =
          'office de city - Sua solicitação foi respondida';
      emailService.html = """Prezado(a) ${solicitante.nome},<br> <br>
Sua solicita&ccedil;&atilde;o <b>${solicitacao.protocoloText}</b> foi respondida
 <br>Para mais informa&ccedil;&otilde;es acesse o sistema e-SIC - city.<br><br>
Mensagem Autom&aacute;tica do Sistema e-SIC - city
        """;
      emailService.paraEmail = solicitante.email;
      await emailService.envia();

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('SolicitacaoController@responder $e $s');
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }
}
