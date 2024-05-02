import 'dart:html';

import 'package:new_sali_frontend/new_sali_frontend.dart';


/// <input [mask]="'(xx)xxxx-xxxx'" name="fone" type="text" class="form-control" required>
@Directive(selector: '[mask]')
class MaskDirective {
  @Input('mask')
  String mask = 'xxx.xxx.xxx-xx'; //xxx.xxx.xxx-xx xxxxx-xxx

  String escapeCharacter = 'x';
  late InputElement inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';

  @Input('isOnlyNumber')
  bool isOnlyNumber = true;

  MaskDirective(this._el) {
    lastTextSize = 0;
    if (!(_el is InputElement)) {
      throw Exception('MaskDirective has to be applied to an InputElement');
    }
    inputElement = _el as InputElement;
    if (isOnlyNumber) {
      inputElement.onKeyPress.listen(onlyNumberKey);
    }
    inputElement.onInput.listen((e) {
      _onChange(inputElement.value!);
      //print(inputElement.value);
    });

    inputElement.onPaste.listen((e) {
      final pattern = FrontUtils.convertMaskToRegex(mask, escapeCharacter);      
      final regex = RegExp(pattern);
      final data = e.clipboardData?.getData('text/plain');
      if (data != null && regex.hasMatch(data)) {
      } else {
        e.preventDefault();
      }
    });
  }

  void _onChange(String text) {
    if (text.length <= mask.length) {
      // its deleting text
      if (text.length < lastTextSize) {
        if (mask[text.length] != escapeCharacter) {
          //inputElement.focus();
          inputElement.setSelectionRange(
              inputElement.value!.length, inputElement.value!.length);
          inputElement.select();
        }
      } else {
        // its typing
        if (text.length >= lastTextSize) {
          var position = text.length;
          position = position <= 0 ? 1 : position;
          if (position < mask.length - 1) {
            if ((mask[position - 1] != escapeCharacter) &&
                (text[position - 1] != mask[position - 1])) {
              inputElement.value = _buildText(text);
            }
            if (mask[position] != escapeCharacter) {
              inputElement.value = '${inputElement.value}${mask[position]}';
            }
          }
        }

        if (inputElement.selectionStart! < inputElement.value!.length) {
          inputElement.setSelectionRange(
              inputElement.value!.length, inputElement.value!.length);
          inputElement.select();
        }
      }
      // update cursor position
      lastTextSize = inputElement.value!.length;
      lastTextValue = inputElement.value!;
    } else {
      inputElement.value = lastTextValue;
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

  onlyNumberKey(KeyboardEvent evt) {
    // Only ASCII character in that range allowed
    var ASCIICode = (evt.which != null ? evt.which : evt.keyCode) ?? 0;
    if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57)) {
      evt.preventDefault();
    }
  }
}
