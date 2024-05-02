import 'package:new_sali_backend/src/shared/utils/backend_utils.dart';
import 'package:test/test.dart';

void main() {
  test('teste unitario ocultarInicio', () async {
    var result = BackendUtils.ocultarInicio('13128250731',limit: 3,replace: '*');
    expect(result, '***28250731');
  });

  test('teste unitario ocultarInicio string vazia', () async {
    var result = BackendUtils.ocultarInicio('');
    expect(result, '');
  });
}
