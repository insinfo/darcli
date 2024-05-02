import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/solicitante/controllers/solicitante_controller.dart';

//registrar rotas aqui
Future<dynamic> solicitantePrivatesRoutes(Router app) async {
  app.get('/solicitantes', (req, res) => SolicitanteController.getAll);
  app.get('/solicitantes/:id', (req, res) => SolicitanteController.getById);
  app.get('/solicitantes/by/token',
      (req, res) => SolicitanteController.getByIdToken);

  app.put('/solicitantes/:id', (req, res) => SolicitanteController.update);
  app.delete('/solicitantes/:id', (req, res) => SolicitanteController.delete);
  app.delete(
      '/solicitantes/all/', (req, res) => SolicitanteController.deleteAll);
}

Future<dynamic> solicitantePublicRoutes(Router app) async {
  app.post('/solicitantes', (req, res) => SolicitanteController.insert);
  //app.get( '/public/facs', (req, res) => FacsController.getAllProcedimentoForSite);
}
