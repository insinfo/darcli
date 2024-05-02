import 'dart:html';
import 'package:ngdart/angular.dart';

/// <input [isOnlyNumber]="true" name="fone" type="text" class="form-control" required>
@Directive(selector: '[isOnlyNumber]')
class OnlyNumberDirective {
  late InputElement inputElement;
  final Element _el;

  @Input('isOnlyNumber')
  bool isOnlyNumber = true;

  OnlyNumberDirective(this._el) {
    if (!(_el is InputElement)) {
      throw Exception(
          'OnlyNumberDirective has to be applied to an InputElement');
    }
    inputElement = _el as InputElement;
    if (isOnlyNumber) {
      inputElement.onKeyPress.listen(onlyNumberKey);
    }
    // inputElement.onInput.listen((e) {
       //print('OnlyNumberDirective@onInput');
    // });
    inputElement.onPaste.listen((e) {
      final regex = RegExp(r'^[0-9]*$');
      final data = e.clipboardData?.getData('text/plain');
      if (data != null && regex.hasMatch(data)) {
      } else {
        e.preventDefault();
      }
    });
  }

  onlyNumberKey(KeyboardEvent evt) {
    // Only ASCII character in that range allowed
    var ASCIICode = (evt.which != null ? evt.which : evt.keyCode) ?? 0;
    if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57)) {
      evt.preventDefault();
    }
  }
}
