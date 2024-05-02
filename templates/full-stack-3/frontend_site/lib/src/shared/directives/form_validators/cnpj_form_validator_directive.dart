import 'dart:html';
import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Directive(
  selector: ''
      '[cnpjValidator][ngControl],'
      '[cnpjValidator][ngFormControl],'
      '[cnpjValidator][ngModel]',
  providers: [
    //NG_VALIDATORStoken de injeção (uma espécie de chave de injeção de dependência exclusiva,
    //que identifica exclusivamente uma dependência).
    ExistingProvider.forToken(
      ngValidators, CnpjFormValidatorDirective, //multi: true
    ),
  ],
)
class CnpjFormValidatorDirective implements Validator {
  final Element _element;

  late HtmlElement feedbackElement;
  String _errorMessage = 'CNPJ Inválido';

  bool onlyVisual = true;

  @Input('cnpjValidator')
  set cnpjValidator(String? v) {
    if (v != null && v.isNotEmpty) {
      _errorMessage = v;
    }
    feedbackElement.text = _errorMessage;
  }

  String get cnpjValidator => _errorMessage;

  CnpjFormValidatorDirective(this._element) {
    feedbackElement = DivElement();
    feedbackElement.text = _errorMessage;
    feedbackElement.setAttribute('class', 'invalid-feedback');
    _element.parent?.append(feedbackElement);
  }

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    final val = control.value?.toString();
    var isValid = CNPJValidator.isValid(val);

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
