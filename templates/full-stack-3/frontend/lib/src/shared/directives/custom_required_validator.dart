import 'dart:html';

import 'package:sibem_frontend/sibem_frontend.dart';

import 'dart:html' as html;

/// função para dar foco no elemento de formulario que não esta preenchido corretamente
void focusFirstInvalidFields(NgForm procedimentoForm) {
  if (procedimentoForm.form != null) {
    for (final item in procedimentoForm.form!.controls.entries) {
      // ignore: unused_local_variable
      final key = item.key;
      final control = item.value;
      // var ele =  procedimentoForm.getControl(control as NgControl);

      if (control.invalid) {
        //print('focusFirstInvalidFields ${procedimentoForm.value} | $key');
        //'data-is-valid'
        final invalidControl =
            html.document.querySelector('[data-invalid="true"]');
        invalidControl?.focus();
        return;
      }
    }
  }
}

///  <input [(ngModel)]="item.cnpj" ngControl="cnpj" [maxlength]="200" type="text"
///  class="form-control" [customRequired]="'É necessário um CNPJ válido!'" [customRequiredType]="'cnpj'">
///
/// '[customRequired][ngControl],'
///      '[customRequired][ngFormControl],'
///      '[customRequired][ngModel]'
@Directive(
  selector: '[customRequired]',
  providers: [
    ExistingProvider.forToken(ngValidators, CustomRequiredValidator),
  ],
)
class CustomRequiredValidator implements Validator {
  // final ViewContainerRef _viewContainer;
  final Element _element;
  //late ComponentRef _componentRef;
  late HtmlElement feedbackElement;
  String _errorMessage = 'Campo requerido!';
  String _customRequiredType = 'string';

  @Input('customRequiredDisabled')
  bool disabled = false;

  @Input('customRequired')
  set customRequired(String? m) {
    if (m != null && m.isNotEmpty) {
      _errorMessage = m;
    }
    feedbackElement.text = _errorMessage;
  }

  @Input('customRequiredType')
  set customRequiredType(String? m) {
    if (m != null && m.isNotEmpty) {
      _customRequiredType = m;
    }
  }

//Engenheiro Elétrico
  //this._viewContainer,
  CustomRequiredValidator(this._element) {
    // _componentRef = _viewContainer.createComponent(FormFeedbackComponentNgFactory);
    //feedbackElement = _componentRef.location as HtmlElement;

    feedbackElement = DivElement();
    feedbackElement.text = _errorMessage;
    feedbackElement.setAttribute('class', 'invalid-feedback');
    _element.parent?.append(feedbackElement);
  }

  @Input('invalidValues')
  List<dynamic> invalidValues = [null, '',-1];

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    if (disabled == true) {
      return null;
    }
    var value = control.value is String
        ? control.value.toString().trim()
        : control.value;

    var isValid = !invalidValues.contains(value);

    if (_customRequiredType == 'string') {
      isValid = !invalidValues.contains(control.value is String
          ? control.value.toString().trim()
          : control.value);
    } else if (_customRequiredType == 'cnpj') {
      isValid = control.value is String && CnpjUtil.isValid(control.value);
    } else if (_customRequiredType == 'cpf') {
      isValid = control.value is String && CpfUtil().validate(control.value);
    }

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
      _element.attributes.remove('data-invalid');
    } else {
      _element.classes.remove('is-valid');
      _element.classes.add('is-invalid');
      _element.attributes['data-invalid'] = 'true';
    }
  }
}
