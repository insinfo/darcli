import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_backend/src/shared/utils/route_item.dart';

//registrar rotas do modulo administracao aqui
const administracaoPrivateRoutes = [
  RouteItem('get', '/administracao/paises', PaisController.all),
  RouteItem('get', '/administracao/ufs', UnidadeFederativaController.all),
  RouteItem('get', '/administracao/municipios', MunicipioController.all),

RouteItem('get', '/administracao/modulos', ModuloController.all),
RouteItem('post', '/administracao/modulos', ModuloController.insert),
RouteItem('put', '/administracao/modulos', ModuloController.update),
//RouteItem('delete', '/administracao/modulos', ModuloController.deleteAll),

  RouteItem('get', '/administracao/funcionalidades', FuncionalidadeController.all),
  RouteItem('post', '/administracao/funcionalidades', FuncionalidadeController.insert),
  RouteItem('put', '/administracao/funcionalidades', FuncionalidadeController.update),
  //RouteItem('delete', '/administracao/funcionalidades', FuncionalidadeController.deleteAll),

  RouteItem('get', '/administracao/acoes', AcaoController.all),
  RouteItem('post', '/administracao/acoes', AcaoController.insert),
  RouteItem('put', '/administracao/acoes', AcaoController.update),
  //RouteItem('delete', '/administracao/acoes', AcaoController.deleteAll),

  RouteItem('get', '/administracao/permissoes/:numCgm/:anoExercicio',
      PermissaoController.modsFuncsAcoesPermissoesOfUser),
  RouteItem('put', '/administracao/permissoes/:numCgm/:anoExercicio',
      PermissaoController.definirPermissao),
  RouteItem('get', '/administracao/escolaridades', EscolaridadeController.all),
  RouteItem(
      'get', '/administracao/tiposlogradouro', TipoLogradouroController.all),

  RouteItem('get', '/administracao/orgaos', OrgaoController.all),
  RouteItem('post', '/administracao/orgaos', OrgaoController.insert),
  RouteItem('put', '/administracao/orgaos', OrgaoController.update),
  RouteItem('delete', '/administracao/orgaos', OrgaoController.deleteAll),

  RouteItem('get', '/administracao/unidades', UnidadeController.all),
  RouteItem('post', '/administracao/unidades', UnidadeController.insert),
  RouteItem('put', '/administracao/unidades', UnidadeController.update),
  RouteItem('delete', '/administracao/unidades', UnidadeController.deleteAll),

  RouteItem('get', '/administracao/departamentos', DepartamentoController.all),
  RouteItem(
      'post', '/administracao/departamentos', DepartamentoController.insert),
  RouteItem(
      'put', '/administracao/departamentos', DepartamentoController.update),
  RouteItem('delete', '/administracao/departamentos',
      DepartamentoController.deleteAll),

  RouteItem('get', '/administracao/setores', SetorController.all),
  RouteItem('post', '/administracao/setores', SetorController.insert),
  RouteItem('put', '/administracao/setores', SetorController.update),
  RouteItem('delete', '/administracao/setores', SetorController.deleteAll),

  RouteItem('get', '/administracao/gestao', GestaoController.all),
  // usuario
  RouteItem('get', '/administracao/usuarios', UsuarioController.all),
  RouteItem(
      'get', '/administracao/usuarios/:numcgm', UsuarioController.byNumCgm),
  RouteItem('post', '/administracao/usuarios', UsuarioController.insert),
  RouteItem('put', '/administracao/usuarios', UsuarioController.update),

  RouteItem('get', '/administracao/auditorias', AuditoriaController.all),
  RouteItem('post', '/administracao/auditorias', AuditoriaController.create),
  RouteItem('get', '/administracao/configuracao', ConfiguracaoController.all),
  RouteItem('get', '/administracao/configuracao/by/filtro',
      ConfiguracaoController.getBy),



  // menu do sistema
  RouteItem('get', '/administracao/menu/:cgm', MenuController.getMenu),
  // lista a hierarquia de Organograma como um arvore
  RouteItem('get', '/administracao/organograma/hierarquia',
      OrganogramaController.getHierarquia),

 
];
