import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const empregadorPrivatesRoutes = [
  // empregadores
  MyRoute('get', '/empregadores', EmpregadorController.getAll),
  MyRoute('get', '/empregadores/:id', EmpregadorController.getById),
  MyRoute('post', '/empregadores', EmpregadorController.create),
  MyRoute('put', '/empregadores/:id', EmpregadorController.update),
  MyRoute('delete', '/empregadores', EmpregadorController.removeAll),
  // empregadores web
  MyRoute('get', '/empregadores-web', EmpregadorWebController.getAll),
  MyRoute('get', '/empregadores-web/:id', EmpregadorWebController.getById),
  MyRoute('post', '/empregadores-web', EmpregadorWebController.create),
  MyRoute('put', '/empregadores-web/:id', EmpregadorWebController.update),
  MyRoute('patch', '/empregadores-web/status/:id',
      EmpregadorWebController.updateStatus),

  MyRoute('delete', '/empregadores-web', EmpregadorWebController.removeAll),
];

const empregadorWebPublicRoutes = [
  MyRoute('post', '/empregadores-web', EmpregadorWebController.create),
  MyRoute('get', '/empregadores-web/cpfOrCnpj/:cpfOrCnpj',
      EmpregadorWebController.getByCpfOrCnpj),
];
