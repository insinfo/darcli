import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

const auditoriaPrivateRoutes = [
  MyRoute('get', '/auditorias', AuditoriaController.getAll),
  MyRoute('get', '/auditorias/:id', AuditoriaController.getById),
  MyRoute('post', '/auditorias', AuditoriaController.create),
  MyRoute('put', '/auditorias/:id', AuditoriaController.update),
  MyRoute('delete', '/auditorias', AuditoriaController.removeAll),
];
