// import 'package:eloquent/eloquent.dart';
// import 'package:rava_backend/src/shared/app_config.dart';

// final dbManager = Manager()
//   ..addConnection({
//     'driver': 'pgsql',
//     //'driver_implementation': 'dargres',
//     //'driver_implementation': 'postgres',
//     'driver_implementation': 'postgres_v3',
//     'host': appConfig.dbHost,
//     'port': appConfig.dbPort.toString(),
//     'database': appConfig.dbName,
//     'username': appConfig.dbUser, 
//     'password': appConfig.dbPass,
//     'charset': appConfig.dbCharset, 
//     'prefix': '',
//     'schema': appConfig.dbSchemes,    
//   });
// //..setAsGlobal();

// Future<Connection> connect(AppConfig appConfig) async {
//   final db = await dbManager.getConnection();
//   //_manager.container['config']['database.connections']['default']
//   print('db_connect.dart connected on ${appConfig.dbHost}');
//   return db;
// }
