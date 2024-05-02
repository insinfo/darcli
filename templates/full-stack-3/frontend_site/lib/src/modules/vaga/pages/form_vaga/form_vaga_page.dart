import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend_site/sibem_frontend_site.dart';
import 'package:sibem_frontend_site/src/modules/cargo/pages/lista_cargo/lista_cargo_page.dart';
import 'package:sibem_frontend_site/src/modules/conhecimento_extra/pages/lista_conhecimento_extra/lista_conhecimento_extra_page.dart';
import 'package:sibem_frontend_site/src/modules/curso/pages/lista_curso/lista_curso_page.dart';

@Component(
  selector: 'form-vaga-page',
  templateUrl: 'form_vaga_page.html',
  styleUrls: ['form_vaga_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    ListaCargoPage,
    ListaCursoPage,
    ListaConhecimentoExtraPage,
  ],
)
class FormVagaPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final VagaService _vagaService;
  final EscolaridadeService _scolaridadeService;
  final AuthService _authService;
  final Router _router;
  bool isNew = true;

  @ViewChild('modalCargo')
  CustomModalComponent? modalCargo;

  @ViewChild('listaCargo')
  ListaCargoPage? listaCargo;

  @ViewChild('modalConhecimentoExtra')
  CustomModalComponent? modalConhecimentoExtra;

  @ViewChild('listaConhecimentoExtra')
  ListaConhecimentoExtraPage? listaConhecimentoExtra;

  @ViewChild('modalBeneficio')
  CustomModalComponent? modalBeneficio;

  @ViewChild('modalCurso')
  CustomModalComponent? modalCurso;

  @ViewChild('listaCurso')
  ListaCursoPage? listaCurso;

  final html.Element hostElement;

  final Location _location;

  FormVagaPage(
      this.notificationComponentService,
      this.hostElement,
      this._vagaService,
      this._router,
      this._location,
      this._scolaridadeService,
      this._authService);

  var item = Vaga.invalid();

  DataFrame<Escolaridade> escolaridades = DataFrame<Escolaridade>.newClear();
  List<String> listaTipoVaga = listaTipoVagaSibem;
  List<String> listaTurno = listaTurnoSibem;
  List<String> listaFormaEncaminhamento = listaFormaEncaminhamentoSibem;
  DataFrame<Beneficio> listaBeneficio = DataFrame(
    items: Beneficio.listaBeneficio(),
    totalRecords: Beneficio.listaTipoBeneficio.length,
  );

  DatatableSettings dtBeneficioSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'nome', title: 'Nome'),
  ]);

  Future<void> getById(int id) async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show(target: hostElement);
      item = await _vagaService.getById(id);
    } catch (e, s) {
      print('FormVagaPage@getById $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  bool validateForm() {
    if (item.empregadorNome == null) {
      SimpleDialogComponent.showAlert(
          'O campo Empregador não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.cargoNome == null) {
      SimpleDialogComponent.showAlert(
          'O campo Cargo da vaga não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.exigeExperiencia == true && item.experienciaInformal == null) {
      SimpleDialogComponent.showAlert(
          'Se o campo "Exige experiência" for "Sim" o campo "Experiência Informal" é obrigatório!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.exigeExperiencia == true && item.aceitaExperienciaMei == null) {
      SimpleDialogComponent.showAlert(
          'Se o campo "Exige experiência" for "Sim" o campo "Aceita Experiência MEI" é obrigatório!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.exigeExperiencia == true && item.tempoMinimoExperiencia == null) {
      SimpleDialogComponent.showAlert(
          'Se o campo "Exige experiência" for "Sim" o campo "Tempo Minimo Experiência" é obrigatório!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    final now = DateTime.now();

    //TODO checar esta nessecidade
    if (isNew) {
      if (!item.dataAbertura.isDateEqual(now)) {
        print('now $now');
        print('item.dataAbertura ${item.dataAbertura}');

        if (item.dataAbertura.isBefore(now)) {
          SimpleDialogComponent.showAlert(
              'A "Data abertura" tem que ser superior ou igual a Data atual"',
              subMessage: 'Campo obrigatório!',
              dialogColor: DialogColor.DANGER,
              okAction: () {});
          return false;
        }
      }
    }

    if (item.confidencialidadeEmpresa == true &&
        item.contatoEncaminhamento == null) {
      SimpleDialogComponent.showAlert(
          'Se "Confidencialidade Empresa" for sim deverar preencher o campo "Contato de Encaminhamento"',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.dataEncerramento != null &&
        !item.dataEncerramento!.isDateEqual(item.dataAbertura) &&
        item.dataEncerramento!.isBefore(item.dataAbertura)) {
      SimpleDialogComponent.showAlert(
          'A "Data Encerramento" tem que ser superior a  "Data abertura"',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.numeroVagas < 1) {
      SimpleDialogComponent.showAlert(
          'O "Número de Vagas" tem que ser superior a 0"',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.numeroEncaminhamentos != null && item.numeroEncaminhamentos! < 1) {
      SimpleDialogComponent.showAlert(
          'O "Nº Maximo de Encaminhamentos" tem que ser superior a 0"',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.idEscolaridade == -1) {
      SimpleDialogComponent.showAlert(
          'O campo Escolaridade exigida da vaga não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.cursos.isNotEmpty &&
        item.cursos.where((cu) => cu.obrigatorio == null).isNotEmpty) {
      SimpleDialogComponent.showAlert(
          'O campo "Obrigatório?" dos Cursos Exigidos não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.conhecimentosExtras.isNotEmpty &&
        item.conhecimentosExtras
            .where((ce) => ce.obrigatorio == null)
            .isNotEmpty) {
      SimpleDialogComponent.showAlert(
          'O campo "Obrigatório?" dos Conhecimentos Extras não pode ficar vazio!',
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
        item.idEmpregador = _authService.authPayload.idPessoa!;
        item.isFromWeb = true;
        if (!validateForm()) {
          return;
        }
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }

        item.validado = false;

        if (isNew) {
          await _vagaService.insert(item);
        } else {
          await _vagaService.update(item);
        }
        notificationComponentService
            .notify('Vaga ${isNew ? 'cadastrado' : 'atualizado'} com sucesso.');

        _router.navigate(RoutePaths.listaVaga.toUrl());
      } catch (e, s) {
        print('FormVagaPage@load $e $s');
        SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
            subMessage: '$e $s');
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  Future<void> loadEscolaridades({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      escolaridades =
          await _scolaridadeService.all(Filters(limit: 100, offset: 0));
    } catch (e, s) {
      print('ListaEscolaridadePage@loadEscolaridades $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await loadEscolaridades();
    item.empregadorNome = _authService.authPayload.nome;

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

  void openModalCargo() {
    modalCargo?.open();
    listaCargo?.load();
  }

  void onSelectCargo(Cargo cargo) {
    item.idCargo = cargo.id;
    item.cargoNome = cargo.nome;
    modalCargo?.close();
  }

  void openModalBeneficio() {
    modalBeneficio?.open();
  }

  void onSelectBeneficio(Beneficio be) {
    if (item.beneficios.where((el) => el.nome == be.nome).isEmpty) {
      item.beneficios.add(be);
    }

    modalBeneficio?.close();
  }

  void rmBeneficio(Beneficio beneficio) {
    item.beneficios.removeWhere((item) => item.nome == beneficio.nome);
  }

  void openModalCurso() {
    listaCurso?.load();
    modalCurso?.open();
  }

  void onSelectCurso(Curso curso) {
    if (item.cursos.where((el) => el.nome == curso.nome).isEmpty) {
      item.cursos.add(curso);
    }
    modalCurso?.close();
  }

  void rmCurso(Curso curso) {
    item.cursos.removeWhere((item) => item.nome == curso.nome);
  }

  void openModalConhecimentoExtra() {
    listaConhecimentoExtra?.load();
    modalConhecimentoExtra?.open();
  }

  void onSelectConhecimentoExtra(ConhecimentoExtra conhecimentoExtra) {
    if (item.conhecimentosExtras
        .where((el) => el.nome == conhecimentoExtra.nome)
        .isEmpty) {
      item.conhecimentosExtras.add(conhecimentoExtra);
    }
    modalConhecimentoExtra?.close();
  }

  void rmConhecimentoExtra(ConhecimentoExtra conhecimentoExtra) {
    item.conhecimentosExtras
        .removeWhere((item) => item.nome == conhecimentoExtra.nome);
  }

  void onChangeSelectEscala(html.InputElement inputCargaHorariaSemanal) async {
    await Future.delayed(Duration(milliseconds: 200));
    if (item.escala) {
      inputCargaHorariaSemanal.disabled = true;
      item.cargaHorariaSemanal = null;
    } else {
      inputCargaHorariaSemanal.disabled = false;
    }
  }
}
