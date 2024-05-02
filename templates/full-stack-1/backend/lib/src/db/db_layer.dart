import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/src/shared/app_config.dart';

class DBLayer extends Manager {
  late Connection _connection;

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
      'schema': appConfig.db_schemes,
      'driver_implementation': 'postgres'
    }, 'default');
  }

  Future<Connection> connect([String? name]) async {
    _connection = await getConnection(name ?? 'default');    
    return _connection;
  }

  Future close() async {   
    await _connection.disconnect();
  }
}
