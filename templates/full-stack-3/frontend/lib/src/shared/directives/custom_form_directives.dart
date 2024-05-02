import 'package:sibem_frontend/sibem_frontend.dart';

import 'package:sibem_frontend/src/shared/components/custom_select/custom_select.dart';

import 'value_accessors/custom_checkbox_control_value_accessor.dart';
import 'value_accessors/date_value_accessor.dart';
import 'value_accessors/select_control_value_accessor_with_equal.dart';

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
  // CheckboxControlValueAccessor,
  CustonCheckboxControlValueAccessor,
  SelectControlValueAccessorWithEqual,
  CustomNgSelectOption,
  //BrowserAutocompleteAttrDirective,
  DateValueAccessor,
  CustomRequiredValidator,

  // SelectControlValueAccessor,
  // NgSelectOption,
  RadioControlValueAccessor,
  RequiredValidator,
  MinLengthValidator,
  MaxLengthValidator,
  PatternValidator,
  //
  CustomSelectComponent,
];
