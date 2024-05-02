import 'dart:js_util' as js_util;
import 'dart:html';

/// fix this bug https://github.com/dart-lang/sdk/issues/47942
extension ToStringSelectionExtension on Selection? {
  String asString() {
    var result = js_util.callMethod(this as Selection, 'toString', []);
    return result.toString();
  }
}

extension ToStringNullSafetySelectionExtension on Selection {
  String asString() {
    var result = js_util.callMethod(this, 'toString', []);
    return result.toString();
  }
}
