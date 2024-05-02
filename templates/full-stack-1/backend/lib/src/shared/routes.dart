import 'package:angel3_framework/angel3_framework.dart';
import 'package:file/file.dart' as file;
import 'package:angel3_static/angel3_static.dart' as static_file_server;
import 'package:new_sali_backend/new_sali_backend.dart';

import 'package:new_sali_backend/src/shared/dependencies/custom_router/router.dart';
import 'package:new_sali_backend/src/shared/dependencies/custom_router/router_entry.dart';
import 'package:new_sali_backend/src/shared/middleware/auth_middleware.dart';
import 'utils/route_item.dart';

const List<RouteItem> rotasPublicas = [

  ...authPublicRoutes
];

const List<RouteItem> rotasPrivadas = [
  ...administracaoPrivateRoutes,

  ...authPrivatesRoutes,

  ...estatisticaPrivatesRoutes,
  
];

AngelConfigurer configureRoutes(file.FileSystem fileSystem) {
  return (Angel app) {
    final basePath = '/api/v1';

    // app.get('/', (req, res) => res.write('app'));
    // for (final rota in rotasPublicas) {
    //   app.addRoute(rota.methodUpper(), basePath + rota.path,
    //       (req, res) => rota.handler as RequestHandler);
    // }
    // for (final rota in rotasPrivadas) {
    //   app.addRoute(rota.methodUpper(), basePath + rota.path,
    //       (req, res) => rota.handler as RequestHandler,
    //       middleware: [AuthMiddleware.handleRequestAngel]);
    // }
    // app.fallback((req, res) {
    //   res.headers['Content-Type'] = 'application/json;charset=utf-8';
    //   res.statusCode = 404;
    //   return res.write(jsonEncode({
    //     'message': 'Rota não existe',
    //     'exception': 'Rota não existe',
    //     'stackTrace': ''
    //   }));
    // });

    final router = CustomRouter();
    router.get('/', (req, res) => res.write('app'));
    for (final rota in rotasPublicas) {
      router.add(rota.methodUpper(), basePath + rota.pathAsShelf(),
          rota.handler as CustomHandler);
    }
    for (final rota in rotasPrivadas) {
      router.add(rota.methodUpper(), basePath + rota.pathAsShelf(),
          rota.handler as CustomHandler,
          middleware: AuthMiddleware.handleRequest);
    }
    
    if (!app.environment.isProduction) {
      print('init VirtualDirectory');
      var vDir = static_file_server.VirtualDirectory(
        app,
        fileSystem,
        source: fileSystem.directory('storage'),
        allowDirectoryListing: true,
      );
      app.all('*', vDir.handleRequest);
    }

    app.all('*', router.call);

    var oldErrorHandler = app.errorHandler;
    app.errorHandler = (e, req, res) async {
      if (req.accepts('text/html', strict: true)) {
        if (e.statusCode == 404 && req.accepts('text/html', strict: true)) {
          await res
              .render('error', {'message': 'Arquivo não existe ${req.uri}.'});
        } else {
          await res.render('error', {'message': e.message});
        }
      } else {
        return await oldErrorHandler(e, req, res);
      }
    };
  };
}
