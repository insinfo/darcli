import 'dart:html';

import 'package:ngdart/angular.dart';

import '../../components/form_feedback/form_feedback_component.template.dart';

@Directive(
  selector: ''
      '[customRequired][ngControl],'
      '[customRequired][ngFormControl],'
      '[customRequired][ngModel]',
  providers: [
    ExistingProvider.forToken(ngValidators, CustomRequiredValidator),
  ],
)
class CustomRequiredValidator implements Validator {
  final ViewContainerRef _viewContainer;
  final Element _element;
  late ComponentRef _componentRef;
  late HtmlElement feedbackElement;
  String _errorMessage = 'Campo requerido!';

  @Input('customRequiredDisabled')
  bool disabled = false;

  @Input('customRequired')
  set customRequired(String? m) {
    if (m != null && m.isNotEmpty) {
      _errorMessage = m;
    }
    feedbackElement.text = _errorMessage;
  }

  //String get customRequired => _errorMessage;

  CustomRequiredValidator(this._viewContainer, this._element) {
    _componentRef =
        _viewContainer.createComponent(FormFeedbackComponentNgFactory);
    feedbackElement = _componentRef.location as HtmlElement;
    feedbackElement.setAttribute('class', 'invalid-feedback');
  }

  @Input('invalidValues')
  List<dynamic> invalidValues = [null, ''];

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    if (disabled == true) {
      return null;
    }
    var isValid = !invalidValues.contains(control.value is String
        ? control.value.toString().trim()
        : control.value);
    //control.value != null && control.value != '';
    if (control.touched || control.dirty) {
      validateVisual(isValid);
    }

    return isValid
        ? null
        : {
            'error-message': _errorMessage,
            'validator': 'customRequired',
          };
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
