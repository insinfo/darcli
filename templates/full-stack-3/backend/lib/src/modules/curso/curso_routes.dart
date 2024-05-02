import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const cursoPrivateRoutes = [
  MyRoute(MyRoute.get, '/cursos', CursoController.getAll),
  MyRoute(MyRoute.get, '/cursos/:id', CursoController.getById),
  MyRoute(MyRoute.post, '/cursos', CursoController.create),
  MyRoute(MyRoute.put, '/cursos/:id', CursoController.update),
  MyRoute(MyRoute.delete, '/cursos', CursoController.removeAll),
  MyRoute(MyRoute.post, '/cursos/import/xlsx', CursoController.importXlsx),
  MyRoute(MyRoute.delete, '/cursos/:id', CursoController.remove),
];

const cursoWebPublicRoutes = [
  MyRoute(MyRoute.get, '/cursos', CursoController.getAll),
];
