import 'dart:html';

import 'package:sibem_frontend/sibem_frontend.dart';

@Directive(selector: '[cnpjMask]')
class CnpjMaskDirective {
  String mask = 'xx.xxx.xxx/xxxx-xx';
  int maxLength = 18;
  String escapeCharacter = 'x';
  InputElement? inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';

  CnpjMaskDirective(this._el) {
    lastTextSize = 0;
    inputElement = _el as InputElement;
    inputElement?.onInput.listen((e) {
      _onChange();
    });
  }

  void _onChange() {
    if (inputElement != null) {
      var text = inputElement!.value ?? '';

      if (text.length <= mask.length) {
        // its deleting text
        if (text.length < lastTextSize) {
          if (mask[text.length] != escapeCharacter) {
            //inputElement.focus();
            inputElement!.setSelectionRange(
                inputElement!.value!.length, inputElement!.value!.length);
            inputElement!.select();
          }
        } else {
          // its typing
          if (text.length >= lastTextSize) {
            var position = text.length;
            position = position <= 0 ? 1 : position;
            if (position < mask.length - 1) {
              if ((mask[position - 1] != escapeCharacter) &&
                  (text[position - 1] != mask[position - 1])) {
                inputElement!.value = _buildText(text);
              }
              if (mask[position] != escapeCharacter) {
                inputElement!.value = '${inputElement!.value}${mask[position]}';
              }
            }
          }

          if (inputElement!.selectionStart! < inputElement!.value!.length) {
            inputElement!.setSelectionRange(
                inputElement!.value!.length, inputElement!.value!.length);
            inputElement!.select();
          }
        }
        // update cursor position
        lastTextSize = inputElement!.value!.length;
        lastTextValue = inputElement!.value!;
      } else {
        inputElement!.value = lastTextValue;
      }
    }
  }

  String _buildText(String text) {
    var result = '';
    for (var i = 0; i < text.length - 1; i++) {
      result += text[i];
    }
    result += mask[text.length - 1];
    result += text[text.length - 1];
    return result;
  }
}
