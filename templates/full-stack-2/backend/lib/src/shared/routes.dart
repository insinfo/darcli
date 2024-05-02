import 'dart:convert';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/modules/auth/auth_routes.dart';
import 'package:esic_backend/src/modules/estatistica/estatistica_routes.dart';
import 'package:esic_backend/src/modules/extra/extra_routes.dart';
import 'package:esic_backend/src/modules/solicitacao/solicitacao_routes.dart';
import 'package:esic_backend/src/modules/solicitante/controllers/solicitante_controller.dart';
import 'package:esic_backend/src/modules/solicitante/solicitante_routes.dart';
import 'package:esic_backend/src/modules/usuario/usuario_routes.dart';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_backend/src/shared/middleware/auth_middleware.dart';

import 'package:file/file.dart' as file;
import 'package:angel3_static/angel3_static.dart' as static_file_server;

AngelConfigurer configureRoutes(file.FileSystem fileSystem) {
  return (Angel app) async {
    app.get('/', (req, res) => res.write('esic_backend'));
    app.get(
        '/confirmacao', (req, res) => SolicitanteController.confirmaCadastro);
    app.group(AppConfig.inst().basePath, (router) async {
      await solicitantePublicRoutes(router);
      //await solicitacaoPublicRoutes(router);
      await authPublicRoutes(router);
      await extraPublicRoutes(router);
      await extraPublicRoutes(router);
      await estatisticaPublicRoutes(router);
      //  await usuarioPublicRoutes(router);
    });

    app.chain([AuthMiddleware().handleRequest]).group(AppConfig.inst().basePath,
        (router) async {
      await solicitantePrivatesRoutes(router);
      await solicitacaoPrivatesRoutes(router);
      //await estatisticaPrivatesRoutes(router);
      await usuarioPrivatesRoutes(router);
    });

    if (!app.environment.isProduction) {
      var vDir = static_file_server.VirtualDirectory(
        app,
        fileSystem,
        source: fileSystem.directory('web'),
      );
      app.fallback(vDir.handleRequest);
    }

    app.fallback((req, res) {
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.statusCode = 404;
      return res.write(jsonEncode({
        'message': 'Rota não existe',
        'exception': 'Rota não existe',
        'stackTrace': ''
      }));
    });

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
