import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/solicitacao/controllers/solicitacao_controller.dart';

//registrar rotas aqui
Future<dynamic> solicitacaoPrivatesRoutes(Router app) async {
  app.get('/solicitacoes', (req, res) => SolicitacaoController.getAll);

  app.get('/solicitacoes/pessoa/',
      (req, res) => SolicitacaoController.getAllOfPessoa);

  app.get('/solicitacoes/:id', (req, res) => SolicitacaoController.getById);

  app.get('/solicitacoes/pessoa/:id',
      (req, res) => SolicitacaoController.getByIdOfPessoa);

  app.post('/solicitacoes', (req, res) => SolicitacaoController.insert);

  app.post(
      '/prorrogar/solicitacao', (req, res) => SolicitacaoController.prorrogar);
  app.post(
      '/responder/solicitacao', (req, res) => SolicitacaoController.responder);
  app.post('/receber/solicitacao', (req, res) => SolicitacaoController.receber);

  app.put('/solicitacoes/:id', (req, res) => SolicitacaoController.update);
  app.delete('/solicitacoes/:id', (req, res) => SolicitacaoController.delete);
  app.delete(
      '/solicitacoes/all/', (req, res) => SolicitacaoController.deleteAll);
}

Future<dynamic> solicitacaoPublicRoutes(Router app) async {
  //app.get( '/public/facs', (req, res) => FacsController.getAllProcedimentoForSite);
}
