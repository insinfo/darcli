import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem
@Component(
  selector: 'lista-tipo-deficiencia-page',
  templateUrl: 'lista_tipo_deficiencia_page.html',
  styleUrls: ['lista_tipo_deficiencia_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaTipoDeficienciaPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final TipoDeficienciaService _tipoDeficienciaService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaTipoDeficienciaPage(this.notificationComponentService, this.hostElement,
      this._tipoDeficienciaService, this._router);

  var itemSelected = TipoDeficiencia(nome: '', id: -1);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<TipoDeficiencia> items = DataFrame<TipoDeficiencia>.newClear();

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

  final _onSelectStreamController = StreamController<TipoDeficiencia>();

  @Output('onSelect')
  Stream<TipoDeficiencia> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(TipoDeficiencia selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formTipoDeficiencia
          .toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _tipoDeficienciaService.all(filtro);
    } catch (e, s) {
      print('ListaTipoDeficienciaPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<TipoDeficiencia>();
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
        await _tipoDeficienciaService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaTipoDeficienciaPage@excluir $e $s');
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
