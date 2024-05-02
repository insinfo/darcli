import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const tipoConhecimentoWebPublicRoutes = [
  MyRoute('get', '/tipos-conhecimento', TipoConhecimentoController.getAll),
];

const tipoConhecimentoPrivateRoutes = [
  MyRoute('get', '/tipos-conhecimento', TipoConhecimentoController.getAll),
  MyRoute('get', '/tipos-conhecimento/:id', TipoConhecimentoController.getById),
  MyRoute('post', '/tipos-conhecimento', TipoConhecimentoController.create),
  MyRoute('put', '/tipos-conhecimento/:id', TipoConhecimentoController.update),
  MyRoute(
      'delete', '/tipos-conhecimento', TipoConhecimentoController.removeAll),
];
