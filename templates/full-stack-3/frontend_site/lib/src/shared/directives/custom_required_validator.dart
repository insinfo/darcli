import 'dart:html';

import 'package:sibem_frontend_site/sibem_frontend_site.dart';

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
  final Element _element;

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

  CustomRequiredValidator(this._element) {
    feedbackElement = DivElement();
    feedbackElement.text = _errorMessage;
    feedbackElement.setAttribute('class', 'invalid-feedback');
    _element.parent?.append(feedbackElement);
  }

  List<dynamic> _invalidValues = ['null', ''];

  @Input('invalidValues')
  set invalidValues(dynamic val) {
    if (val is List) {
      _invalidValues = val;
    } else if (val is String) {
      _invalidValues = val.split(',');
    }else{
      _invalidValues.add(val);
    }
  }

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    if (disabled == true) {
      return null;
    }

    var isValid = false;

    if (_customRequiredType == 'string') {
      if (control.value == null) {
        isValid == false;
      } else if (control.value is String) {
        isValid = !_invalidValues.contains(control.value);
      }
    } else if (_customRequiredType == 'cnpj') {
      isValid = control.value is String && CnpjUtil.isValid(control.value);
    } else if (_customRequiredType == 'cpf') {
      isValid = control.value is String && CpfUtil().validate(control.value);
    } else if (_customRequiredType == 'date') {
      isValid = control.value is DateTime;
    } else if (_customRequiredType == 'int') {
      isValid = control.value is int && !_invalidValues.contains(control.value);
      //print('isValid $isValid _invalidValues $_invalidValues');
    } else if (_customRequiredType == 'bool') {
      isValid = control.value is bool;
    }

   // print( 'control.value  ${control.value} | ${control.value.runtimeType} | isValid $isValid | $_invalidValues');

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
