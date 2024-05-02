
import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const conhecimentoExtraPrivateRoutes = [
  MyRoute('get', '/conhecimentos-extra', ConhecimentoExtraController.getAll),
  MyRoute(
      'get', '/conhecimentos-extra/:id', ConhecimentoExtraController.getById),
  MyRoute('post', '/conhecimentos-extra', ConhecimentoExtraController.create),
  MyRoute(
      'put', '/conhecimentos-extra/:id', ConhecimentoExtraController.update),
  MyRoute(
      'delete', '/conhecimentos-extra', ConhecimentoExtraController.removeAll),
];

const conhecimentoExtraWebPublicRoutes = [
  MyRoute('get', '/conhecimentos-extra', ConhecimentoExtraController.getAll),
];
