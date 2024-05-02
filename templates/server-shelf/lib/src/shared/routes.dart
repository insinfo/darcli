import 'package:__projectName__/__projectName__.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void routes(Router app) {
  app.get('/', (Request request) {
    return Response.ok('app_backend');
  });
 
  app.mount(appConfig.basePath, grupoRoutes());
 
}
