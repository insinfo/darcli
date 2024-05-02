import 'package:dotenv/dotenv.dart';

final appConfig = AppConfig.inst();

class AppConfig {
  static AppConfig? _instance;

  String get basePath => env['base_path'] ?? '/ravabackend/api/v1';

  /// retorna a intancia
  static AppConfig inst() {
    if (_instance == null) {
      final env = DotEnv(includePlatformEnvironment: false)..load();
      _instance = AppConfig(env);
    }
    return _instance!;
  }

  final DotEnv env;

  AppConfig(this.env);

  String get serverHost => env['server_host']!;
  String get serverPort => env['server_port']!;
  String get appCacheDir => env['app_cache_dir']!;

  String get dbName => env['db_name']!;
  String get dbHost => env['db_host']!;
  int get dbPort => int.parse(env['db_port']!);
  String get dbUser => env['db_user']!;
  String get dbPass => env['db_pass']!;
  String get dbCharset => env['db_charset']!;
  List<String> get dbSchemes => env['db_schemes']!.contains(',')
      ? env['db_schemes']!.split(',')
      : [env['db_schemes']!];

  String get dns => env['dns']!;
  String get storageDns => env['storage_dns']!;
  String get storageDir => env['storage_dir']!;
  String get appLinkBack => env['app_link_back']!;
  String get appLinkFront => env['app_link_front']!;

  String getStorageDnsWith(String filePath) {
    return '$storageDns/$filePath';
  }
}
