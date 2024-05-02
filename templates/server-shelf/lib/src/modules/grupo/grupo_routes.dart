import 'package:rava_backend/rava_backend.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Handler grupoRoutes() {
  final router = Router();

  router.get('/grupos', GrupoController.all);
  router.get('/grupos/<id>', GrupoController.getByNumero);
  router.post('/grupos', GrupoController.insert);
  router.put('/grupos/<id>', GrupoController.update);
  router.delete('/grupos', GrupoController.deleteAll);
  //grp1.DELETE("book/:id", Controllers.DeleteBook)

  // router.post(
  //     '/articles',
  //     Pipeline()
  //         .addMiddleware(authProvider.requireAuth())
  //         .addHandler(_createArticle));

  return router;
}
