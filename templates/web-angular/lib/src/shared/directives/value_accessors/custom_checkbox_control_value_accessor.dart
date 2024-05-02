import 'dart:html';

import 'package:ngdart/angular.dart';

// ignore: implementation_imports
import 'package:ngforms/src/directives/control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;

// /// Used to provide a [ControlValueAccessor] for form controls.
// ///
// /// See [DefaultValueAccessor] for how to implement one.
// const ngValueAccessor = MultiToken<ControlValueAccessor<dynamic>>(
//   'NgValueAccessor',
// );

const custonCheckboxValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  CustonCheckboxControlValueAccessor,
);

/// The accessor for writing a value and listening to changes on a checkbox input element.
///
/// ### Example
///
/// ```html
/// <input type="checkbox" ngControl="rememberLogin">
/// ```
@Directive(
  selector: 'input[type=checkbox][ngControl],'
      'input[type=checkbox][ngFormControl],'
      'input[type=checkbox][ngModel]',
  providers: [custonCheckboxValueAccessor],
)
class CustonCheckboxControlValueAccessor extends Object
    with TouchHandler, ChangeHandler<bool>
    implements ControlValueAccessor<bool> {
  final InputElement _element;

  CustonCheckboxControlValueAccessor(HtmlElement element)
      : _element = element as InputElement;

  @HostListener('change', ['\$event.target.checked'])
  void handleChange(bool checked) {
    onChange(checked, rawValue: '$checked');
  }

  @override
  void writeValue(bool? value) {
    _element.checked = value;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }
}
