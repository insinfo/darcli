import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const vagaBeneficioPrivateRoutes = [
  // MyRoute(MyRoute.get, '/beneficios', BeneficioController.getAll),
  // MyRoute(MyRoute.get, '/beneficios/:id', BeneficioController.getById),
  // MyRoute(MyRoute.post, '/beneficios', BeneficioController.create),
  // MyRoute(MyRoute.put, '/beneficios/:id', BeneficioController.update),
  // MyRoute(MyRoute.delete, '/beneficios', BeneficioController.removeAll),
  // MyRoute(MyRoute.delete, '/beneficios/:id', BeneficioController.remove),
];

const vagaBeneficioWebPublicRoutes = [
  MyRoute(MyRoute.get, '/beneficios', BeneficioController.getAll),
];
