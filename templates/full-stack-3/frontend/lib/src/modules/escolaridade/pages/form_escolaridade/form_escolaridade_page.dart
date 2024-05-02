import 'dart:async';
import 'dart:html' as html;
import 'package:sibem_frontend/sibem_frontend.dart';

@Component(
  selector: 'form-escolaridade-page',
  templateUrl: 'form_escolaridade_page.html',
  styleUrls: ['form_escolaridade_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [],
)
class FormEscolaridadePage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EscolaridadeService _escolaridadeService;
  final Router _router;
  bool isNew = true;

 

  final html.Element hostElement;

  final Location _location;

  FormEscolaridadePage(this.notificationComponentService, this.hostElement,
      this._escolaridadeService, this._router, this._location);

  var item = Escolaridade(nome: '', id: -1, ordemGraduacao: 0);

  Future<void> getById(int id) async {
    final simpleLoading = SimpleLoading();

    try {
      simpleLoading.show(target: hostElement);
      item = await _escolaridadeService.getById(id);
    } catch (e, s) {
      print('FormEscolaridadePage@getById $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  bool validateForm() {
    if (item.nome.trim().length < 3) {
      SimpleDialogComponent.showAlert(
          'O nome não pode ficar vazio e deve ter pelo menos 3 caracteres!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    return true;
  }

  Future<void> salvar(NgForm cadastroForm, {bool showLoading = true}) async {
    var isValid = true;
    for (var control in cadastroForm.form!.controls.values) {
      control.markAsTouched();
      control.updateValueAndValidity();
      //so checa se é valido os campos com a directiva customRequired ignorando os campos com a directiva cpfValidator
      if (control.errors != null &&
          control.errors!['validator'] == 'customRequired') {
        isValid = false;
      }
    }

    if (isValid == false) {
      SimpleDialogComponent.showAlert('Preencha os campos obrigatórios!',
          okAction: () => focusFirstInvalidFields(cadastroForm));
    } else {
      final simpleLoading = SimpleLoading();
      try {
        if (!validateForm()) {
          return;
        }
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }
        if (isNew) {
          await _escolaridadeService.insert(item);
        } else {
          await _escolaridadeService.update(item);
        }
        notificationComponentService.notify(
            'Escolaridade ${isNew ? 'cadastrado' : 'atualizado'} com sucesso.');

        _router.navigate(RoutePaths.listaEscolaridade.toUrl());
      } catch (e, s) {
        print('FormEscolaridadePage@load $e $s');
        SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
            subMessage: '$e $s');
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    final id = RoutePaths.getId(current.parameters);
    if (id == null) {
      isNew = true;
    } else {
      isNew = false;
      await getById(id);
    }
  }

  void back() {
    _location.back();
  }
}
