import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

const candidatoPrivatesRoutes = [
  //candidatos web
  MyRoute(MyRoute.get, '/candidato-web/:id', CandidatoWebController.getById),
  MyRoute(MyRoute.put, '/candidato-web/:id', CandidatoWebController.update),
  //candidatos
  MyRoute(MyRoute.get, '/candidatos', CandidatoController.getAll),

  MyRoute(MyRoute.get, '/candidatos/:id', CandidatoController.getByIdCandidato),
  MyRoute(MyRoute.post, '/candidatos', CandidatoController.create),
  MyRoute(MyRoute.put, '/candidatos/:id', CandidatoController.update),
  MyRoute(MyRoute.delete, '/candidatos', CandidatoController.removeAll),
  //
  MyRoute(MyRoute.get, '/candidatos-web', CandidatoWebController.getAll),
];

const candidatoWebPublicRoutes = [
  MyRoute('post', '/candidatos-web', CandidatoWebController.create),
  MyRoute('get', '/candidatos-web/cpf/:cpf', CandidatoWebController.getByCpf),
];

const candidatoWebPrivateRoutes = [
  // lista candidatos encaminhados para um empregador
  MyRoute(MyRoute.get, '/candidatos/empregador/:idEmpregador',
      CandidatoController.getAllByEmpregador),
];
