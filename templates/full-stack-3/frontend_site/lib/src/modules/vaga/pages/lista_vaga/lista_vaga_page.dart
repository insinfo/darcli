import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend_site/sibem_frontend_site.dart';

/// Listagem de vagas
@Component(
  selector: 'lista-vaga-page',
  templateUrl: 'lista_vaga_page.html',
  styleUrls: ['lista_vaga_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    NavbarComponent,
  ],
  exports: [LoginStatus],
)
class ListaVagaPage implements OnActivate {
  final NotificationComponentService notificationComponentService;

  final VagaService _vagaService;
  final AuthService authService;

  final ConhecimentoExtraService _conhecimentoExtraService;
  final CursoService _cursoService;
  final VagaBeneficioService _vagaBeneficioService;

  // ignore: unused_field
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @Input('filtroBloqueioEncaminhamento')
  set filtroBloqueioEncaminhamento(bool val) {
    filtro.bloqueioEncaminhamento = val;
  }

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;
  var itemSelected = Vaga.invalid();

  final filtro = Filters(limit: 50, offset: 0);

  @Input('limitPerPageOptions')
  List<int> limitPerPageOptions = [
    1,
    5,
    6,
    7,
    10,
    12,
    20,
    24,
    25,
    50,
    // 100,
    // 500,
    // 1000,
    // 2000
  ];

  ListaVagaPage(
      this.notificationComponentService,
      this.hostElement,
      this._vagaService,
      this._router,
      this.authService,
      this._conhecimentoExtraService,
      this._cursoService,
      this._vagaBeneficioService) {
    colsDefinitions = [
      DatatableCol(
          key: 'detalhe',
          title: '',
          customRenderHtml: (map, instance) {
            final vagaSel = (instance as Vaga);
            final div = html.DivElement();

            final btn = html.DivElement();
            btn.onClick.listen((e) async {
              exibeDetalhes(vagaSel);
            });
            btn.classes.addAll(
                ['badge', 'border', 'border-primary', 'text-primary', 'me-2']);
            btn.text = 'Detalhes';

            div.append(btn);
            return div;
          }),
      DatatableCol(
          key: 'bloqueioEncaminhamento',
          title: 'Bloqueada',
          format: DatatableFormat.bool),
      DatatableCol(key: 'cargoNome', title: 'Cargo'),
      DatatableCol(
          key: 'empregadorNome',
          title: 'Empregador',
          customRenderString: (map, instance) {
            final vaga = (instance as Vaga);
            return vaga.confidencialidadeEmpresa == true
                ? 'Não informado'
                : vaga.empregadorNome ?? '';
          }),
      DatatableCol(
          key: 'grauEscolaridade', title: 'Escolaridade', visibility: true),
      DatatableCol(
          key: 'cargaHorariaSemanal',
          title: 'Carga Horária Semanal',
          visibility: false),
      DatatableCol(
          key: 'numeroVagas', title: 'Número de Vagas', visibility: true),
      DatatableCol(
          key: 'vagaPcd', title: 'Vaga PNE', format: DatatableFormat.bool),
      DatatableCol(
          key: 'exigeExperiencia',
          title: 'Exige experiência',
          format: DatatableFormat.bool),
      DatatableCol(
        key: 'sexoBiologico',
        title: 'Sexo Biológico',
      ),
    ];

    dtSettings = DatatableSettings(colsDefinitions: colsDefinitions);
  }

