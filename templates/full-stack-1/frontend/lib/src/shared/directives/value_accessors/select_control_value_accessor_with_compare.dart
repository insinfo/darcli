import 'dart:html';

import 'package:ngdart/angular.dart';
//import 'package:ngdart/src/utilities.dart';
import 'package:ngdart/src/dependencies/ngforms/src/directives/control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;

const SELECT_VALUE_ACCESSOR = ExistingProvider.forToken(
  ngValueAccessor,
  SelectControlValueAccessorWithCompare,
);

extension IsPrimitive on Object? {
  /// Returns whether this object is considered a "primitive" (in JavaScript).
  ///
  /// In short, this is true for [num], [bool], [String], and [Null].
  bool get isPrimitive {
    return this is num || this is bool || this == null || this is String;
  }
}

String _buildValueString(String? id, Object? value) {
  if (id == null) return '$value';
  if (!value!.isPrimitive) value = 'Object';
  var s = '$id: $value';
  //  Fix this magic maximum 50 characters (from TS-transpile).
  if (s.length > 50) {
    s = s.substring(0, 50);
  }
  return s;
}

String _extractId(String valueString) => valueString.split(':')[0];

/// The accessor for writing a value and listening to changes on a select
/// element.
///
/// Note: We have to listen to the 'change' event because 'input' events aren't
/// fired for selects in Firefox and IE:
/// https://bugzilla.mozilla.org/show_bug.cgi?id=1024350
/// https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/4660045
@Directive(
  selector: 'select[ngControl],select[ngFormControl],select[ngModel]',
  providers: [SELECT_VALUE_ACCESSOR],
  // SelectControlValueAccessor must be visible to CustomNgSelectOption.
  visibility: Visibility.all,
)
class SelectControlValueAccessorWithCompare extends Object
    with TouchHandler, ChangeHandler<dynamic>
    implements ControlValueAccessor<Object?> {
  final SelectElement _element;
  Object? value;
  final Map<String, Object?> _optionMap = <String, Object?>{};
  num _idCounter = 0;

  SelectControlValueAccessorWithCompare(HtmlElement element)
      : _element = element as SelectElement;

  @HostListener('change', ['\$event.target.value'])
  void handleChange(String value) {
    onChange(_getOptionValue(value), rawValue: value);
  }

  @Input()
  set compareWith(bool Function(Object? o1, Object? o2) fn) {
    _compareWith = fn;
  }

  bool Function(Object? o1, Object? o2) _compareWith = identical;

  @override
  void writeValue(Object? value) {
    this.value = value;
    var valueString = _buildValueString(_getOptionId(value), value);
    _element.value = valueString;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }

  String _registerOption() => (_idCounter++).toString();

  String? _getOptionId(Object? value) {
    for (var id in _optionMap.keys) {
      //if (identical(_optionMap[id], value)) return id;
      if (_compareWith(_optionMap[id], value)) return id;
    }
    return null;
  }

  dynamic _getOptionValue(String valueString) {
    var value = _optionMap[_extractId(valueString)];
    return value ?? valueString;
  }
}

/// Marks `<option>` as dynamic, so Angular can be notified when options change.
///
/// ### Example
///
///     <select ngControl="city">
///       <option *ngFor="let c of cities" [value]="c"></option>
///     </select>
@Directive(
  selector: 'option',
)
class CustomNgSelectOption implements OnDestroy {
  final OptionElement _element;
  final SelectControlValueAccessorWithCompare? _select;
  late final String id;
  CustomNgSelectOption(HtmlElement element, @Optional() @Host() this._select)
      : _element = element as OptionElement {
    if (_select != null) id = _select!._registerOption();
  }

  @Input('ngValue')
  set ngValue(Object? value) {
    var select = _select;
    if (select == null) return;
    select._optionMap[id] = value;
    _setElementValue(_buildValueString(id, value));
    select.writeValue(select.value);
  }

  @Input('value')
  set value(Object? value) {
    var select = _select;
    _setElementValue(value as String);
    if (select != null) select.writeValue(select.value);
  }

  void _setElementValue(String value) {
    _element.value = value;
  }

  @override
  void ngOnDestroy() {
    var select = _select;
    if (select != null) {
      select._optionMap.remove(id);
      select.writeValue(select.value);
    }
  }
}
