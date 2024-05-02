
import '../common.dart';

part 'package_simple.g.dart';

/// A generator for a pub library.
class PackageSimpleGenerator extends DefaultGenerator {
  PackageSimpleGenerator()
      : super('package-simple', 'Dart Package',
            'A starting point for Dart libraries or applications.',
            categories: const ['dart']) {
    for (var file in decodeConcatenatedData(_data)) {
      addTemplateFile(file);
    }

    setEntrypoint(getFile('lib/__projectName__.dart'));
  }
}
