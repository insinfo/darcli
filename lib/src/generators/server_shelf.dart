

import '../common.dart';

part 'server_shelf.g.dart';

/// A generator for a server app built on `package:shelf`.
class ServerShelfGenerator extends DefaultGenerator {
  ServerShelfGenerator()
      : super('server-shelf', 'Web Server',
            'A web server built using the shelf package.',
            categories: const ['dart', 'shelf', 'server']) {
    for (var file in decodeConcatenatedData(_data)) {
      addTemplateFile(file);
    }

    setEntrypoint(getFile('bin/server.dart'));
  }

  @override
  String getInstallInstructions() => '${super.getInstallInstructions()}\n'
      'run your app via `dart ${entrypoint?.path}`.';
}
