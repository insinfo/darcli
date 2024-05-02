import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

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
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaCargoPage(this.notificationComponentService, this.hostElement,
      this._cargoService, this._router);

  var itemSelected = Cargo(nome: '', id: -1);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Cargo> items = DataFrame<Cargo>.newClear();

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

  final _onSelectStreamController = StreamController<Cargo>();

  @Output('onSelect')
  Stream<Cargo> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Cargo selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(
          RoutePaths.formCargo.toUrl(parameters: {'id': '${selected.id}'}));
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

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Cargo>();
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
        await _cargoService.delete(selected.first);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaCargoPage@excluir $e $s');
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

  Future<void> importarXlsx({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      final fileMap = await FrontUtils.getClientFileAsBytes();
      if (fileMap != null) {
        await _cargoService.importXlsx(fileMap['name'], fileMap['bytes']);
      }
    } catch (e, s) {
      print('ListaCargoPage@importarXlsx $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }
}
