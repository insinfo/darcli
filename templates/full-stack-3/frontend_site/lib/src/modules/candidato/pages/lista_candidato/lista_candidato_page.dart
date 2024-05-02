import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend_site/sibem_frontend_site.dart';

/// Listagem de candidatos
@Component(
  selector: 'lista-candidato-page',
  templateUrl: 'lista_candidato_page.html',
  styleUrls: ['lista_candidato_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: const [RoutePaths, StatusEncaminhamento],
)
class ListaCandidatoEncaminhadoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EncaminhamentoService _encaminhamentoService;
  final AuthService authService;
  // ignore: unused_field
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  @ViewChild('modalVaga')
  CustomModalComponent? modalVaga;

  @ViewChild('btnAtualizar')
  html.Element? btnAtualizar;

  @ViewChild('modalAtualizarStatus')
  CustomModalComponent? modalAtualizarStatus;

  final filtro = Filters(
      limit: 12,
      offset: 0,
      statusEncaminhamento: StatusEncaminhamento.encaminhado.value);

  final html.Element hostElement;

  List<DatatableCol> dtColsDefinitions = [];
  late DatatableSettings dtSettings;

  ListaCandidatoEncaminhadoPage(
      this.notificationComponentService,
      this.hostElement,
      this._encaminhamentoService,
      this._router,
      this.authService) {
    dtColsDefinitions = [
      DatatableCol(
          key: 'id',
          title: 'Id',
          visibility: false,
          sortingBy: 'id',
          enableSorting: true),
      DatatableCol(
          key: 'idVaga',
          title: 'Id Vaga',
          visibility: true,
          sortingBy: 'idVaga',
          enableSorting: true),
      DatatableCol(
          key: 'dataAberturaVaga',
          title: 'Dt. Abertura Vaga',
          visibility: true,
          sortingBy: 'dataAberturaVaga',
          enableSorting: true,
          format: DatatableFormat.date),
      DatatableCol(
          key: 'nomeCargo',
          title: 'Cargo',
          enableSorting: true,
          sortingBy: 'nomeCargo'),
      DatatableCol(
          key: 'nomeCandidato',
          title: 'Candidato',
          enableSorting: true,
          sortingBy: 'nomeCandidato'),
      DatatableCol(
          key: 'nomeEmpregador', title: 'Empregador', visibility: false),
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
          sortingBy: 'status',
          customRenderHtml: (map, instance) {
            final enca = (instance as Encaminhamento);

            final div = html.DivElement();
            div.classes.addAll(['badge']);
            div.text = enca.status;

            if (enca.status == StatusEncaminhamento.efetivado.value) {
              div.classes.addAll(['bg-success']);
            } else if (enca.status == StatusEncaminhamento.encaminhado.value) {
              div.classes.addAll(['bg-purple']);//, 'text-purple'
            } else if (enca.status ==
                StatusEncaminhamento.naoCompareceu.value) {
              div.classes.addAll(['bg-danger']);
            } else if (enca.status == StatusEncaminhamento.naoSelecionado.value) {
              div.classes.addAll(['bg-warning']);
            }         
            //div.classes.addAll(['bg-opacity-10']);
            return div;
          }),
    ];
    dtSettings = DatatableSettings(colsDefinitions: dtColsDefinitions);
  }

  var itemSelected = Encaminhamento.invalid();

  DataFrame<Encaminhamento> items = DataFrame<Encaminhamento>.newClear();

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
    } else {}
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _encaminhamentoService.getAllByEmpregador(
          authService.authPayload.idPessoa!, filtro);
    } catch (e, s) {
      print('ListaCandidatoPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) {
    load();
  }

  void setInputSearchFocus() {
    datatable?.setInputSearchFocus();
  }

  void openAtulizarStatus() {
    final selected = datatable!.getAllSelected<Encaminhamento>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnAtualizar!, 'Selecione um Candidato!');
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

  void onChangeFiltroStatus() async {
    await Future.delayed(Duration(milliseconds: 100));
    load();
  }

//end class
}
