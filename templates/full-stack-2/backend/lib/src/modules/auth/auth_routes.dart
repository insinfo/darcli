import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/auth/controllers/auth_controller.dart';

//registrar rotas aqui
Future<dynamic> authPrivatesRoutes(Router app) async {
  //app.get('/solicitacoes', (req, res) => SolicitacaoController.getAll);
}

Future<dynamic> authPublicRoutes(Router router) async {
  router.post(
      '/auth/site/login', (req, res) => AuthController.authenticateSite);
  router.post('/auth/site/check', (req, res) => AuthController.checkToken);
  router.post('/reset/pass', (req, res) => AuthController.resetaSenhaSite);

  router.post('/change/pass', (req, res) => AuthController.changeSenhaSite);
}
