import 'package:sibem_frontend_site/sibem_frontend_site.dart';

import 'package:sibem_frontend_site/src/modules/cargo/pages/lista_cargo/lista_cargo_page.dart';
import 'package:sibem_frontend_site/src/modules/conhecimento_extra/pages/lista_conhecimento_extra/lista_conhecimento_extra_page.dart';
import 'package:sibem_frontend_site/src/modules/curso/pages/lista_curso/lista_curso_page.dart';

@Component(
  selector: 'form-candidato-web-page',
  templateUrl: 'form_candidato_web_page.html',
  styleUrls: ['form_candidato_web_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    routerDirectives,
    FooterComponent,
    ListaCargoPage,
    ListaCursoPage,
    ListaConhecimentoExtraPage,
    CustomModalComponent,
  ],
  exports: [RoutePaths, Routes],
)
class FormCandidatoWebPage implements OnActivate {
  final UfService _ufService;
  final MunicipioService _municipioService;
  final EscolaridadeService _scolaridadeService;
  final TipoDeficienciaService _tipoDeficienciaService;
  final CandidatoWebService _candidatoService;
  final AuthService authService;

  FormCandidatoWebPage(
      this._ufService,
      this._municipioService,
      this._scolaridadeService,
      this._tipoDeficienciaService,
      this._candidatoService,
      this.authService);

  var item = CandidatoWeb.invalid();
  var step = 0;

  DataFrame<Uf> ufs = DataFrame<Uf>.newClear();
  DataFrame<Municipio> municipios = DataFrame<Municipio>.newClear();
  List<String> tiposLogradoouro = listaTiposLogradouroPmro;
  List<String> tiposEndereco = listaTipoEnderecoPmro;
  DataFrame<Escolaridade> escolaridades = DataFrame<Escolaridade>.newClear();
  DataFrame<TipoDeficiencia> tiposDeficiencia =
      DataFrame<TipoDeficiencia>.newClear();

  @ViewChild('modalCargo')
  CustomModalComponent? modalCargo;

  @ViewChild('listaCargo')
  ListaCargoPage? listaCargo;

  @ViewChild('modalCurso')
  CustomModalComponent? modalCurso;

  @ViewChild('listaCurso')
  ListaCursoPage? listaCurso;

  @ViewChild('modalConhecimentoExtra')
  CustomModalComponent? modalConhecimentoExtra;

  @ViewChild('listaConhecimentoExtra')
  ListaConhecimentoExtraPage? listaConhecimentoExtra;

  int currentCargoIdx = -1;
  int currentCursoIdx = -1;
  int currentConhecimentoExtraIdx = -1;

  void onUfChanged(int idUf) {
    item.idMunicipio = -1;
    loadMunicipio(idUf: idUf);
  }

