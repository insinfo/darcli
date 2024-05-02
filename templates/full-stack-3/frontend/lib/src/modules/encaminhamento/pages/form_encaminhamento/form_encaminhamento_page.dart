import 'dart:async';
import 'dart:html' as html;
import 'package:sibem_frontend/sibem_frontend.dart';
import 'package:sibem_frontend/src/modules/candidato/pages/lista_candidato/lista_candidato_page.dart';
import 'package:sibem_frontend/src/modules/encaminhamento/services/gera_pdf_guia_encaminhamento.dart';
import 'package:sibem_frontend/src/modules/vaga/pages/lista_vaga/lista_vaga_page.dart';

@Component(
  selector: 'form-encaminhamento-page',
  templateUrl: 'form_encaminhamento_page.html',
  styleUrls: ['form_encaminhamento_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    ListaVagaPage,
    ListaCandidatoPage,
  ],
)
class FormEncaminhamentoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EncaminhamentoService _encaminhamentoService;
  // ignore: unused_field
  final AuthService _authService;
  final Router _router;
  bool isNew = true;

  final html.Element hostElement;
  final Location _location;

  var item = Encaminhamento.invalid();
  // String nomeVaga = '';
  // String nomeCandidato = '';

  @ViewChild('modalVaga')
  CustomModalComponent? modalVaga;

  @ViewChild('listaVaga')
  ListaVagaPage? listaVaga;

  @ViewChild('modalCandidato')
  CustomModalComponent? modalCandidato;

  @ViewChild('listaCandidato')
  ListaCandidatoPage? listaCandidato;

  FormEncaminhamentoPage(
      this.notificationComponentService,
      this.hostElement,
      this._encaminhamentoService,
      this._router,
      this._location,
      this._authService);

  Future<void> getById(int id) async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show(target: hostElement);
      item = await _encaminhamentoService.getById(id);
    } catch (e, s) {
      print('FormEncaminhamentoPage@getById $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  bool validateForm() {
    if (item.nomeVaga == null || item.nomeVaga?.trim().isEmpty == true) {
      SimpleDialogComponent.showAlert('Selecione a vaga!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (item.nomeCandidato == null ||
        item.nomeCandidato?.trim().isEmpty == true) {
      SimpleDialogComponent.showAlert('Selecione o candidato!',
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
          await _encaminhamentoService.insert(item);
        } else {
          await _encaminhamentoService.update(item);
        }
        notificationComponentService.notify(
            'Encaminhamento ${isNew ? 'cadastrado' : 'atualizado'} com sucesso.');
        geraGuiaEncaminhamento();
        _router.navigate(RoutePaths.listaEncaminhamento.toUrl());
      } catch (e, s) {
        print('FormEncaminhamentoPage@load $e $s');
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
    //var param = current.parameters['id'];
    //final id = int.tryParse(current.parameters['id'] ?? '');
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

  void openModalVaga() {
    listaVaga?.load();
    modalVaga?.open();
  }

  void onSelectVaga(Vaga vaga) {
    item.nomeCandidato = null;
    item.idCandidato = -1;
    item.vaga = vaga;
    if (vaga.empregador == null) {
      SimpleDialogComponent.showAlert('o empregador da vaga esta nulo');
    }
    item.empregador = vaga.empregador;
    listaCandidato?.filtroIdVaga = vaga.id;
    listaCandidato?.filtro.nomeVaga = vaga.cargoNome;
    listaCandidato?.enableAllVagaMatch();
    modalVaga?.close();
  }

  void openModalCandidato() {
    if (item.idVaga == -1) {
      SimpleDialogComponent.showAlert('Selecione uma vaga primeiro!');
      return;
    }
    listaCandidato?.load();
    modalCandidato?.open();
  }

  void onSelectCandidato(Candidato candidato) {
    item.candidato = candidato;
    modalCandidato?.close();
  }

  void geraGuiaEncaminhamento() async {
    try {
      final bytes = await geraPDFGuiaEncaminhamento(item);
      FrontUtils.download(bytes, 'application/pdf', 'guia_encaminhamento.pdf');
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao gerar guia de encaminhamento',
          subMessage: '$e $s');
    }
  }

  void imprimirGuiaEncaminhamento() async {
    try {
      final bytes = await geraPDFGuiaEncaminhamento(item);
      await FrontUtils.printFileBytes(bytes, 'application/pdf');
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao gerar guia de encaminhamento',
          subMessage: '$e $s');
    }
  }
}
