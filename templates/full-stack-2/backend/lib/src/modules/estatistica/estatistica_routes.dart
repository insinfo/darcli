import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/estatistica/controllers/estatistica_controller.dart';

//registrar rotas aqui
Future<dynamic> estatisticaPrivatesRoutes(Router app) async {}

Future<dynamic> estatisticaPublicRoutes(Router app) async {
  //app.get( '/public/facs', (req, res) => FacsController.getAllProcedimentoForSite);

  app.get('/estatisticas/solicitacoes/ano',
      (req, res) => EstatisticaController.solicitacoesPorAno);
}
