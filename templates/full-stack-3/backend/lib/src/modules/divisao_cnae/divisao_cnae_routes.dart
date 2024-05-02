import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const divisaoCnaeWebPublicRoutes = [
  MyRoute('get', '/divisoes-cnae', DivisaoCnaeController.getAll),
];

const divisaoCnaePrivateRoutes = [
  MyRoute('get', '/divisoes-cnae', DivisaoCnaeController.getAll),
  MyRoute('get', '/divisoes-cnae/:id', DivisaoCnaeController.getById),
  MyRoute('post', '/divisoes-cnae', DivisaoCnaeController.create),
  MyRoute('put', '/divisoes-cnae/:id', DivisaoCnaeController.update),
  MyRoute('delete', '/divisoes-cnae', DivisaoCnaeController.removeAll),
];