  void exibeDetalhes(Vaga vagaSel) async {
    var message = '''<h4>Detalhes</h4>
                    Cargo: <span class="fw-bold">${vagaSel.cargoNome}  </span><br>
                    Empregador: <span class="fw-bold">${vagaSel.confidencialidadeEmpresa ? 'Não informado' : vagaSel.empregadorNome} </span><br>
                    Exige experiência: <span class="fw-bold">${vagaSel.exigeExperiencia == true ? 'Sim' : 'Não'} </span><br>
                    Tempo Minimo de Experiência: <span class="fw-bold">${vagaSel.tempoMinimoExperiencia ?? '0'} meses </span><br>
                    Tempo Maximo Experiência: <span class="fw-bold">${vagaSel.tempoMaximoExperiencia ?? 'Não definido'}  </span><br>                    
                    Aceita Experiência Informal: <span class="fw-bold">${vagaSel.experienciaInformal == true ? 'Sim' : 'Não'} </span><br>
                    Aceita Experiência MEI: <span class="fw-bold">${vagaSel.aceitaExperienciaMei == true ? 'Sim' : 'Não'} </span><br>
                    Identidade de Genero: <span class="fw-bold">${vagaSel.identidadeGenero ?? 'Não definido'} </span><br>
                    Idade Minima: <span class="fw-bold">${vagaSel.idadeMinima} </span><br>
                    Idade Maximo: <span class="fw-bold">${vagaSel.idadeMaxima ?? 'Não definido'} </span><br>
                    Data abertura: <span class="fw-bold">${vagaSel.dataAberturaFormatada} </span><br>
                    Data Encerramento: <span class="fw-bold">${vagaSel.dataEncerramentoFormatada ?? 'Não definido'} </span><br>
                    Número de Vagas: <span class="fw-bold">${vagaSel.numeroVagas} </span><br>
                    Sexo Biologico: <span class="fw-bold">${vagaSel.sexoBiologico} </span><br>
                    Vaga PCD: <span class="fw-bold">${vagaSel.vagaPcd == true ? 'Sim' : 'Não'} </span><br>
                    Aceita Fumante: <span class="fw-bold">${vagaSel.aceitaFumante != null ? vagaSel.aceitaFumante == true ? 'Sim' : 'Não' : 'Não definido'} </span><br>
                    Escolaridade: <span class="fw-bold">${vagaSel.grauEscolaridade} </span><br>
                    Tipo da Vaga: <span class="fw-bold">${vagaSel.tipoVaga} </span><br>
                    Escala: <span class="fw-bold">${vagaSel.escala == true ? 'Sim' : 'Não'} </span><br>
                    Carga Horaria Semanal: <span class="fw-bold">${vagaSel.cargaHorariaSemanal ?? 'Não definido'} </span><br>
                    Descrição carga horária: <span class="fw-bold">${vagaSel.descricaoCargaHoraria ?? 'Não definido'} </span><br>
                    Turno: <span class="fw-bold">${vagaSel.turno} </span><br>
                    Área Petróleo e Gás: <span class="fw-bold">${vagaSel.areaPetroleoGas == true ? 'Sim' : 'Não'} </span><br>
                    OffShore: <span class="fw-bold">${vagaSel.offShore == true ? 'Sim' : 'Não'} </span><br>
                    ''';
    final conhecimentosExtras = await loadConhecimentoExtra(vagaSel.id);
    if (conhecimentosExtras.isNotEmpty) {
      message += '<br><h5>Conhecimentos extras: </h5>';
      for (var conhe in conhecimentosExtras) {
        message +=
            '<span class=""> ${conhe.nome} ${conhe.obrigatorio == true ? ' - obrigatório' : ' - desejável'} </span><br>';
      }
    }

    final cursos = await loadCursos(vagaSel.id);
    if (conhecimentosExtras.isNotEmpty) {
      message += '<br><h5>Cursos:</h5>';
      for (var curso in cursos) {
        message +=
            '<span class=""> ${curso.nome} ${curso.obrigatorio == true ? ' - obrigatório' : ' - desejável'} </span><br>';
      }
    }

    final beneficios = await loadBeneficios(vagaSel.id);
    if (beneficios.isNotEmpty) {
      message += '<br><h5>Beneficios:</h5>';
      for (var beneficio in beneficios) {
        message +=
            '<span class=""> ${beneficio.nome} ${beneficio.valor ?? ''} </span><br>';
      }
    }

    SimpleDialogComponent.showAlert(message, title: 'Detalhes');
  }

  DataFrame<Vaga> items = DataFrame<Vaga>.newClear();

  late List<DatatableCol> colsDefinitions;

