import 'package:ngforms/angular_forms.dart';

import 'select_control_value_accessor_with_equal.dart';

/// substitui SelectControlValueAccessor por SelectControlValueAccessorWithEqual
const List<Type> customFormDirectives = [
  NgControlName,
  NgControlGroup,
  NgFormControl,
  NgModel,
  NgFormModel,
  NgForm,
  MemorizedForm,

  DefaultValueAccessor,
  NumberValueAccessor,
  CheckboxControlValueAccessor,
  //
  SelectControlValueAccessorWithEqual,
  CustomNgSelectOption,

  // SelectControlValueAccessor,
  // NgSelectOption,

  RadioControlValueAccessor,
  RequiredValidator,
  MinLengthValidator,
  MaxLengthValidator,
  PatternValidator
];
