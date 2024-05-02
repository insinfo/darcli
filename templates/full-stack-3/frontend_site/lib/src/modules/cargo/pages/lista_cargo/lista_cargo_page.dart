import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend_site/sibem_frontend_site.dart';

/// Listagem de cargos
@Component(
  selector: 'lista-cargo-page',
  templateUrl: 'lista_cargo_page.html',
  styleUrls: ['lista_cargo_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
)
class ListaCargoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final CargoService _cargoService;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaCargoPage(
      this.notificationComponentService, this.hostElement, this._cargoService);

  var itemSelected = Cargo(nome: '', id: -1);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Cargo> items = DataFrame<Cargo>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    //DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    //DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Cargo>();

  @Output('onSelect')
  Stream<Cargo> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Cargo selected) async {
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
      items = await _cargoService.all(filtro);
    } catch (e, s) {
      print('ListaCargoPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
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
