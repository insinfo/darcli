

import '../common.dart';

part 'web_stagexl.g.dart';

/// A generator for a StageXL web application.
class WebStageXlGenerator extends DefaultGenerator {
  WebStageXlGenerator()
      : super('web-stagexl', 'StageXL Web App',
            'A starting point for 2D animation and games.',
            categories: const ['dart', 'web']) {
    for (var file in decodeConcatenatedData(_data)) {
      addTemplateFile(file);
    }

    setEntrypoint(getFile('web/index.html'));
  }
}
