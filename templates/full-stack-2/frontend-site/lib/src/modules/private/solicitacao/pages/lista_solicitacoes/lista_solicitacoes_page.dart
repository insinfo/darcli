import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend_site/src/modules/private/solicitacao/services/solicitacao_service.dart';

import 'package:esic_frontend_site/src/shared/components/datatable/datatable.dart';
import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend_site/src/shared/directives/value_accessors/custom_form_directives.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:ngdart/angular.dart';

import 'dart:html' as html;

import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'lista-solicitacoes-page',
  templateUrl: 'lista_solicitacoes_page.html',
  styleUrls: ['lista_solicitacoes_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
  ],
  providers: [
    ClassProvider(SolicitacaoService),
  ],
)
class ListaSolicitacoesPage implements OnInit, OnActivate {
  final SolicitacaoService _solicitacaoService;
  final Router _router;

  final SimpleLoading _simpleLoading = SimpleLoading();
  Filters filtros =
      Filters(limit: 12, orderDir: 'desc', orderBy: 'idsolicitacao');

  @ViewChild('page')
  html.DivElement? pageContainer;
  String? errorMessage;

  DataFrame<Solicitacao> solicitacoes =
      DataFrame<Solicitacao>(items: [], totalRecords: 0);

  ListaSolicitacoesPage(this._solicitacaoService, this._router) {
    filtros.additionalParams['situacao'] = 'Todos';
  }

  List<DatatableSearchField> searchInFields = [
    DatatableSearchField(
        field: 'protocoloAno', label: 'Protocolo/Ano', operator: '='),
    DatatableSearchField(
        field: 'textosolicitacao',
        label: 'Texto Solicitação',
        operator: 'ilike'),
  ];

  DatatableSettings datatableSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(
      key: 'numprotocolo||anoprotocolo',
      title: 'Protocolo/Ano',
      multiValSeparator: '/',
    ),
    DatatableCol(key: 'tipoSolicitacao.nome', title: 'Tipo de Solicitação'),
    DatatableCol(
        key: 'datasolicitacao',
        title: 'Data Solicitação',
        format: DatatableFormat.date),
    DatatableCol(
        key: 'dataprevisaoresposta',
        title: 'Previsão Resposta',
        format: DatatableFormat.date),
    DatatableCol(
      key: 'dataprorrogacao',
      title: 'Prorrogado?',
      customRender: (itemMap, itemInstance) {
        var sol = itemInstance as Solicitacao;
        return sol.foiProrrogadoText;
      },
    ),
    DatatableCol(
        key: 'situacao',
        title: 'Situação',
        customRender: (itemMap, itemInstance) =>
            (itemInstance as Solicitacao).situacaoText),
    DatatableCol(
        key: 'dataresposta',
        title: 'Data Resposta',
        format: DatatableFormat.date),
  ]);

  Future<void> getAllSolicitacoes() async {
    try {
      _simpleLoading.show(target: pageContainer);
      solicitacoes = await _solicitacaoService.getAllOfPessoa(filtros);
    } catch (e, s) {
      SimpleDialogComponent.showAlert('$e', subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  Future<void> onRequestData(Filters fil) async {
    filtros.limit = fil.limit;
    filtros.offset = fil.offset;
    filtros.searchInFields = fil.searchInFields;
    filtros.searchString = fil.searchString;
    filtros.orderBy = fil.orderBy;
    filtros.orderDir = fil.orderDir;
    await getAllSolicitacoes();
  }

  void onRowClick(dynamic selected) {
    var item = selected as Solicitacao;
    _router.navigate(
        RoutePaths.detalheSolicitacao.toUrl(parameters: {'id': '${item.id}'}));
  }

  //---------------- FILTROS
  void selectFiltroSituacaoChange(e) async {
    var selectFS = e.target as html.SelectElement;
    filtros.additionalParams['situacao'] = selectFS.value!;
    await getAllSolicitacoes();
  }

  @override
  void ngOnInit() async {
    //await getAllSolicitacoes();
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await getAllSolicitacoes();
  }
}
