import 'dart:html';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';

import '../../validators/cpf_validator.dart';


@Directive(
  selector: ''
      '[cpfValidator][ngControl],'
      '[cpfValidator][ngFormControl],'
      '[cpfValidator][ngModel]',
  providers: [
    //NG_VALIDATORStoken de injeção (uma espécie de chave de injeção de dependência exclusiva,
    //que identifica exclusivamente uma dependência).
    ExistingProvider.forToken(
      ngValidators, CpfFormValidatorDirective, //multi: true
    ),
  ],
)
class CpfFormValidatorDirective implements Validator {
  final Element _element;

  late HtmlElement feedbackElement;
  String _errorMessage = 'CNPJ Inválido';

  bool onlyVisual = true;

  @Input('cpfValidator')
  set cpfValidator(String? v) {
    if (v != null && v.isNotEmpty) {
      _errorMessage = v;
    }
    feedbackElement.text = _errorMessage;
  }

  String get cpfValidator => _errorMessage;

  CpfFormValidatorDirective(this._element) {
    feedbackElement = DivElement();
    feedbackElement.text = _errorMessage;
    feedbackElement.setAttribute('class', 'invalid-feedback');
    _element.parent?.append(feedbackElement);
  }

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    final val = control.value?.toString();
    var isValid = CPFValidator.isValid(val);

    if (control.touched || control.dirty) {
      validateVisual(isValid);
    }
    if (onlyVisual == false) {
      return isValid
          ? null
          : {
              'error-message': _errorMessage,
              'validator': 'cpfValidator',
            };
    } else {
      return null;
    }
  }

  void validateVisual(bool isValid) {
    if (isValid) {
      _element.classes.remove('is-invalid');
      _element.classes.add('is-valid');
    } else {
      _element.classes.remove('is-valid');
      _element.classes.add('is-invalid');
    }
  }
}




/*
@Directive(
  selector: ''
      '[minLength][ngControl],'
      '[minLength][ngFormControl],'
      '[minLength][ngModel]',
  providers: [
    ExistingProvider.forToken(NG_VALIDATORS, CpfFormValidatorDirective),
  ],
)
class MinLengthValidator implements Validator {
  @HostBinding('attr.minlength')
  String minLengthAttr;

  int _minLength;
  int get minLength => _minLength;

  @Input('minlength')
  set minLength(int value) {
    _minLength = value;
    minLengthAttr = value?.toString();
  }

  @override
  Map<String, dynamic> validate(AbstractControl c) {
    final v = c?.value?.toString();
    if (v == null || v == '') return null;
    return v.length < minLength
        ? {
            'minlength': {'requiredLength': minLength, 'actualLength': v.length}
          }
        : null;
  }
}*/
