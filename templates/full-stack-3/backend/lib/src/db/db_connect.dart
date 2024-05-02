import 'package:sibem_backend/src/shared/app_config.dart';
import 'package:eloquent/eloquent.dart';

final dbManager = Manager()
  ..addConnection({
    'driver': 'pgsql',
    'driver_implementation': 'postgres', // postgres | dargres | postgres_v3
    'host': AppConfig.inst().dbHost,
    'port': AppConfig.inst().dbPort.toString(),
    'database': AppConfig.inst().dbName,
    'username': AppConfig.inst().dbUser,
    'password': AppConfig.inst().dbPass,
    'charset': AppConfig.inst().dbCharset,
    'prefix': '',
    'schema': AppConfig.inst().db_schemes,
    //'sslmode' => 'prefer',
    'pool': true,
    'poolsize': 8,
    'application_name': 'sibem',
    // 'allowreconnect': appConfig.dbAllowReconnect,
  },'default2');
//..setAsGlobal();

Future<Connection> dbConnect() async {
  final config = AppConfig.inst();
  final db = await dbManager.getConnection('default2');
 
  //_manager.container['config']['database.connections']['default']
  print(
      'db_connect.dart connected on ${config.dbHost} | pool: ${config.dbPool} | poolsize: ${config.dbPoolSize} | allowreconnect: ${config.dbAllowReconnect}');
  return db;
}
