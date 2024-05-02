import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/extra/controllers/extra_controller.dart';

//registrar rotas aqui
Future<dynamic> extraPrivatesRoutes(Router app) async {}

Future<dynamic> extraPublicRoutes(Router app) async {
  app.get(
      '/extra/faixaetarias', (req, res) => ExtraController.getAllFaixaEtaria);
  app.get(
      '/extra/escolaridades', (req, res) => ExtraController.getAllEscolaridade);
  app.get('/extra/paises', (req, res) => ExtraController.getAllPaises);
  app.get('/extra/municipios', (req, res) => ExtraController.getAllMunicipios);
  app.get('/extra/estados', (req, res) => ExtraController.getAllEstados);
  app.get('/extra/tiposlogradouro',
      (req, res) => ExtraController.getAllTiposLogradouro);
  app.get('/extra/cargos', (req, res) => ExtraController.getAllCargos);
  app.get(
      '/extra/tipotelefones', (req, res) => ExtraController.getAllTipoTelefone);
}
