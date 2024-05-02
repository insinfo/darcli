import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de tipos conhecimento 
@Component(
  selector: 'lista-tipo-conhecimento-page',
  templateUrl: 'lista_tipo_conhecimento_page.html',
  styleUrls: ['lista_tipo_conhecimento_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaTipoConhecimentoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final TipoConhecimentoService _tipoConhecimentoService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaTipoConhecimentoPage(this.notificationComponentService, this.hostElement,
      this._tipoConhecimentoService, this._router);

  var itemSelected = TipoConhecimento(nome: '', id: -1);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<TipoConhecimento> items = DataFrame<TipoConhecimento>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
   
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<TipoConhecimento>();

  @Output('onSelect')
  Stream<TipoConhecimento> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(TipoConhecimento selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(
          RoutePaths.formTipoConhecimento.toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _tipoConhecimentoService.all(filtro);
    } catch (e, s) {
      print('ListaTipoConhecimentoPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<TipoConhecimento>();
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
        await _tipoConhecimentoService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaTipoConhecimentoPage@excluir $e $s');
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
