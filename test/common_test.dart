

import 'package:darcli/src/common.dart';
import 'package:test/test.dart';

void main() {
  group('common', () {
    test('normalizeProjectName', () {
      expect(normalizeProjectName('foo.dart'), 'foo');
      expect(normalizeProjectName('foo-bar'), 'foo_bar');
    });

    group('substituteVars', () {
      test('simple', () {
        _expect('foo __bar__ baz', {'bar': 'baz'}, 'foo baz baz');
      });

      test('nosub', () {
        _expect('foo __bar__ baz', {'aaa': 'bbb'}, 'foo __bar__ baz');
      });

      test('matching input', () {
        _expect('foo __bar__ baz', {'bar': '__baz__', 'baz': 'foo'},
            'foo __baz__ baz');
      });

      test('vars must be alpha + numeric', () {
        expect(() => substituteVars('str', {'with space': 'noop'}),
            throwsArgumentError);
        expect(() => substituteVars('str', {'with!symbols': 'noop'}),
            throwsArgumentError);
        expect(() => substituteVars('str', {'with1numbers': 'noop'}),
            throwsArgumentError);
        expect(() => substituteVars('str', {'with_under': 'noop'}),
            throwsArgumentError);
      });
    });
  });
}

void _expect(String original, Map<String, String> vars, String result) {
  expect(substituteVars(original, vars), result);
}
