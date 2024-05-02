import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de conhecimento extra
@Component(
  selector: 'lista-conhecimento-extra-page',
  templateUrl: 'lista_conhecimento_extra_page.html',
  styleUrls: ['lista_conhecimento_extra_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaConhecimentoExtraPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final ConhecimentoExtraService _conhecimentoExtraService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaConhecimentoExtraPage(this.notificationComponentService,
      this.hostElement, this._conhecimentoExtraService, this._router);

  var itemSelected =
      ConhecimentoExtra(nome: '', id: -1, idTipoConhecimento: -1);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<ConhecimentoExtra> items = DataFrame<ConhecimentoExtra>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
    DatatableCol(key: 'tipoConhecimentoNome', title: 'Tipo Conhecimento'),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<ConhecimentoExtra>();

  @Output('onSelect')
  Stream<ConhecimentoExtra> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(ConhecimentoExtra selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formConhecimentoExtra
          .toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _conhecimentoExtraService.all(filtro);
    } catch (e, s) {
      print('ListaConhecimentoExtraPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<ConhecimentoExtra>();
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
        await _conhecimentoExtraService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaConhecimentoExtraPage@excluir $e $s');
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
