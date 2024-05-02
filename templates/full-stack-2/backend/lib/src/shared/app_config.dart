import 'package:dotenv/dotenv.dart';

class AppConfig {
  static AppConfig? _instance;

  String get basePath => env['base_path'] ?? '/esicbackend/api/v1';

  /// retorna a intancia
  static AppConfig inst() {
    if (_instance == null) {
      var env = DotEnv(includePlatformEnvironment: true)..load();
      _instance = AppConfig(env);
    }

    return _instance!;
  }

  DotEnv env;

  AppConfig(this.env);

  String get serverHost => env['server_host']!;
  String get serverPort => env['server_port']!;
  String get dbName => env['db_name']!;
  String get dbHost => env['db_host']!;
  int get dbPort => int.parse(env['db_port']!);
  String get dbPass => env['db_pass']!;
  String get dns => env['dns']!;
  String get storageDns => env['storage_dns']!;
  String get storageDir => env['storage_dir']!;
  String get app_link_back => env['app_link_back']!;
  String get app_link_front => env['app_link_front']!;

  int prazoResposta = 20;
  int qtdProrrogacaoResposta = 10;
  int prazoSolicitacaoRecurso = 10;
  int prazoRespostaRecurso = 10;
  int qtdeProrrogacaoRecurso = 10;

  String getStorageDnsWith(String filePath) {
    return '$storageDns/$filePath';
  }
}
