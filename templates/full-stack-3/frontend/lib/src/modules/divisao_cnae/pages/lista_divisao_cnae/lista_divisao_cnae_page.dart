import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de divisão Cnaes
@Component(
  selector: 'lista-divisao-cnae-page',
  templateUrl: 'lista_divisao_cnae_page.html',
  styleUrls: ['lista_divisao_cnae_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaDivisaoCnaePage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final DivisaoCnaeService _divisaoCnaeService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaDivisaoCnaePage(this.notificationComponentService, this.hostElement,
      this._divisaoCnaeService, this._router);

  var itemSelected = DivisaoCnae(nome: '', id: -1, secao: '');

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<DivisaoCnae> items = DataFrame<DivisaoCnae>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(
        key: 'secao', title: 'Secão', sortingBy: 'secao', enableSorting: true),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'secao', operator: 'like', label: 'Secão'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<DivisaoCnae>();

  @Output('onSelect')
  Stream<DivisaoCnae> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(DivisaoCnae selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formDivisaoCnae
          .toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _divisaoCnaeService.all(filtro);
    } catch (e, s) {
      print('ListaDivisaoCnaePage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<DivisaoCnae>();
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
        await _divisaoCnaeService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaDivisaoCnaePage@excluir $e $s');
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
}
