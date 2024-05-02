import 'dart:isolate';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:sibem_backend/sibem_backend.dart';

import 'dart:async';
import 'package:file/local.dart';
import 'package:sibem_backend/src/shared/routes.dart';
import 'package:angel3_cors/angel3_cors.dart';

import 'package:cron/cron.dart';

Future configureServer(Angel app) async {
  final options = CorsOptions(allowedHeaders: ["*"], exposedHeaders: ["*"]);

  app.fallback(cors(options));
  //Access-Control-Allow-Headers: *
  await dependencyInjection(app);

  final fs = const LocalFileSystem();

  await app.configure(configureRoutes(fs));
}

///para serviço agendado em segundo plano
void startCronService() async {
  print('startCronService ');
  await Isolate.spawn(_cronIsolate, [], debugName: 'cron');
}

void _cronIsolate(List args) async {
  print('_cronIsolate ');
  final cron = Cron();

  final newConnManager = Manager()
    ..addConnection({
      'driver': 'pgsql',
      'driver_implementation':
          'postgres_v3', // postgres | dargres | postgres_v3
      'host': AppConfig.inst().dbHost,
      'port': AppConfig.inst().dbPort.toString(),
      'database': AppConfig.inst().dbName,
      'username': AppConfig.inst().dbUser,
      'password': AppConfig.inst().dbPass,
      'charset': AppConfig.inst().dbCharset,
      'prefix': '',
      'schema':  AppConfig.inst().db_schemes.join(','),
      //'sslmode' => 'prefer',
      'pool': true,
      'poolsize': 1,
      // 'allowreconnect': appConfig.dbAllowReconnect,
    }, 'cronConnection');

  final conn = await newConnManager.getConnection('cronConnection');
  final repo = VagaRepository(conn);

  cron.schedule(Schedule.parse('*/60 * * * *'), () async {
    print('rodando rotina do cron a cada 60 minutos host ${AppConfig.inst().dbHost}');
    try {
      await repo.bloquearVagasVencidas();
      //await newConnManager.getDatabaseManager().purge('cronConnection');
    } catch (e, s) {
      print('erro rodando rotina do cron $e $s');
    }
    //print('fim rodando rotina do cron');
  });
}
