


import 'package:new_sali_frontend/new_sali_frontend.dart';

import '../form_validators/custom_required_validator.dart';
import 'select_control_value_accessor_with_equal.dart';


// const List<Type> formDirectives = [
//   NgControlName,
//   NgControlGroup,
//   NgFormControl,
//   NgModel,
//   NgFormModel,
//   NgForm,
//   MemorizedForm,
//   NgSelectOption,
//   DefaultValueAccessor,
//   NumberValueAccessor,
//   CheckboxControlValueAccessor,
//   SelectControlValueAccessor,
//   RadioControlValueAccessor,
//   RequiredValidator,
//   MinLengthValidator,
//   MaxLengthValidator,
//   PatternValidator
// ];

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
  PatternValidator
];
