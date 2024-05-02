import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de empregadores
@Component(
  selector: 'lista-empregador-page',
  templateUrl: 'lista_empregador_page.html',
  styleUrls: ['lista_empregador_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaEmpregadorPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EmpregadorService _empregadorService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaEmpregadorPage(this.notificationComponentService, this.hostElement,
      this._empregadorService, this._router);

  var itemSelected = Empregador(
    dataCadastroEmpregador: DateTime.now(),
    contato: '',
    idDivisaoCnae: -1,
    ativo: true,
    tipo: 'juridica',
    nome: '',
    dataInclusao: DateTime.now(),
  );

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Empregador> items = DataFrame<Empregador>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(key: 'isFromWeb', title: 'Veio da WEB', visibility: true,format: DatatableFormat.bool),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
    DatatableCol(key: 'contato', title: 'Contato'),
    DatatableCol(
        key: 'dataCadastroEmpregador',
        title: 'Cadastrado',
        sortingBy: 'dataCadastroEmpregador',
        enableSorting: true,
        format: DatatableFormat.date),
    DatatableCol(
        key: 'dataAlteracaoEmpregador',
        title: 'Alterado',
        sortingBy: 'dataAlteracaoEmpregador',
        enableSorting: true,
        format: DatatableFormat.date),
    DatatableCol(key: 'ativo', title: 'Ativo', format: DatatableFormat.bool),
    DatatableCol(key: 'tipo', title: 'Tipo'),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Empregador>();

  @Output('onSelect')
  Stream<Empregador> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Empregador selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formEmpregador
          .toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _empregadorService.all(filtro);
    } catch (e, s) {
      print('ListaEmpregadorPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Empregador>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnExcluir!, 'Selecione apenas um item!');
      return;
    }

    final isRemove = await SimpleDialogComponent.showConfirm(
        'Tem certeza que deseja escluir: "${selected.map((e) => e.contato).join('-')}", esta operação não pode ser desfeita?');
    if (isRemove) {
      final simpleLoading = SimpleLoading();
      try {
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }
        await _empregadorService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaEmpregadorPage@excluir $e $s');
        SimpleDialogComponent.showAlert('Erro ao remover Empregador',
            subMessage: '$e $s');
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
