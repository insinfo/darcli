import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de auditorias
@Component(
  selector: 'lista-auditoria-page',
  templateUrl: 'lista_auditoria_page.html',
  styleUrls: ['lista_auditoria_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaAuditoriaPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final AuditoriaService _auditoriaService;
  // ignore: unused_field
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaAuditoriaPage(this.notificationComponentService, this.hostElement,
      this._auditoriaService, this._router);

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Auditoria> items = DataFrame<Auditoria>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(key: 'usuarioNome', title: 'Usuário'),
    DatatableCol(key: 'acao', title: 'Ação'),
    DatatableCol(key: 'data', title: 'data', format: DatatableFormat.date),
    DatatableCol(key: 'metodo', title: 'metodo'),
    DatatableCol(key: 'path', title: 'path'),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(
        field: 'usuarioNome', operator: 'like', label: 'Usuário'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Auditoria>();

  @Output('onSelect')
  Stream<Auditoria> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Auditoria selected) async {
    // itemSelected = selected;
    // if (insideModal) {
    //   _onSelectStreamController.add(selected);
    // } else {
    //   _router.navigate(
    //       RoutePaths.formAuditoria.toUrl(parameters: {'id': '${selected.id}'}));
    // }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _auditoriaService.all(filtro);
    } catch (e, s) {
      print('ListaAuditoriaPage@load $e $s');
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
