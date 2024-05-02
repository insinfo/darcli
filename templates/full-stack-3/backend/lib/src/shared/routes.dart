import 'dart:convert';
import 'package:angel3_static/angel3_static.dart' as static_file_server;
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:file/file.dart' as file;
import 'package:sibem_backend/src/middleware/auditoria_middleware.dart';
import 'package:sibem_backend/src/middleware/sibem_auth_middleware.dart';
import 'package:sibem_backend/src/modules/candidato/candidato_routes.dart';
import 'package:sibem_backend/src/modules/cargo/cargo_routes.dart';
import 'package:sibem_backend/src/modules/conhecimento_extra/conhecimento_extra_routes.dart';
import 'package:sibem_backend/src/modules/curso/curso_routes.dart';
import 'package:sibem_backend/src/modules/divisao_cnae/divisao_cnae_routes.dart';
import 'package:sibem_backend/src/modules/empregador/empregador_routes.dart';
import 'package:sibem_backend/src/modules/encaminhamento/encaminhamento_routes.dart';
import 'package:sibem_backend/src/modules/pmro_padrao/pmro_padrao_routes.dart';
import 'package:sibem_backend/src/modules/tipo_conhecimento/tipo_conhecimento_routes.dart';
import 'package:sibem_backend/src/modules/vaga/vaga_routes.dart';

// import 'package:sibem_backend/src/shared/dependencies/custom_router/pipeline.dart';
// import 'package:sibem_backend/src/shared/dependencies/custom_router/router.dart';
// import 'package:sibem_backend/src/shared/dependencies/custom_router/router_entry.dart';

import 'package:sibem_backend/src/shared/route_item.dart';

const List<MyRoute> rotasPrivadasWeb = [
  ...authWebPrivatesRoutes,
  ...vagaPrivateWebRoutes,
  ...candidatoWebPrivateRoutes,
  ...encaminhamentoWebPrivateRoutes,
];

const List<MyRoute> rotasPublicasWeb = [
  ...authWebPublicRoutes,
  ...empregadorWebPublicRoutes,
  ...usuarioWebPublicRoutes,
  ...vagaPublicWebRoutes,
  ...pmroPadraoWebPublicRoutes,
  ...cargoWebPublicRoutes,
  ...candidatoWebPublicRoutes,
  ...divisaoCnaeWebPublicRoutes,
  ...cursoWebPublicRoutes,
  ...tipoConhecimentoWebPublicRoutes,
  ...conhecimentoExtraWebPublicRoutes,
  ...vagaBeneficioWebPublicRoutes,
];

const List<MyRoute> rotasPrivadas = [
  ...vagaPrivateRoutes,
  ...pmroPadraoPrivateRoutes,
  // cargos
  ...cargoPrivateRoutes,
  // cursos
  ...cursoPrivateRoutes,
  // tipos de conecimento
  ...tipoConhecimentoPrivateRoutes,
  // conhecimento extra
  ...conhecimentoExtraPrivateRoutes,
  // divisoes cnae
  ...divisaoCnaePrivateRoutes,
  // empregadores
  ...empregadorPrivatesRoutes,
  // candidatos
  ...candidatoPrivatesRoutes,
  // encaminhamentos
  ...encaminhamentoPrivateRoutes,
  // auditoria
  ...auditoriaPrivateRoutes,
  // estatistica
  ...estatisticaPrivateRoutes,
];

AngelConfigurer configureRoutes(file.FileSystem fileSystem) {
  final basePath = '/api/v1';
  // rotas para o site externo do banco de empregos
  final basePathWeb = '/web/api/v1';

  return (Angel app) async {
    app.get('/', (req, res) => res.write('sibem_backend'));

    for (final rota in rotasPrivadasWeb) {
      app.addRoute(rota.methodUpper(), basePathWeb + rota.path,
          (req, res) => rota.handler as RequestHandler,
          middleware: [SibemAuthMiddleware().handleRequest]);
    }

    for (final rota in rotasPublicasWeb) {
      app.addRoute(rota.methodUpper(), basePathWeb + rota.path,
          (req, res) => rota.handler as RequestHandler);
    }

    for (final rota in rotasPrivadas) {
      app.addRoute(rota.methodUpper(), basePath + rota.path,
          (req, res) => rota.handler as RequestHandler, middleware: [
        JubarteAuthMiddleware().handleRequest,
        AuditoriaMiddleware().handleRequest
      ]);
    }

    app.fallback((req, res) {
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.statusCode = 400;
      return res.write(jsonEncode({
        'message': 'Rota não existe',
        'exception': 'Rota não existe',
        'stackTrace': ''
      }));
    });

    // final router = CustomRouter();
    // router.get('/', (req, res) => res.write('sibem_backend'));
    // for (final rota in rotasPrivadas) {
    //   print('${rota.methodUpper() } ${basePath + rota.pathAsShelf()} ${rota.handler}');
    //   router.add(
    //     rota.methodUpper(),
    //     basePath + rota.pathAsShelf(),
    //     rota.handler as CustomHandler,
    //     middleware:  (Pipeline()..addMiddleware(JubarteAuthMiddleware.handle)).middleware
    //   );
    // }

    if (!app.environment.isProduction) {
      var vDir = static_file_server.VirtualDirectory(
        app,
        fileSystem,
        source: fileSystem.directory('web'),
        //allowDirectoryListing: true,
      );
      app.fallback(vDir.handleRequest);
    }

    //app.all('*', router.call);

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
    //
  };
}
