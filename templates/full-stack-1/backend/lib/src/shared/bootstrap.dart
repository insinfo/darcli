import 'package:angel3_framework/angel3_framework.dart';
import 'dart:async';
import 'package:file/local.dart';


import 'app_config.dart';

import 'routes.dart';
import 'package:new_sali_backend/src/shared/dependencies/angel3_cors/angel3_cors.dart';

Future configureServer(Angel app) async {
  
  app.container.registerSingleton<AppConfig>(appConfig);
 
  final options = CorsOptions();
  app.fallback(cors(options));

  final fs = const LocalFileSystem();
  
  await app.configure(configureRoutes(fs));
}

