import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/shared/services/auth_service.dart';
import 'package:esic_frontend/src/modules/solicitacao/services/solicitacoes_service.dart';

import 'package:esic_frontend/src/shared/components/datatable/datatable.dart';

import 'package:esic_frontend/src/shared/components/loading/loading.dart';
import 'package:esic_frontend/src/shared/components/simple_dialog/simple_dialog.dart';

import 'package:esic_frontend/src/shared/route_paths.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngrouter/angular_router.dart';
import 'dart:html' as html;

@Component(
  selector: 'lista-solicitacao-page',
  templateUrl: 'lista_solicitacao.html',
  styleUrls: ['lista_solicitacao.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DatatableComponent,
  ],
  providers: [ClassProvider(SolicitacoesService)],
)
class ListaSolicitacaoPage implements OnActivate , CanReuse{
  final SolicitacoesService service;
  final AuthService authService;

  ListaSolicitacaoPage(this.service, this.authService, this._router);

  final Router _router;

  @ViewChild('pageContainer')
  html.DivElement? pageContainer;

  @ViewChild('tagContainer')
  html.HtmlElement? tagContainer;

  SimpleLoading simpleLoading = SimpleLoading();

  List<DatatableSearchField> searchInFields = [
    DatatableSearchField(
        field: 'protocoloAno', label: 'Protocolo/Ano', operator: '='),
    DatatableSearchField(
        field: 'textosolicitacao',
        label: 'Texto Solicitação',
        operator: 'ilike'),
    DatatableSearchField(
        field: 'resposta', label: 'Resposta', operator: 'ilike'),
    DatatableSearchField(
        field: 'lda_solicitante.nome',
        label: 'Nome solicitante',
        operator: 'like'),
  ];

  DatatableSettings datatableSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(
      key: 'numprotocolo||anoprotocolo',
      title: 'Protocolo/Ano',
      multiValSeparator: '/',
      enableSorting: false,
      sortingBy: "numprotocolo::text || '/' || anoprotocolo::text",
    ),
    //A - aberto; T - em tramitacao; N - negado; R - respondido;
    DatatableCol(
      key: 'situacao',
      title: 'Situação',
      sortingBy: 'situacao',
      enableSorting: true,
      customRender: (itemMap, itemInstance) {
        var sol = itemInstance as Solicitacao;
        return sol.situacaoText;
      },
    ),
    // DatatableCol(key: 'tipoSolicitacao.nome', title: 'Tipo de Solicitação'),
    DatatableCol(
      key: 'textosolicitacao',
      title: 'Texto Solicitação',
      visibility: false,
    ),
    //DatatableCol(key: 'instancia', title: 'Tipo de Solicitação'),
    DatatableCol(key: 'resposta', title: 'Resposta', visibility: false),
    DatatableCol(
      key: 'dataresposta',
      title: 'Data Resposta',
      format: DatatableFormat.date,
      enableSorting: true,
      sortingBy: 'dataresposta',
    ),
    DatatableCol(
      key: 'datasolicitacao',
      title: 'Data Solicitação',
      format: DatatableFormat.date,
      enableSorting: true,
      sortingBy: 'datasolicitacao',
    ),
    DatatableCol(
      key: 'solicitantenome',
      title: 'Solicitante',
      format: DatatableFormat.text,
      enableSorting: true,
      sortingBy: 'solicitantenome',
    ),
    DatatableCol(
      key: 'datarecebimentosolicitacao',
      title: 'Data Recebimento',
      format: DatatableFormat.date,
      enableSorting: true,
      sortingBy: 'datarecebimentosolicitacao',
    ),
    DatatableCol(
      key: 'secretariaorigemnome',
      title: 'Origem',
      format: DatatableFormat.text,
      visibility: false,
    ),
    DatatableCol(
      key: 'secretariadestinonome',
      title: 'Destino',
      format: DatatableFormat.text,
      visibility: false,
    ),
    DatatableCol(
      key: 'prazorestante',
      title: 'Prazo Restante',
      enableSorting: true,
      sortingBy: 'prazorestante',
      customRender: (itemMap, itemInstance) {
        var sol = itemInstance as Solicitacao;
        var cor = '', title = '';
        if (sol.prazoRestante < 0) {
          //vermelho - Urgente! Passou do prazo de resolução
          cor = '#FFB2B2';
          title = 'Urgente! Passou do prazo';
        } //se faltar entre 1 e 5 dias para expirar o prazo de resposta
        else if (sol.prazoRestante >= 0 && sol.prazoRestante <= 5) {
          cor = '#FFFACD'; //amarelo - Alerta! Está perto de expirar
          title = 'Alerta! Está perto de expirar';
        }
        return '<span title="$title" style="background: $cor; padding-left:10px;padding-right:10px;padding-top:5px;padding-bottom:5px;">${sol.prazoRestante}</span>';
      },
    ),
    DatatableCol(
      key: 'dataprevisaoresposta',
      title: 'Previsão Resposta',
      format: DatatableFormat.date,
      visibility: false,
      enableSorting: true,
      sortingBy: 'dataprevisaoresposta',
    ),
    DatatableCol(
      key: 'dataprorrogacao',
      title: 'Prorrogado?',
      enableSorting: true,
      sortingBy: 'dataprorrogacao',
      customRender: (itemMap, itemInstance) {
        var sol = itemInstance as Solicitacao;
        return sol.dataProrrogacao != null ? 'Sim' : 'Não';
      },
    ),
    /*DatatableCol(
      key: 'formaretorno',
      title: 'Forma Retorno',
      customRender: (itemMap, itemInstance) {
        var sol = itemInstance as Solicitacao;
        return sol.formaRetornoText;
      },
    ),*/
  ]);

  DataFrame<Solicitacao> solicitacoes =
      DataFrame<Solicitacao>(items: [], totalRecords: 0);

  Filters filtros =
      Filters(limit: 12, orderDir: 'asc', orderBy: 'idsolicitacao');

  Future<void> getAllSolicitacoes() async {
    try {
      simpleLoading.show(target: pageContainer);
      solicitacoes = await service.getAll(filtros);
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao obter dados',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
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

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await getAllSolicitacoes();
  }

  //---------------- FILTROS
  void selectFiltroSituacaoChange(e) async {
    var selectFS = e.target as html.SelectElement;
    filtros.additionalParams['situacao'] = selectFS.value!;
    await getAllSolicitacoes();
  }

  void cadastrar() {
    _router
        .navigate(RoutePaths.solicitacoesForm.toUrl(parameters: {'id': 'new'}));
  }

  void onRowClick(dynamic selected) async {
    var item = selected as Solicitacao;

    if (selected.dataRecebimentoSolicitacao == null) {
      var result =
          await SimpleDialogComponent.showConfirm('Receber Solicitação?');
      if (result) {
        await receberSolicitacao(item);
        await _router.navigate(RoutePaths.solicitacoesForm
            .toUrl(parameters: {'id': '${item.id}'}));
      }
    } else {
      await _router.navigate(
          RoutePaths.solicitacoesForm.toUrl(parameters: {'id': '${item.id}'}));
    }
  }

  Future<void> receberSolicitacao(Solicitacao solicitacao) async {
    try {
      simpleLoading.show(target: pageContainer);
      await service.receber(solicitacao);
    } catch (e, s) {
      SimpleDialogComponent.showAlert(
          'Erro executar o recebimento da solicitacao!',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }
  
  @override
  Future<bool> canReuse(RouterState current, RouterState next)async {
    return true;
  }
}
