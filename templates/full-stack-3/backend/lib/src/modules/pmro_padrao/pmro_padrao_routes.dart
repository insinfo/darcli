import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const pmroPadraoPrivateRoutes = [
  // estados
  MyRoute('get', '/ufs', UfController.getAll),
  MyRoute('get', '/ufs/:id', UfController.getById),
  MyRoute('post', '/ufs', UfController.create),
  MyRoute('put', '/ufs/:id', UfController.update),
  // municipios
  MyRoute('get', '/municipios', MunicipioController.getAll),
  MyRoute('get', '/municipios/:id', MunicipioController.getById),
  MyRoute('get', '/municipios/uf/id/:idUf', MunicipioController.getAllByIdUf),
  MyRoute('get', '/municipios/uf/sigla/:siglaUf',
      MunicipioController.getAllBySiglaUf),
  MyRoute('post', '/municipios', MunicipioController.create),
  MyRoute('put', '/municipios/:id', MunicipioController.update),
  // escolaridades
  MyRoute('get', '/escolaridades', EscolaridadeController.getAll),
  MyRoute('get', '/escolaridades/:id', EscolaridadeController.getById),
  MyRoute('post', '/escolaridades', EscolaridadeController.create),
  MyRoute('put', '/escolaridades/:id', EscolaridadeController.update),
  MyRoute('delete', '/escolaridades', EscolaridadeController.removeAll),
  // tipos de deficiencia
  MyRoute('get', '/tipos-deficiencia', TipoDeficienciaController.getAll),
  MyRoute('get', '/tipos-deficiencia/:id', TipoDeficienciaController.getById),
  MyRoute('post', '/tipos-deficiencia', TipoDeficienciaController.create),
  MyRoute('put', '/tipos-deficiencia/:id', TipoDeficienciaController.update),
  MyRoute('delete', '/tipos-deficiencia', TipoDeficienciaController.removeAll),
];

const pmroPadraoWebPublicRoutes = [
  MyRoute('get', '/ufs', UfController.getAll),
  MyRoute('get', '/municipios/uf/id/:idUf', MunicipioController.getAllByIdUf),
  MyRoute('get', '/tipos-deficiencia', TipoDeficienciaController.getAll),
  MyRoute('get', '/escolaridades', EscolaridadeController.getAll),
];
