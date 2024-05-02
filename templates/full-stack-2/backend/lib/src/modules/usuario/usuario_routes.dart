import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/usuario/controllers/usuario_controller.dart';

//registrar rotas aqui
Future<dynamic> usuarioPrivatesRoutes(Router app) async {
  app.get('/usuarios', (req, res) => UsuarioController.getAll);
  app.get('/usuarios/:id', (req, res) => UsuarioController.getById);
  app.post('/usuarios', (req, res) => UsuarioController.insert);
  app.put('/usuarios/:id', (req, res) => UsuarioController.update);
  app.delete('/usuarios/:id', (req, res) => UsuarioController.delete);
  app.delete('/usuarios/all/', (req, res) => UsuarioController.deleteAll);
}

Future<dynamic> usuarioPublicRoutes(Router app) async {
  //app.get( '/public/facs', (req, res) => FacsController.getAllProcedimentoForSite);
}
