

import 'dart:async';
import 'dart:convert';

import 'package:darcli/darcli.dart';
import 'package:test/test.dart';

void main() {
  for (var generator in generators) {
    test(generator.id, () => _testGenerator(getGenerator(generator.id)));
  }
}

Future _testGenerator(Generator generator) async {
  expect(generator.id, isNotNull);

  final target = MockTarget();

  // Assert that we can generate the template.
  await generator.generate('foo', target);

  // Run some basic validation on the generated results.
  expect(target.getFileContentsAsString('.gitignore'), isNotNull);
  expect(target.getFileContentsAsString('pubspec.yaml'), isNotNull);
}

class MockTarget extends GeneratorTarget {
  final Map<String, List<int>> _files = {};

  @override
  Future createFile(String path, List<int> contents) async {
    _files[path] = contents;
  }

  bool hasFile(String path) => _files.containsKey(path);

  String? getFileContentsAsString(String path) {
    if (!hasFile(path)) return null;
    return utf8.decode(_files[path]!);
  }
}