  bool validateForm() {
    print('''item.tempoExperienciaFormal1 ${item.tempoExperienciaFormal1}  
    item.tempoExperienciaInformal1 ${item.tempoExperienciaInformal1}
    item.tempoExperienciaMei1 ${item.tempoExperienciaMei1}''');

    if (item.nomeCargo1 != null && item.experienciaCargo1 == true) {
      if (item.tempoExperienciaFormal1 == null &&
          item.tempoExperienciaInformal1 == null &&
          item.tempoExperienciaMei1 == null) {
        //
        SimpleDialogComponent.showAlert(
            'Se experiência do Cargo 1 for "sim" uns dos campos "Tempo Experiência..." dever ser preenchido!',
            subMessage: 'Campo obrigatório!',
            dialogColor: DialogColor.DANGER,
            okAction: () {});
        return false;
      }
    }

    if (item.nomeCargo2 != null && item.experienciaCargo2 == true) {
      if (item.tempoExperienciaFormal2 == null &&
          item.tempoExperienciaInformal2 == null &&
          item.tempoExperienciaMei2 == null) {
        //
        SimpleDialogComponent.showAlert(
            'Se experiência do Cargo 2 for "sim" uns dos campos "Tempo Experiência..." dever ser preenchido!',
            subMessage: 'Campo obrigatório!',
            dialogColor: DialogColor.DANGER,
            okAction: () {});
        return false;
      }
    }

    if (item.nomeCargo3 != null && item.experienciaCargo3 == true) {
      if (item.tempoExperienciaFormal3 == null &&
          item.tempoExperienciaInformal3 == null &&
          item.tempoExperienciaMei3 == null) {
        //
        SimpleDialogComponent.showAlert(
            'Se experiência do Cargo 3 for "sim" uns dos campos "Tempo Experiência..." dever ser preenchido!',
            subMessage: 'Campo obrigatório!',
            dialogColor: DialogColor.DANGER,
            okAction: () {});
        return false;
      }
    }

    if (item.nome.trim().length < 3) {
      SimpleDialogComponent.showAlert(
          'O nome não pode ficar vazio e deve ter pelo menos 3 caracteres!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (item.dataInicialResidenciaAtual.year == 1700) {
      SimpleDialogComponent.showAlert('Data Inicial Residencia Atual invalida!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (item.dataNascimento.year == 1700) {
      SimpleDialogComponent.showAlert('Data Nascimento é invalida!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (item.idEscolaridade == -1) {
      SimpleDialogComponent.showAlert('Data Nascimento é invalida!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.nomeCargo1 == null) {
      SimpleDialogComponent.showAlert('O campo Cargo 1 é obrigatorio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.experienciaCargo1 == null) {
      SimpleDialogComponent.showAlert(
          'O campo experiência do Cargo 1 é obrigatorio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    return true;
  }

  Future<void> checkCadastro(NgForm checkForm) async {
    var isValid = true;
    for (var control in checkForm.form!.controls.values) {
      control.markAsTouched();
      control.updateValueAndValidity();
      //so checa se é valido os campos com a directiva customRequired ignorando os campos com a directiva cpfValidator
      if (control.errors != null &&
          control.errors!['validator'] == 'customRequired') {
        isValid = false;
      }
    }

    if (isValid == false) {
      focusFirstInvalidFields(checkForm);
    } else {
      final simpleLoading = SimpleLoading();
      simpleLoading.show();
      try {
        final cand = await _candidatoService.getByCpf(item.cpf);
        if (cand.validado == true) {
          SimpleDialogComponent.showAlert('Você já fez o seu Pre-cadastro!');
        } else {
          SimpleDialogComponent.showAlert(
              'Seu pré-cadastro já foi feito e está aguardando você comparecer no Banco de Empregos para finalizá-lo!');
        }
      } on NotFoundException {
        step = 1;
      } catch (e, s) {
        print('FormCandidatoPage@load $e $s');
        SimpleDialogComponent.showAlert('Falha ao verificar o CPF',
            subMessage: '$e');
      } finally {
        simpleLoading.hide();
      }
    }
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
          simpleLoading.show();
        }

        // if (item.idCargo1 != null) {
        //   item.tempoExperienciaFormal1 ??= 0;
        //   item.tempoExperienciaInformal1 ??= 0;
        //   item.tempoExperienciaMei1 ??= 0;
        // }
        // if (item.idCargo2 != null) {
        //   item.tempoExperienciaFormal2 ??= 0;
        //   item.tempoExperienciaInformal2 ??= 0;
        //   item.tempoExperienciaMei2 ??= 0;
        // }
        // if (item.idCargo3 != null) {
        //   item.tempoExperienciaFormal3 ??= 0;
        //   item.tempoExperienciaInformal3 ??= 0;
        //   item.tempoExperienciaMei3 ??= 0;
        // }

        await _candidatoService.insert(item);
        step = 2;
      } catch (e, s) {
        print('FormCandidatoPage@load $e $s');
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
    await loadUfs();
    await loadMunicipio();
    await loadEscolaridades();
    await loadDeficiencias();
    item.cpf = authService.authPayload.login;
    item.nome = authService.authPayload.nome;
    //item.telefone = authService.authPayload.telefone;
    //item.emailPrincipal = authService.authPayload.emailPrincipal;
  }

  Future<void> loadUfs() async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show();
      ufs = await _ufService.all(Filters(limit: 30));
    } catch (e, s) {
      print('FormCandidatoPage@loadUfs $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  /// idUf = 20 = Rio de Janeiro
  Future<void> loadMunicipio({int idUf = 20}) async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show();
      //, idUf: idUf
      municipios = await _municipioService.getAllByIdUf(idUf);
    } catch (e, s) {
      print('FormCandidatoPage@loadMunicipio $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> loadEscolaridades({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show();
      }
      escolaridades =
          await _scolaridadeService.all(Filters(limit: 100, offset: 0));
    } catch (e, s) {
      print('FormCandidatoPage@loadEscolaridades $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> loadDeficiencias({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show();
      }
      tiposDeficiencia = await _tipoDeficienciaService.all(Filters(limit: 100));
    } catch (e, s) {
      print('FormCandidatoPage@loadDeficiencias $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  void openModalCargo(int cargoIdx) {
    currentCargoIdx = cargoIdx;
    modalCargo?.open();
    listaCargo?.datatable?.setInputSearchFocus();
    listaCargo?.load();
  }

  void onSelectCargo(Cargo cargo) {
    final currentCargos = [item.idCargo1, item.idCargo2, item.idCargo3];
    if (currentCargos.contains(cargo.id)) {
      SimpleDialogComponent.showAlert('Este cargo ja foi adicionado');
      return;
    }
    switch (currentCargoIdx) {
      case 1:
        item.idCargo1 = cargo.id;
        item.nomeCargo1 = cargo.nome;
        break;
      case 2:
        item.idCargo2 = cargo.id;
        item.nomeCargo2 = cargo.nome;
        break;
      case 3:
        item.idCargo3 = cargo.id;
        item.nomeCargo3 = cargo.nome;
        break;
    }
    modalCargo?.close();
  }

  void openModalCurso(int cursoIdx) {
    currentCursoIdx = cursoIdx;
    modalCurso?.open();
    listaCurso?.datatable?.setInputSearchFocus();
    listaCurso?.load();
  }

  void onSelectCurso(Curso curso) {
    final currentCursos = [
      item.idCurso1,
      item.idCurso2,
      item.idCurso3,
      item.idCurso4,
      item.idCurso5,
      item.idCurso6
    ];
    if (currentCursos.contains(curso.id)) {
      SimpleDialogComponent.showAlert('Este curso ja foi adicionado');
      return;
    }

    switch (currentCursoIdx) {
      case 1:
        item.idCurso1 = curso.id;
        item.nomeCurso1 = curso.nome;
        break;
      case 2:
        item.idCurso2 = curso.id;
        item.nomeCurso2 = curso.nome;
        break;
      case 3:
        item.idCurso3 = curso.id;
        item.nomeCurso3 = curso.nome;
        break;
      case 4:
        item.idCurso4 = curso.id;
        item.nomeCurso4 = curso.nome;
        break;
      case 5:
        item.idCurso5 = curso.id;
        item.nomeCurso5 = curso.nome;
        break;
      case 6:
        item.idCurso6 = curso.id;
        item.nomeCurso6 = curso.nome;
        break;
    }
    modalCurso?.close();
  }

  void openConhecimentoExtra(int cursoIdx) {
    currentConhecimentoExtraIdx = cursoIdx;
    modalConhecimentoExtra?.open();
    listaConhecimentoExtra?.datatable?.setInputSearchFocus();
    listaConhecimentoExtra?.load();
  }

  void onSelectConhecimentoExtra(ConhecimentoExtra conheExtra) {
    final currentConhecimentosExtras = [
      item.idConhecimentoExtra1,
      item.idConhecimentoExtra2,
      item.idConhecimentoExtra3,
      item.idConhecimentoExtra4
    ];
    if (currentConhecimentosExtras.contains(conheExtra.id)) {
      SimpleDialogComponent.showAlert(
          'Este Conhecimento Extra ja foi adicionado');
      return;
    }
    switch (currentConhecimentoExtraIdx) {
      case 1:
        item.idConhecimentoExtra1 = conheExtra.id;
        item.nomeConhecimentoExtra1 = conheExtra.nome;
        break;
      case 2:
        item.idConhecimentoExtra2 = conheExtra.id;
        item.nomeConhecimentoExtra2 = conheExtra.nome;
        break;
      case 3:
        item.idConhecimentoExtra3 = conheExtra.id;
        item.nomeConhecimentoExtra3 = conheExtra.nome;
        break;
      case 4:
        item.idConhecimentoExtra4 = conheExtra.id;
        item.nomeConhecimentoExtra4 = conheExtra.nome;
        break;
    }
    modalConhecimentoExtra?.close();
  }
}
