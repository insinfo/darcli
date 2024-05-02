import 'dart:async';
import 'dart:html' as html;
import 'package:sibem_frontend/sibem_frontend.dart';
import 'package:sibem_frontend/src/modules/cargo/pages/lista_cargo/lista_cargo_page.dart';
import 'package:sibem_frontend/src/modules/conhecimento_extra/pages/lista_conhecimento_extra/lista_conhecimento_extra_page.dart';
import 'package:sibem_frontend/src/modules/curso/pages/lista_curso/lista_curso_page.dart';

@Component(
  selector: 'form-candidato-page',
  templateUrl: 'form_candidato_page.html',
  styleUrls: ['form_candidato_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    ListaCursoPage,
    ListaConhecimentoExtraPage,
    ListaCargoPage,
  ],
)
class FormCandidatoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final CandidatoService _candidatoService;
  final UfService _ufService;
  final MunicipioService _municipioService;
  final EscolaridadeService _scolaridadeService;
  final TipoDeficienciaService _tipoDeficienciaService;

  final CursoService _cursoService;
  final ConhecimentoExtraService _conhecimentoExtraService;

  final Router _router;
  bool isNew = true;
  final Location _location;
  final html.Element hostElement;

  var item = Candidato.invalid();
  DataFrame<Uf> ufs = DataFrame<Uf>.newClear();
  DataFrame<Municipio> municipios = DataFrame<Municipio>.newClear();
  List<String> tiposLogradoouro = listaTiposLogradouroPmro;
  List<String> tiposEndereco = listaTipoEnderecoPmro;
  DataFrame<Escolaridade> escolaridades = DataFrame<Escolaridade>.newClear();
  DataFrame<TipoDeficiencia> tiposDeficiencia =
      DataFrame<TipoDeficiencia>.newClear();

  @ViewChild('modalCurso')
  CustomModalComponent? modalCurso;

  @ViewChild('listaCurso')
  ListaCursoPage? listaCurso;

  @ViewChild('listaConhecimentoExtra')
  ListaConhecimentoExtraPage? listaConhecimentoExtra;

  @ViewChild('modalConhecimentoExtra')
  CustomModalComponent? modalConhecimentoExtra;

  @ViewChild('modalCargo')
  CustomModalComponent? modalCargo;

  @ViewChild('listaCargo')
  ListaCargoPage? listaCargo;

  Future<void> loadUfs() async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show(target: hostElement);
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
      simpleLoading.show(target: hostElement);
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
        simpleLoading.show(target: hostElement);
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

  FormCandidatoPage(
      this.notificationComponentService,
      this.hostElement,
      this._candidatoService,
      this._router,
      this._location,
      this._ufService,
      this._municipioService,
      this._scolaridadeService,
      this._tipoDeficienciaService,
      this._cursoService,
      this._conhecimentoExtraService);

  Future<void> getById(int id) async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show(target: hostElement);
      var cand = await _candidatoService.getById(id);
      if (cand.enderecos.isNotEmpty && cand.enderecos.first.idUf != null) {
        await loadMunicipio(idUf: cand.enderecos.first.idUf!);
      }
      // se não tiver complemento Pessoa Fisica
      cand.complementoPessoaFisica ??= ComplementoPessoaFisica(idPessoa: -1);

      item = cand;
    } catch (e, s) {
      print('FormCandidatoPage@getById $e $s');
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
    print(
        'item.dataInicialResidenciaAtual ${item.dataInicialResidenciaAtual.year}');
    if (item.dataInicialResidenciaAtual.year == 1700) {
      SimpleDialogComponent.showAlert('Data Inicial Residencia Atual invalida!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (item.dataNascimento.year == 1700) {
      SimpleDialogComponent.showAlert('Data Nascimento invalida!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.complementoPessoaFisica!.idEscolaridade == -1) {
      SimpleDialogComponent.showAlert(
          'O campo Escolaridade não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.telefones.where((tel) => tel.numero.trim().isEmpty).isNotEmpty) {
      SimpleDialogComponent.showAlert('Telefone não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.enderecos
        .where((end) => end.logradouro.trim().isEmpty)
        .isNotEmpty) {
      SimpleDialogComponent.showAlert('Logradouro não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.enderecos
        .where(
            (end) => end.numero == null || end.numero?.trim().isEmpty == true)
        .isNotEmpty) {
      SimpleDialogComponent.showAlert('Número não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.enderecos
        .where((end) =>
            end.nomeBairro == null || end.nomeBairro?.trim().isEmpty == true)
        .isNotEmpty) {
      SimpleDialogComponent.showAlert('Bairro não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.cargosDesejados.isEmpty) {
      SimpleDialogComponent.showAlert(
          'Cargos Desejados não pode ficar vazio, deve haver pelo menos um Cargo!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.cargosDesejados
        .where((cargo) => cargo.experiencia == null)
        .isNotEmpty) {
      SimpleDialogComponent.showAlert('Experiência não pode ficar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (item.cargosDesejados.isNotEmpty) {
      for (final cargo in item.cargosDesejados) {
        if (cargo.experiencia == true) {
          if (cargo.tempoExperienciaFormal == null &&
              cargo.tempoExperienciaInformal == null &&
              cargo.tempoExperienciaMei == null) {
            SimpleDialogComponent.showAlert(
                'Se "Experiência" do Crago ${cargo.nome} for ao menos um campo de tempo de Experiência tem que ser preenchido!',
                subMessage: 'Campo obrigatório!',
                dialogColor: DialogColor.DANGER,
                okAction: () {});
            return false;
          }
        }
      }
    }

    // if (item.cargosDesejados.isNotEmpty) {
    //   for (final cargo in item.cargosDesejados) {
    //     if (cargo.experiencia == true &&
    //         cargo.tempoExperienciaInformal == null) {
    //       SimpleDialogComponent.showAlert(
    //           'Se "Experiência" do Crago ${cargo.nome} for sim não pode ficar vazio o campo "Tempo Experiência Informal"!',
    //           subMessage: 'Campo obrigatório!',
    //           dialogColor: DialogColor.DANGER,
    //           okAction: () {});
    //       return false;
    //     }
    //   }
    //}

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
          await _candidatoService.insert(item);
        } else {
          await _candidatoService.update(item);
        }
        notificationComponentService.notify(
            'Candidato ${isNew ? 'cadastrado' : 'atualizado'} com sucesso.');

        _router.navigate(RoutePaths.listaCandidato.toUrl());
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

  Future<void> loadDeficiencias({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
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

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await loadUfs();
    await loadEscolaridades();
    await loadDeficiencias();
    final idParam = current.parameters['id'];
    final isWeb = current.queryParameters['isWeb'];
    final id = idParam == null ? null : int.tryParse(idParam);

    if (idParam == 'new') {
      if (isWeb == 'true' && RoutePaths.areaTransferencia is CandidatoWeb) {
        loadFromCandidatoWeb();
      } else {
        await loadMunicipio();
        item = Candidato.invalid();
      }
      isNew = true;
    } else if (id != null) {
      isNew = false;
      await getById(id);
    }
  }

  void loadFromCandidatoWeb() async {
    if (RoutePaths.areaTransferencia is CandidatoWeb) {
      final candidatoWeb = RoutePaths.areaTransferencia as CandidatoWeb;
      print('loadFromCandidatoWeb candidatoWeb.idUf ${candidatoWeb.idUf}');
      print(
          'loadFromCandidatoWeb candidatoWeb.idMunicipio ${candidatoWeb.idMunicipio}');
      await loadMunicipio(idUf: candidatoWeb.idUf);

      //await Future.delayed(Duration(milliseconds: 2000));

      item.isFromWeb = true;
      item.cpf = candidatoWeb.cpf;
      item.nome = candidatoWeb.nome;
      item.rg = candidatoWeb.rg;
      item.dataEmissao = candidatoWeb.dataEmissao;
      item.orgaoEmissor = candidatoWeb.orgaoEmissor;
      item.idUfOrgaoEmissor = candidatoWeb.idUfOrgaoEmissor;
      item.sexo = candidatoWeb.sexoBiologico;
      item.identidadeGenero = candidatoWeb.identidadeGenero;
      item.estadoCivil = candidatoWeb.estadoCivil;
      item.dataNascimento = candidatoWeb.dataNascimento;
      item.pis = candidatoWeb.pis;
      item.emailPrincipal = candidatoWeb.emailPrincipal;
      item.dataInicialResidenciaRO = candidatoWeb.dataInicialResidenciaRO;
      item.dataInicialResidenciaAtual = candidatoWeb.dataInicialResidenciaAtual;
      item.rendaFamiliar = candidatoWeb.rendaFamiliar;
      item.referenciaPessoal = candidatoWeb.referenciaPessoal;
      item.fumante = candidatoWeb.fumante;

      item.complementoPessoaFisica!.idEscolaridade =
          candidatoWeb.idEscolaridade;
      //print('complementoPessoaFisica ${item.complementoPessoaFisica!.idEscolaridade}');
      item.complementoPessoaFisica!.nrCarteiraProfissional =
          candidatoWeb.nrCarteiraProfissional;
      item.complementoPessoaFisica!.nrSerieCarteiraProfissional =
          candidatoWeb.nrSerieCarteiraProfissional;
      item.complementoPessoaFisica!.nrDependentes = candidatoWeb.nrDependentes;
      item.complementoPessoaFisica!.categoriaHabilitacao =
          candidatoWeb.categoriaHabilitacao;
      item.complementoPessoaFisica!.nrTituloEleitor =
          candidatoWeb.nrTituloEleitor;
      item.complementoPessoaFisica!.zonaTituloEleitor =
          candidatoWeb.zonaTituloEleitor;
      //item.complementoPessoaFisica?.secaoTituloEleitor = candidatoWeb.secaoTituloEleitor;
      item.complementoPessoaFisica!.nrCertificadoReservista =
          candidatoWeb.nrCertificadoReservista;
      item.complementoPessoaFisica!.deficiente = candidatoWeb.deficiente;
      item.complementoPessoaFisica!.cid = candidatoWeb.cid;
      item.complementoPessoaFisica!.idTipoDeficiencia =
          candidatoWeb.idTipoDeficiencia;
      // telefones
      item.telefones = [
        Telefone(
            id: -1,
            idPessoa: -1,
            tipo: candidatoWeb.tipoTelefone,
            numero: candidatoWeb.telefone)
      ];

      print('candidatoWeb.tipoTelefone ${candidatoWeb.tipoTelefone}');

      // enderecos
      item.enderecos = [
        Endereco(
          cep: candidatoWeb.cep,
          tipo: candidatoWeb.tipoEndereco,
          //33 BRASIL
          idPais: 33,
          //20 RIO DE JANEIRO
          idUf: candidatoWeb.idUf,
          //3242 city
          idMunicipio: candidatoWeb.idMunicipio,
          tipoLogradouro: candidatoWeb.tipoLogradouro,
          logradouro: candidatoWeb.logradouro,
          numero: candidatoWeb.numeroEndereco,
          nomeBairro: candidatoWeb.bairro,
          complemento: candidatoWeb.complementoEndereco,
          validacao: false,
        )
      ];

      print('item.enderecos ${item.enderecos}');
      print('item.enderecos idUf ${item.enderecos.first.idUf}');
      print('item.enderecos idMunicipio ${item.enderecos.first.idMunicipio}');

      item.cargosDesejados = [
        Cargo(
          nome: candidatoWeb.nomeCargo1!,
          id: candidatoWeb.idCargo1!,
          experiencia: candidatoWeb.experienciaCargo1,
          tempoExperienciaFormal: candidatoWeb.tempoExperienciaFormal1,
          tempoExperienciaInformal: candidatoWeb.tempoExperienciaInformal1,
          tempoExperienciaMei: candidatoWeb.tempoExperienciaMei1,
        )
      ];

      if (candidatoWeb.idCargo2 != null && candidatoWeb.nomeCargo2 != null) {
        item.cargosDesejados.add(
          Cargo(
            nome: candidatoWeb.nomeCargo2!,
            id: candidatoWeb.idCargo2!,
            experiencia: candidatoWeb.experienciaCargo2,
            tempoExperienciaFormal: candidatoWeb.tempoExperienciaFormal2,
            tempoExperienciaInformal: candidatoWeb.tempoExperienciaInformal2,
            tempoExperienciaMei: candidatoWeb.tempoExperienciaMei2,
          ),
        );
      }

      if (candidatoWeb.idCargo3 != null && candidatoWeb.nomeCargo3 != null) {
        item.cargosDesejados.add(
          Cargo(
            nome: candidatoWeb.nomeCargo3!,
            id: candidatoWeb.idCargo3!,
            experiencia: candidatoWeb.experienciaCargo3,
            tempoExperienciaFormal: candidatoWeb.tempoExperienciaFormal3,
            tempoExperienciaInformal: candidatoWeb.tempoExperienciaInformal3,
            tempoExperienciaMei: candidatoWeb.tempoExperienciaMei3,
          ),
        );
      }

      if (candidatoWeb.idCurso1 != null) {
        final curso = await getCursoById(candidatoWeb.idCurso1!);
        if (curso != null) {
          curso.dataConclusao = candidatoWeb.dataConclusaoCurso1;
          item.cursos.add(curso);
        }
      }
      if (candidatoWeb.idCurso2 != null) {
        final curso = await getCursoById(candidatoWeb.idCurso2!);
        if (curso != null) {
          curso.dataConclusao = candidatoWeb.dataConclusaoCurso2;
          item.cursos.add(curso);
        }
      }
      if (candidatoWeb.idCurso3 != null) {
        final curso = await getCursoById(candidatoWeb.idCurso3!);
        if (curso != null) {
          curso.dataConclusao = candidatoWeb.dataConclusaoCurso3;
          item.cursos.add(curso);
        }
      }
      if (candidatoWeb.idCurso4 != null) {
        final curso = await getCursoById(candidatoWeb.idCurso4!);
        if (curso != null) {
          curso.dataConclusao = candidatoWeb.dataConclusaoCurso4;
          item.cursos.add(curso);
        }
      }
      if (candidatoWeb.idCurso5 != null) {
        final curso = await getCursoById(candidatoWeb.idCurso5!);
        if (curso != null) {
          curso.dataConclusao = candidatoWeb.dataConclusaoCurso5;
          item.cursos.add(curso);
        }
      }
      if (candidatoWeb.idCurso6 != null) {
        final curso = await getCursoById(candidatoWeb.idCurso6!);
        if (curso != null) {
          curso.dataConclusao = candidatoWeb.dataConclusaoCurso6;
          item.cursos.add(curso);
        }
      }

      if (candidatoWeb.idConhecimentoExtra1 != null) {
        final conhecimentoExtra =
            await getConhecimentoExtraById(candidatoWeb.idConhecimentoExtra1!);
        if (conhecimentoExtra != null) {
          conhecimentoExtra.nivelConhecimento =
              candidatoWeb.conhecimentoExtraNivel1;
          item.conhecimentosExtras.add(conhecimentoExtra);
        }
      }

      if (candidatoWeb.idConhecimentoExtra2 != null) {
        final conhecimentoExtra =
            await getConhecimentoExtraById(candidatoWeb.idConhecimentoExtra2!);
        if (conhecimentoExtra != null) {
          conhecimentoExtra.nivelConhecimento =
              candidatoWeb.conhecimentoExtraNivel2;
          item.conhecimentosExtras.add(conhecimentoExtra);
        }
      }

      if (candidatoWeb.idConhecimentoExtra3 != null) {
        final conhecimentoExtra =
            await getConhecimentoExtraById(candidatoWeb.idConhecimentoExtra3!);
        if (conhecimentoExtra != null) {
          conhecimentoExtra.nivelConhecimento =
              candidatoWeb.conhecimentoExtraNivel3;
          item.conhecimentosExtras.add(conhecimentoExtra);
        }
      }

      if (candidatoWeb.idConhecimentoExtra4 != null) {
        final conhecimentoExtra =
            await getConhecimentoExtraById(candidatoWeb.idConhecimentoExtra4!);
        if (conhecimentoExtra != null) {
          conhecimentoExtra.nivelConhecimento =
              candidatoWeb.conhecimentoExtraNivel4;
          item.conhecimentosExtras.add(conhecimentoExtra);
        }
      }

      //limpa a area de Transferencia
      RoutePaths.areaTransferencia = null;
    }
  }

  Future<Curso?> getCursoById(int idCurso) async {
    final loading = SimpleLoading();
    try {
      loading.show();
      final result = await _cursoService.getById(idCurso);
      return result;
    } catch (e, s) {
      print('falha ao obter curso $e $s');
    } finally {
      loading.hide();
    }
    return null;
  }

  Future<ConhecimentoExtra?> getConhecimentoExtraById(
      int idConhecimentoExtra) async {
    final loading = SimpleLoading();
    try {
      loading.show();
      final result =
          await _conhecimentoExtraService.getById(idConhecimentoExtra);
      return result;
    } catch (e, s) {
      print('falha ao obter Conhecimento Extra $e $s');
    } finally {
      loading.hide();
    }
    return null;
  }

  void back() {
    _location.back();
  }

  void addTelefone() {
    if (item.telefones.length < 3) {
      item.telefones.add(Telefone.invalid());
    }
  }

  void rmTelefone(Telefone tel) {
    if (item.telefones.length > 1) {
      item.telefones.remove(tel);
    }
  }

  void addEndereco() {
    if (item.enderecos.isEmpty) {
      item.enderecos.add(Endereco.invalid());
    }
  }

  void rmEndereco(Endereco end) {
    if (item.enderecos.length > 1) {
      item.enderecos.remove(end);
    }
  }

  void onUfChanged(Endereco endereco, int idUf) {
    endereco.idMunicipio = -1;
    loadMunicipio(idUf: idUf);
  }

  // curso
  void openModalCurso() {
    //print('openModalCurso item.cursos.length ${item.cursos.length }');
    if(item.cursos.length > 5){
      SimpleDialogComponent.showAlert('Você só pode adicionar no máximo 6 cursos!');
      return;
    }
    listaCurso?.load();
    modalCurso?.open();
  }

  void onSelectCurso(Curso curso) {
    if (item.cursos.where((el) => el.id == curso.id).isEmpty) {
      item.cursos.add(curso);
    }
    modalCurso?.close();
  }

  void rmCurso(Curso curso) {
    item.cursos.removeWhere((item) => item.id == curso.id);
  }

  // Conhecimento Extra
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
        .removeWhere((item) => item.id == conhecimentoExtra.id);
  }

  // Cargo
  void openModalCargo() {
    modalCargo?.open();
    listaCargo?.load();
  }

  void onSelectCargo(Cargo cargo) {
    if (item.cargosDesejados.where((el) => el.nome == cargo.nome).isEmpty) {
      item.cargosDesejados.add(cargo);
    }

    modalCargo?.close();
  }

  void rmCargo(Cargo cargo) {
    item.cargosDesejados.removeWhere((item) => item.id == cargo.id);
  }
}
