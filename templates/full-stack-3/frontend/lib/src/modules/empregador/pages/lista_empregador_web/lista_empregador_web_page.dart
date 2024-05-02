import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de empregadores web
@Component(
  selector: 'lista-empregador-web-page',
  templateUrl: 'lista_empregador_web_page.html',
  styleUrls: ['lista_empregador_web_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths, EmpregadorStatusValidacao],
)
class ListaEmpregadorWebPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EmpregadorWebServiceWeb _empregadorWebServiceWeb;

  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('modalTrocarStatus')
  CustomModalComponent? modalTrocarStatus;

  @ViewChild('btnValidar')
  html.Element? btnValidar;
  @ViewChild('btnCancelar')
  html.Element? btnCancelar;

  @ViewChild('btnAtualizarObservacao')
  html.Element? btnAtualizarObservacao;

  final html.Element hostElement;

  late DatatableSettings dtSettings;

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'cpfOrCnpj', operator: '=', label: 'cpfOrCnpj'),
  ];

  ListaEmpregadorWebPage(this.notificationComponentService, this.hostElement,
      this._empregadorWebServiceWeb, this._router) {
    dtSettings = DatatableSettings(colsDefinitions: [
      DatatableCol(
          key: 'id',
          title: 'Id',
          sortingBy: 'id',
          enableSorting: true,
          visibility: false),
      DatatableCol(
          key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
      DatatableCol(key: 'cpfOrCnpj', title: 'CPF/CNPJ', visibility: true),
      DatatableCol(key: 'telefone', title: 'Telefone', visibility: false),
      DatatableCol(key: 'contato', title: 'Contato'),
      DatatableCol(
          key: 'tipoTelefone', title: 'Tipo Telefone', visibility: false),
      DatatableCol(
          key: 'dataCadastro',
          title: 'Dt Cadastro',
          sortingBy: 'dataCadastro',
          enableSorting: true,
          format: DatatableFormat.date),
      DatatableCol(
        key: 'dataValidacao',
        title: 'Dt Validação',
        sortingBy: 'dataValidacao',
        enableSorting: true,
        visibility: true,
        format: DatatableFormat.dateTime,
      ),
      DatatableCol(
          key: 'nomeRespValidacao',
          title: 'Resp Validação',
          visibility: true,
          customRenderString: (m, i) {
            return (i as EmpregadorWeb).nomeRespValidacao ?? '';
          }),
      DatatableCol(key: 'tipo', title: 'Tipo'),
      DatatableCol(
        key: 'observacaoValidacao',
        title: 'Observação Validação',
      ),
      DatatableCol(
          key: 'statusValidacao',
          title: 'Status Validação',
          visibility: true,
          customRenderHtml: (map, instance) {
            final empre = (instance as EmpregadorWeb);
            final dev = html.DivElement();
            dev.text = empre.statusValidacao?.value ?? '';
            return dev;
          }),
    ]);
  }

  var itemSelected = EmpregadorWeb.invalidJuridica();

  final filtro = Filters(
      limit: 12,
      offset: 0,
      statusValidacao: EmpregadorStatusValidacao.pendente.value);

  DataFrame<EmpregadorWeb> items = DataFrame<EmpregadorWeb>.newClear();

  void onDtRequestData(e) {
    load();
  }

  void validar() {
    final selected = datatable!.getAllSelected<EmpregadorWeb>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnValidar!, 'Selecione apenas um item!');
      return;
    }

    if (selected.first.statusValidacao == EmpregadorStatusValidacao.validado) {
      PopoverComponent.showPopover(btnValidar!, 'Já esta validado!');
      return;
    }

    if (selected.first.statusValidacao == EmpregadorStatusValidacao.cancelado) {
      PopoverComponent.showPopover(btnValidar!, 'Está cancelado!');
      return;
    }

    itemSelected = selected.first;

    _router.navigate(RoutePaths.formEmpregador.toUrl(parameters: {'id': 'new'}),
        NavigationParams(queryParameters: {'isWeb': 'true'}));
    RoutePaths.areaTransferencia = itemSelected;
  }

  EmpregadorStatusValidacao? selectedStatus;

  void openCancelar() {
    final selected = datatable!.getAllSelected<EmpregadorWeb>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnCancelar!, 'Selecione apenas um item!');
      return;
    }

    if (selected.first.statusValidacao == EmpregadorStatusValidacao.cancelado) {
      PopoverComponent.showPopover(btnCancelar!, 'Já esta cancelado');
      return;
    }

    itemSelected = selected.first;
    selectedStatus = EmpregadorStatusValidacao.cancelado;

    modalTrocarStatus?.open();
  }

  void openAtualizarObservacao() {
    final selected = datatable!.getAllSelected<EmpregadorWeb>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(
          btnAtualizarObservacao!, 'Selecione apenas um item!');
      return;
    }
    itemSelected = selected.first;
    selectedStatus = itemSelected.statusValidacao;
    modalTrocarStatus?.open();
  }

  void trocarStatus({bool showLoading = true}) async {
    modalTrocarStatus?.close();
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show();
      }
      itemSelected.statusValidacao = selectedStatus;
      await _empregadorWebServiceWeb.updateStatus(itemSelected);
      await load(showLoading: false);
    } catch (e, s) {
      print('trocarStatus $e $s');
      SimpleDialogComponent.showAlert('Erro ao trocar status Empregador WEB',
          subMessage: '$e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  final _onSelectStreamController = StreamController<EmpregadorWeb>();

  @Output('onSelect')
  Stream<EmpregadorWeb> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(EmpregadorWeb selected) async {
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
      items = await _empregadorWebServiceWeb.all(filtro);
    } catch (e, s) {
      print('ListaEmpregadorWebPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  // Future<void> excluir({bool showLoading = true}) async {
  //   final selected = datatable!.getAllSelected<EmpregadorWeb>();
  //   if (selected.isEmpty || selected.length > 1) {
  //     PopoverComponent.showPopover(btnExcluir!, 'Selecione apenas um item!');
  //     return;
  //   }

  //   final isRemove = await SimpleDialogComponent.showConfirm(
  //       'Tem certeza que deseja escluir: "${selected.map((e) => e.nome).join('-')}", esta operação não pode ser desfeita?');
  //   if (isRemove) {
  //     final simpleLoading = SimpleLoading();
  //     try {
  //       if (showLoading) {
  //         simpleLoading.show(target: hostElement);
  //       }
  //       await _empregadorWebServiceWeb.deleteAll(selected);
  //       await load(showLoading: false);
  //     } catch (e, s) {
  //       print('ListaEmpregadorWebPage@excluir $e $s');
  //       SimpleDialogComponent.showAlert('Erro ao remover Empregador',
  //           subMessage: '$e $s');
  //     } finally {
  //       if (showLoading) {
  //         simpleLoading.hide();
  //       }
  //     }
  //   }
  // }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await load();
  }

  void setInputSearchFocus() {
    datatable?.setInputSearchFocus();
  }
}
