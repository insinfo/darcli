import 'package:angel3_framework/angel3_framework.dart';

import 'dart:async';
import 'package:file/local.dart';
import 'package:esic_backend/esic_backend.dart';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_backend/src/shared/routes.dart';
import 'package:angel3_cors/angel3_cors.dart';

import 'package:fluent_query_builder/fluent_query_builder.dart';

Future configureServer(Angel app) async {
  //carrega o arquivo .env
  final appConfig = AppConfig.inst();
  app.container.registerSingleton<AppConfig>(appConfig);

  //connect to database
  final db = await connect();
  app.container.registerSingleton<DbLayer>(db);

  //EnviaEmailService emailService = EnviaEmailService();
  //app.container.registerSingleton<EnviaEmailService>(emailService);

  //add Cross-Origin Resource Sharing (CORS) config
  var options = CorsOptions(allowedHeaders: ["*"], exposedHeaders: ["*"]);
  app.fallback(cors(options));
  //Access-Control-Allow-Headers: *

  print("bootstrap.dart  ${appConfig.basePath} ");
  //file system config
  var fs = const LocalFileSystem();
  //routes config
  await app.configure(configureRoutes(fs));
}
