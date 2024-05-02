

import 'package:darcli/darcli.dart';
import 'package:test/test.dart';

void main() {
  group('generators', () {
    for (var generator in generators) {
      test(generator.id, () => validate(getGenerator(generator.id)));
    }
  });
}

void validate(Generator generator) {
  expect(generator.id, isNot(contains(' ')));
  expect(generator.description, endsWith('.'));
  expect(generator.entrypoint, isNotNull);
  expect(generator.getInstallInstructions(), isNotNull);
}
