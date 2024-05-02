import 'dart:io';
import 'package:logging/logging.dart';
import 'package:belatuk_pretty_logging/belatuk_pretty_logging.dart';
import 'package:angel3_container/mirrors.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_hot/angel3_hot.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/bootstrap.dart';

void main() async {
  startCronService();
  hierarchicalLoggingEnabled = true;

  final hot = HotReloader(() async {
    final logger = Logger.detached('sibem')
      ..level = Level.ALL
      ..onRecord.listen(prettyLog);
    final app = Angel(logger: logger, reflector: MirrorsReflector());
    await app.configure(configureServer);
    return app;
  }, [
    Directory('lib'),
    Directory('bin'),
  ]);
  final config = AppConfig.inst();
  final server = await hot.startServer(config.serverHost, config.serverPort);

  print('server listening at http://${server.address.address}:${server.port}');
}