  late DatatableSettings dtSettings;

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(
        field: 'cargos.nome', operator: 'like', label: 'Cargo'),
    DatatableSearchField(
        field: 'pessoas.nome', operator: 'like', label: 'Empregador'),
    DatatableSearchField(
        field: 'escolaridades.nome', operator: 'like', label: 'Escolaridade'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Vaga>();

  @Output('onSelect')
  Stream<Vaga> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Vaga selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }

      items = await _vagaService.all(filtro);
    } catch (e, s) {
      print('ListaVagaPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<DataFrame<ConhecimentoExtra>> loadConhecimentoExtra(int idVaga,
      {bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      return await _conhecimentoExtraService
          .all(Filters(idVaga: idVaga, limit: 50));
    } catch (e, s) {
      print('ListaVagaPage@loadConhecimentoExtra $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
    return DataFrame<ConhecimentoExtra>.newClear();
  }

  Future<DataFrame<Curso>> loadCursos(int idVaga,
      {bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      return await _cursoService.all(Filters(idVaga: idVaga, limit: 50));
    } catch (e, s) {
      print('ListaVagaPage@loadCursos $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
    return DataFrame<Curso>.newClear();
  }

  Future<DataFrame<Beneficio>> loadBeneficios(int idVaga,
      {bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      return await _vagaBeneficioService
          .all(Filters(idVaga: idVaga, limit: 50));
    } catch (e, s) {
      print('ListaVagaPage@loadBeneficios $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
    return DataFrame<Beneficio>.newClear();
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    //verifica se esta logado

    // print(
    //     'ListaVagaPage@onActivate isEmpregador ${authService.authPayload.isEmpregador}');
    // print(
    //     'ListaVagaPage@onActivate isCandidato ${authService.authPayload.isCandidato}');
    if (authService.authPayload.isEmpregador &&
        authService.authPayload.jaCadastrado == true) {
      filtro.idEmpregador = authService.authPayload.idPessoa;
    } else if (authService.authPayload.isCandidato &&
        authService.authPayload.jaCadastrado == true) {
      filtro.cpfCandidato = authService.authPayload.login;
      //oculta coluna
      colsDefinitions.forEach((col) {
        if (col.key == 'bloqueioEncaminhamento') {
          col.visibility = false;
        }
      });
    } else {
      //oculta coluna
      colsDefinitions.forEach((col) {
        if (col.key == 'bloqueioEncaminhamento') {
          col.visibility = false;
        }
      });
    }

    load();
  }

  void setInputSearchFocus() {
    datatable?.setInputSearchFocus();
  }

  void changeFiltroVagasToPerfil(optionVal) {
    if (optionVal == 'true') {
      filtro.cpfCandidato = authService.authPayload.login;
    } else {
      filtro.cpfCandidato = null;
    }
    load();
  }

  void changeFiltroVagasToEmpregador(optionVal) {
    if (optionVal == 'true') {
      filtro.idEmpregador = authService.authPayload.idPessoa;
    } else {
      filtro.idEmpregador = null;
    }
    load();
  }

  bool get isEmpregadorValidado {
    return authService.authPayload.jaCadastrado == true &&
        authService.authPayload.isEmpregador;
  }

  bool get isCandidatoValidado {
    return authService.authPayload.jaCadastrado == true &&
        authService.authPayload.isCandidato;
  }

  void editarVagaSelected() {
    final selected = datatable!.getAllSelected<Vaga>();
    if (selected.length > 1) {
      SimpleDialogComponent.showAlert('Selecione apenas uma vaga para edição');
      return;
    }
    if (selected.isEmpty) {
      SimpleDialogComponent.showAlert('Selecione uma vaga para edição');
      return;
    }
    if (authService.authPayload.idPessoa != selected.first.idEmpregador) {
      SimpleDialogComponent.showAlert('Você so pode editar suas vagas');
      return;
    }

    _router.navigate(RoutePaths.formVaga
        .toUrl(parameters: {'id': selected.first.id.toString()}));
  }
}
