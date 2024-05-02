import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const cargoPrivateRoutes = [
  MyRoute(MyRoute.get, '/cargos', CargoController.getAll),
  MyRoute(MyRoute.get, '/cargos/:id', CargoController.getById),
  MyRoute(MyRoute.post, '/cargos', CargoController.create),
  MyRoute(MyRoute.put, '/cargos/:id', CargoController.update),
  MyRoute(MyRoute.delete, '/cargos', CargoController.removeAll),
  MyRoute(MyRoute.post, '/cargos/import/xlsx', CargoController.importXlsx),
  MyRoute(MyRoute.delete, '/cargos/:id', CargoController.remove),
];

const cargoWebPublicRoutes = [
  MyRoute(MyRoute.get, '/cargos', CargoController.getAll),
];
