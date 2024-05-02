

import '../common.dart';

part 'web_simple.g.dart';

/// A generator for a uber-simple web application.
class WebSimpleGenerator extends DefaultGenerator {
  WebSimpleGenerator()
      : super('web-simple', 'Bare-bones Web App',
            'A web app that uses only core Dart libraries.',
            categories: const ['dart', 'web']) {
    for (var file in decodeConcatenatedData(_data)) {
      addTemplateFile(file);
    }

    setEntrypoint(getFile('web/index.html'));
  }
}
