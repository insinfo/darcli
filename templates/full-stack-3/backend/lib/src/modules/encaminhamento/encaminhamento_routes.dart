import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const encaminhamentoWebPublicRoutes = [
  MyRoute('get', '/encaminhamentos', EncaminhamentoController.getAll),
];

const encaminhamentoPrivateRoutes = [
  MyRoute('get', '/encaminhamentos', EncaminhamentoController.getAll),
  MyRoute('get', '/encaminhamentos/:id', EncaminhamentoController.getById),
  MyRoute('post', '/encaminhamentos', EncaminhamentoController.create),
  MyRoute('put', '/encaminhamentos/:id', EncaminhamentoController.update),
  MyRoute('patch', '/encaminhamentos/status/:id',
      EncaminhamentoController.updateStatus),
  MyRoute('delete', '/encaminhamentos', EncaminhamentoController.removeAll),
  MyRoute('delete', '/encaminhamentos/:id', EncaminhamentoController.remove),
];

const encaminhamentoWebPrivateRoutes = [
  // lista encaminhados para um empregador
  MyRoute(MyRoute.get, '/encaminhamentos/empregador/:idEmpregador',
      EncaminhamentoController.getAllByEmpregadorForWeb),
  MyRoute('patch', '/encaminhamentos/status/:id',
      EncaminhamentoController.updateStatusForWeb),
];
