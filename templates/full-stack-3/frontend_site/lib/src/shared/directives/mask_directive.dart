import 'dart:html';

import 'package:sibem_frontend_site/sibem_frontend_site.dart';

/// mask = 'xxx.xxx.xxx-xx'
@Directive(selector: '[mask]')
class MaskDirective {
  String _mask = 'xxx.xxx.xxx-xx';
  // ignore: unused_field
  int _maxLength = 14;

  @Input('mask')
  set mask(String? val) {
    if (val != null) {
      _mask = val;
    }
  }

  @Input('maxLength')
  set maxLength(int? val) {
    if (val != null) {
      _maxLength = val;
    }
  }

  String escapeCharacter = 'x';
  InputElement? inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';

  MaskDirective(this._el) {
    lastTextSize = 0;
    inputElement = _el as InputElement;
    inputElement?.onInput.listen((e) {
      _onChange();
    });
  }

  void _onChange() {
    if (inputElement != null) {
      var text = inputElement!.value ?? '';

      if (text.length <= _mask.length) {
        // its deleting text
        if (text.length < lastTextSize) {
          if (_mask[text.length] != escapeCharacter) {
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
            if (position < _mask.length - 1) {
              if ((_mask[position - 1] != escapeCharacter) &&
                  (text[position - 1] != _mask[position - 1])) {
                inputElement!.value = _buildText(text);
              }
              if (_mask[position] != escapeCharacter) {
                inputElement!.value =
                    '${inputElement!.value}${_mask[position]}';
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
    result += _mask[text.length - 1];
    result += text[text.length - 1];
    return result;
  }
}
