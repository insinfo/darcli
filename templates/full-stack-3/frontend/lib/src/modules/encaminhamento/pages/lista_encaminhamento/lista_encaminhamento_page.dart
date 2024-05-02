import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de encaminhamento
@Component(
  selector: 'lista-encaminhamento-page',
  templateUrl: 'lista_encaminhamento_page.html',
  styleUrls: ['lista_encaminhamento_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
)
class ListaEncaminhamentoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EncaminhamentoService _encaminhamentoService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  @ViewChild('btnAtualizar')
  html.Element? btnAtualizar;

  @ViewChild('modalAtualizarStatus')
  CustomModalComponent? modalAtualizarStatus;

  final html.Element hostElement;

  ListaEncaminhamentoPage(this.notificationComponentService, this.hostElement,
      this._encaminhamentoService, this._router);

  var itemSelected = Encaminhamento.invalid();

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Encaminhamento> items = DataFrame<Encaminhamento>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(key: 'nomeCandidato', title: 'Candidato'),
    DatatableCol(key: 'nomeEmpregador', title: 'Empregador'),
    DatatableCol(key: 'nomeCargo', title: 'Cargo'),
    DatatableCol(
        key: 'data',
        title: 'Encaminhado em',
        format: DatatableFormat.date,
        enableSorting: true,
        sortingBy: 'dataAlteracao'),
    DatatableCol(
        key: 'status',
        title: 'Status',
        enableSorting: true,
        sortingBy: 'status'),
    DatatableCol(key: 'usuarioResponsavelNome', title: 'Encaminhado por'),
    DatatableCol(
        key: 'dataAlteracao',
        title: 'Data Alteração',
        format: DatatableFormat.dateTime,
        enableSorting: true,
        sortingBy: 'dataAlteracao'),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(
        field: 'pessoas.nome', operator: 'like', label: 'Candidato'),
    DatatableSearchField(
        field: 'cargos.nome', operator: 'like', label: 'Cargo'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Encaminhamento>();

  @Output('onSelect')
  Stream<Encaminhamento> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Encaminhamento selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(RoutePaths.formEncaminhamento
          .toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _encaminhamentoService.all(filtro);
    } catch (e, s) {
      print('ListaEncaminhamentoPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Encaminhamento>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnExcluir!, 'Selecione apenas um item!');
      return;
    }

    final isRemove = await SimpleDialogComponent.showConfirm(
        'Tem certeza que deseja escluir: "${selected.map((e) => e.nomeCargo).join('-')}", esta operação não pode ser desfeita?');

    if (isRemove) {
      final simpleLoading = SimpleLoading();
      try {
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }
        await _encaminhamentoService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaEncaminhamentoPage@excluir $e $s');
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  void openAtulizarStatus() {
    final selected = datatable!.getAllSelected<Encaminhamento>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnAtualizar!, 'Selecione apenas um item!');
      return;
    }
    itemSelected = selected.first;
    modalAtualizarStatus?.open();
  }

  bool validateForm() {
    if (itemSelected.status.toLowerCase() == 'encaminhado') {
      SimpleDialogComponent.showAlert('Selecione o Status!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    // if (itemSelected.observacao?.trim().isEmpty == true) {
    //   SimpleDialogComponent.showAlert('Observação é obrigatório!',
    //       subMessage: 'Campo obrigatório!',
    //       dialogColor: DialogColor.DANGER,
    //       okAction: () {});
    //   return false;
    // }
    return true;
  }

  Future<void> updateStatus({bool showLoading = true}) async {
    if (!validateForm()) {
      return;
    }

    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      await _encaminhamentoService.updateStatus(itemSelected);
      modalAtualizarStatus?.close();
      await load(showLoading: false);
    } catch (e, s) {
      print('ListaEncaminhamentoPage@updateStatus $e $s');
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
