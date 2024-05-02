import 'package:sibem_frontend_site/sibem_frontend_site.dart';



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
  PatternValidator,
  //
  CustomSelectComponent,
];
