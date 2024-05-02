import 'dart:io';
import 'package:logging/logging.dart';
import 'package:belatuk_pretty_logging/belatuk_pretty_logging.dart';
import 'package:angel3_container/mirrors.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:new_sali_backend/src/shared/bootstrap.dart';
import 'package:dotenv/dotenv.dart';
import 'package:new_sali_backend/src/shared/dependencies/angel3_hot/angel3_hot.dart';

void main() async {
  hierarchicalLoggingEnabled = true;

  final hot = HotReloader(() async {
    final logger = Logger.detached('app_backend')
      ..level = Level.ALL
      ..onRecord.listen(prettyLog);
    final app = Angel(logger: logger, reflector: MirrorsReflector());
    HotReloader.configurePrometheus(app);
    await app.configure(configureServer);
    return app;
  }, [
    Directory('lib'),
    Directory('bin'),
  ]);
  final env = DotEnv(includePlatformEnvironment: false);
  env.load();

  final ip = env['server_host'] ?? 'localhost'; //'192.168.66.123';//'127.0.0.1'
  final port =
      env['server_port'] != null ? int.parse(env['server_port']!) : 3350;
  print('main() ip: $ip');

  final server = await hot.startServer(ip, port);
  print('app_backend listening at http://${server.address.address}:${server.port}');
}
