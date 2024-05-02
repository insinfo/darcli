import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';
import 'package:sibem_frontend/src/modules/vaga/pages/lista_vaga/lista_vaga_page.dart';

/// Listagem de candidato
@Component(
  selector: 'lista-candidato-page',
  templateUrl: 'lista_candidato_page.html',
  styleUrls: ['lista_candidato_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    ListaVagaPage,
  ],
)
class ListaCandidatoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final CandidatoService _candidatoService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  @ViewChild('modalVaga')
  CustomModalComponent? modalVaga;

  @ViewChild('listaVaga')
  ListaVagaPage? listaVaga;

  final filtro = Filters(limit: 12, offset: 0);

  /// filtrar candidatos que coincidem com a vaga
  @Input('filtroIdVaga')
  set filtroIdVaga(int? val) {
    filtro.idVaga = val;
  }

  void onChangeMatchFiltro() async {
    if (filtro.idVaga != null) {
      await Future.delayed(Duration(milliseconds: 100));
      //print('onChangeMatchFiltro ${filtro.matchCargo}');
      load();
    }
  }

  /// abilita todos os match de candidato-vaga
  void enableAllVagaMatch() {
    filtro.matchCargo = true;
    filtro.matchEscolaridade = true;
    filtro.matchFumante = true;
    filtro.matchExperiencia = true;
    filtro.matchIdade = true;
    filtro.matchPcd = true;
    filtro.matchSexo = true;
    filtro.matchGenero = true;
    filtro.matchConhecimentosExtras = true;
    filtro.matchCurso = true;
    filtro.matchValidadeCadastro = true;
  }

  /// limpa os filtros
  void clearFiltros() {
    filtro.nomeVaga = null;
    filtro.idVaga = null;
    filtro.matchCargo = null;
    filtro.matchEscolaridade = null;
    filtro.matchFumante = null;
    filtro.matchExperiencia = null;
    filtro.matchIdade = null;
    filtro.matchCurso = null;
    filtro.matchPcd = null;
    filtro.matchSexo = null;
    filtro.matchGenero = null;
    filtro.matchConhecimentosExtras = null;
    //filtro.matchValidadeCadastro = null;
    load();
  }

  final html.Element hostElement;

  List<DatatableCol> dtColsDefinitions = [];
  late DatatableSettings dtSettings;

  ListaCandidatoPage(this.notificationComponentService, this.hostElement,
      this._candidatoService, this._router) {
    dtColsDefinitions = [
      DatatableCol(
          key: 'idCandidato',
          title: 'Id',
          sortingBy: 'idCandidato',
          enableSorting: true,
          visibility: false),
      DatatableCol(
          key: 'isFromWeb',
          title: 'WEB',
          visibility: true,
          format: DatatableFormat.bool),
      DatatableCol(
          key: 'idPessoaFisica',
          title: 'Id Pessoa',
          sortingBy: 'idPessoaFisica',
          enableSorting: true,
          visibility: false),
      DatatableCol(
          key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
      DatatableCol(
          key: 'idade',
          title: 'Idade',
          visibility: false,
          customRenderString: (map, instance) {
            return (instance as Candidato).idade.toString();
          }),
      DatatableCol(key: 'cpf', title: 'CPF', visibility: false),
      DatatableCol(key: 'sexo', title: 'Sexo'),
      DatatableCol(
          key: 'estadoCivil', title: 'Estado Civil', visibility: false),
      DatatableCol(
          key: 'dataNascimento', title: 'Data Nascimento', visibility: false),
      DatatableCol(
          key: 'emailPrincipal', title: 'E-mail Principal', visibility: false),
      DatatableCol(
          key: 'dataInicialResidenciaRO',
          title: 'Data Inicial Residencia RO',
          visibility: false),
      DatatableCol(
          key: 'rendaFamiliar', title: 'Renda Familiar', visibility: false),
      DatatableCol(
          key: 'referenciaPessoal',
          title: 'Referência Pessoal',
          visibility: false),
      DatatableCol(
          key: 'complementoPessoaFisica.categoriaHabilitacao',
          title: 'Categoria Habilitação',
          visibility: false),
      DatatableCol(
          key: 'complementoPessoaFisica.deficiente',
          title: 'PNE',
          visibility: true,
          format: DatatableFormat.bool),
      DatatableCol(key: 'identidadeGenero', title: 'Ident. Genero', visibility: false),
      DatatableCol(
          key: 'Escolaridade',
          title: 'Escolaridade',
          customRenderString: (map, instance) {
            final cand = (instance as Candidato);
            return cand.complementoPessoaFisica != null
                ? cand.complementoPessoaFisica!.nomeEscolaridade ?? ''
                : '';
          }),
      DatatableCol(
          key: 'ordemGraduacao', title: 'Ordem Graduação', visibility: false),
      DatatableCol(
          key: 'dataAlteracaoCandidato',
          title: 'Data Alteração',
          visibility: false,
          format: DatatableFormat.date),
      DatatableCol(
          key: 'dataCadastroCandidato',
          title: 'Data Cadastro',
          visibility: false,
          format: DatatableFormat.date),
      DatatableCol(
          key: 'Cargos desejados',
          title: 'Cargos desejados',
          customRenderHtml: (map, instance) {
            //badge border border-primary text-primary
            final cand = (instance as Candidato);
            final cargos = cand.cargosDesejados;
            final div = html.DivElement();
            div.onClick.listen((e) => e.stopPropagation());
            var idx = 0;
            for (var cargo in cargos) {
              final span = html.DivElement();
              span.onClick.listen((e) {
                PopoverComponent.showPopover(
                    span,
                    '''Cargo: ${cargo.nome} <br>
                    Experiência Formal: ${cargo.tempoExperienciaFormal ?? '0'} meses <br>
                    Experiência Informal: ${cargo.tempoExperienciaInformal ?? '0'} meses
                    Experiência MEI: ${cargo.tempoExperienciaMei ?? '0'} meses
                    ''',
                    title: 'Detalhe');
              });
              span.classes.addAll([
                'badge',
                'border',
                'border-primary',
                'text-primary',
                'me-2'
              ]);
              span.text = cargo.nome;
              div.append(span);
              if (idx == 11) {
                final span = html.SpanElement();
                span.text = '...';
                div.append(span);
                break;
              }
              idx++;
            }

            return div;
          }),
      DatatableCol(
          key: 'status',
          title: 'Status',
          visibility: true,
          customRenderHtml: (map, instance) {
            final value = map['status'];
            final span = html.SpanElement();
            span.text = value;
            if (value == 'vencido') {
              span.classes.addAll(
                ['badge', 'bg-danger', 'bg-opacity-10', 'text-danger'],
              );
            } else {
              span.classes.addAll(
                ['badge', 'bg-success', 'bg-opacity-10', 'text-success'],
              );
            }
            return span;
          })
    ];
    dtSettings = DatatableSettings(colsDefinitions: dtColsDefinitions);
  }

  var itemSelected = Candidato.invalid();

  DataFrame<Candidato> items = DataFrame<Candidato>.newClear();

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'cpf', operator: '=', label: 'CPF'),
    DatatableSearchField(
        field: 'idCandidato', operator: '=', label: 'Id Candidato'),
    DatatableSearchField(
        field: 'idPessoaFisica', operator: '=', label: 'Id Pessoa'),
    DatatableSearchField(
        field: 'identidadeGenero',
        operator: 'like',
        label: 'Identidade de Genero'),
    DatatableSearchField(field: 'sexo', operator: 'like', label: 'Sexo'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Candidato>();

  @Output('onSelect')
  Stream<Candidato> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Candidato selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formCandidato
          .toUrl(parameters: {'id': '${selected.idCandidato}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _candidatoService.all(filtro);
    } catch (e, s) {
      print('ListaCandidatoPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Candidato>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnExcluir!, 'Selecione apenas um item!');
      return;
    }

    final isRemove = await SimpleDialogComponent.showConfirm(
        'Tem certeza que deseja escluir: "${selected.map((e) => e.nome).join('-')}", esta operação não pode ser desfeita?');
    if (isRemove) {
      final simpleLoading = SimpleLoading();
      try {
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }
        await _candidatoService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaCandidatoPage@excluir $e $s');
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await load();
  }

  void setInputSearchFocus() {
    datatable?.setInputSearchFocus();
  }

  void openModalVaga() {
    if (insideModal == false) {
      modalVaga?.open();
      listaVaga?.load();
    }
  }

  void onSelectVaga(Vaga vagaSel) {
    filtro.nomeVaga = '${vagaSel.cargoNome} - ${vagaSel.empregadorNome}';
    filtroIdVaga = vagaSel.id;
    enableAllVagaMatch();
    modalVaga?.close();
    load();
  }
}
