import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de Escolaridades
@Component(
  selector: 'lista-escolaridade-page',
  templateUrl: 'lista_escolaridade_page.html',
  styleUrls: ['lista_escolaridade_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaEscolaridadePage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EscolaridadeService _scolaridadeService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaEscolaridadePage(this.notificationComponentService, this.hostElement,
      this._scolaridadeService, this._router);

  var itemSelected = Escolaridade(nome: '', id: -1, ordemGraduacao: 0);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Escolaridade> items = DataFrame<Escolaridade>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
    DatatableCol(
        key: 'ordemGraduacao',
        title: 'Ordem de graduação',
        sortingBy: 'ordemGraduacao',
        enableSorting: true),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Escolaridade>();

  @Output('onSelect')
  Stream<Escolaridade> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Escolaridade selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formEscolaridade
          .toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _scolaridadeService.all(filtro);
    } catch (e, s) {
      print('ListaEscolaridadePage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Escolaridade>();
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
        await _scolaridadeService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaEscolaridadePage@excluir $e $s');
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
