import 'package:eloquent/eloquent.dart';

import 'package:rava_backend/rava_backend.dart';

class DBLayer extends Manager {
  late Connection _connection;
  //final Manager dbManager;

  DBLayer() {
    addConnection({
      'driver': 'pgsql',
      'host': appConfig.dbHost, 
      'port': appConfig.dbPort.toString(),
      'database': appConfig.dbName,
      'username': appConfig.dbUser, 
      'password': appConfig.dbPass,
      'charset': appConfig.dbCharset, 
      'prefix': '',
      'schema': appConfig.dbSchemes,
    }, 'default');
    addConnection({
      'driver': 'pgsql',
      'host': appConfig.dbHost, 
      'port': appConfig.dbPort.toString(),
      'database': appConfig.dbName,
      'username': appConfig.dbUser, 
      'password': appConfig.dbPass,
      'charset': appConfig.dbCharset, 
      'prefix': '',
      'schema': appConfig.dbSchemes,  
      'driver_implementation': 'postgres_v3',// postgres | dargres | postgres_v3
      //'sslmode' => 'prefer',
      'pool': true,
      'poolsize': 4,
      //'allowreconnect': ,
    }, 'auditoria');
  }

  Future<Connection> connect([String? name]) async {
    _connection = await getConnection(name ?? 'default');
    //print('DBLayer@connect ${appConfig.dbHost}');
    //_manager.container['config']['database.connections']['default']
    // print('db_connect.dart connected on ${appConfig.dbHost} | pool: ${appConfig.dbPool} | poolsize: ${appConfig.dbPoolSize} | allowreconnect: ${appConfig.dbAllowReconnect}');
    return _connection;
  }

  Future close() async {
    await _connection.disconnect();
  }
}
