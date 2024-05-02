import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/src/shared/app_config.dart';

final dbManager = Manager()
  ..addConnection({
    'driver': 'pgsql',
    'driver_implementation': 'postgres',
    'host': appConfig.dbHost,
    'port': appConfig.dbPort.toString(),
    'database': appConfig.dbName,
    'username': appConfig.dbUser,
    'password': appConfig.dbPass,
    'charset': appConfig.dbCharset,
    'prefix': '',
    'schema': appConfig.db_schemes,
  });

Future<Connection> connect(AppConfig appConfig) async {
  final db = await dbManager.getConnection();

  print(
      'db_connect.dart connected on ${appConfig.dbHost} | pool: ${appConfig.dbPool} | poolsize: ${appConfig.dbPoolSize} | allowreconnect: ${appConfig.dbAllowReconnect}');
  return db;
}
