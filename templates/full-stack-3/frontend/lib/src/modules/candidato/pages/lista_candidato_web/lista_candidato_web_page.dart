import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de candidato
@Component(
  selector: 'lista-candidato-web-page',
  templateUrl: 'lista_candidato_web_page.html',
  styleUrls: ['lista_candidato_web_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
)
class ListaCandidatoWebPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final CandidatoWebService _candidatoWebService;
  // ignore: unused_field
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;
  late DatatableSettings dtSettings;

  ListaCandidatoWebPage(this.notificationComponentService, this.hostElement,
      this._candidatoWebService, this._router) {
    dtSettings = DatatableSettings(colsDefinitions: [
      DatatableCol(
          key: 'validado',
          title: 'Validado',
          visibility: true,
          customRenderHtml: (map, instance) {
            final cand = (instance as CandidatoWeb);

            if (cand.validado == true) {
              return html.DivElement()..text = 'Sim';
            }
            final btn = html.ButtonElement()
              ..type = 'button'; //, 'border-transparent'
            btn.classes.addAll(['btn', 'btn-flat-success', 'border-width-2']);
            btn.text = 'Validar';
            btn.onClick.listen((event) {
              _router.navigate(
                  RoutePaths.formCandidato.toUrl(parameters: {'id': 'new'}),
                  NavigationParams(queryParameters: {'isWeb': 'true'}));
              RoutePaths.areaTransferencia = cand;
            });
            return html.DivElement()..append(btn);
          }),
      DatatableCol(
        key: 'dataValidacao',
        title: 'Validado em',
        visibility: true,
        format: DatatableFormat.date,
        sortingBy: 'dataValidacao',
        enableSorting: true,
      ),
      DatatableCol(
        key: 'nomeRespValidacao',
        title: 'Resp Validação',
        visibility: true,
        customRenderString: (m,i){
          return (i as CandidatoWeb).nomeRespValidacao ?? '';
        }
      ),
      DatatableCol(
        key: 'dataCadastro',
        title: 'Cadastrado',
        visibility: true,
        format: DatatableFormat.date,
        sortingBy: 'dataCadastro',
        enableSorting: true,
      ),
      DatatableCol(
          key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
      DatatableCol(key: 'rg', title: 'RG', visibility: false),
      DatatableCol(key: 'cpf', title: 'CPF', visibility: false),
      DatatableCol(key: 'sexoBiologico', title: 'Sexo', visibility: true),
      DatatableCol(
          key: 'estadoCivil', title: 'Estado Civil', visibility: false),
      DatatableCol(
          key: 'dataNascimento',
          title: 'Nascimento',
          visibility: true,
          format: DatatableFormat.date),
      DatatableCol(
          key: 'emailPrincipal', title: 'E-mail', visibility: true),
      DatatableCol(
          key: 'dataInicialResidenciaRO',
          title: 'Data Inicial Residencia RO',
          visibility: false),
      DatatableCol(
          key: 'rendaFamiliar', title: 'Renda Familiar', visibility: false),
      DatatableCol(
          key: 'referenciaPessoal',
          title: 'Referência Pessoal',
          visibility: true),
      DatatableCol(key: 'cep', title: 'CEP', visibility: false),
      DatatableCol(
          key: 'complementoEndereco', title: 'Complemento', visibility: false),
      DatatableCol(key: 'numeroEndereco', title: 'Número', visibility: false),
      DatatableCol(
          key: 'tipoTelefone', title: 'Tipo Telefone', visibility: false),
      DatatableCol(key: 'telefone', title: 'Telefone', visibility: true),
      DatatableCol(key: 'pis', title: 'PIS', visibility: false),
      DatatableCol(
          key: 'nrTituloEleitor', title: 'Titulo Eleitor', visibility: false),
      DatatableCol(
          key: 'zonaTituloEleitor',
          title: 'Zona Titulo Eleitor',
          visibility: false),
      DatatableCol(
          key: 'nrSerieCarteiraProfissional',
          title: 'Nº Serie Carteira Profissional',
          visibility: false),
      DatatableCol(
          key: 'nrCarteiraProfissional',
          title: 'Nº Carteira Profissional',
          visibility: false),
      DatatableCol(
          key: 'categoriaHabilitacao',
          title: 'Categoria Habilitacao',
          visibility: false),
    ]);
  }

  var itemSelected = CandidatoWeb.invalid();

  final filtro = Filters(limit: 12, offset: 0, isValidado: false);

  /// filtrar candidatos que coincidem com a vaga
  @Input('filtroIdVaga')
  set filtroIdVaga(int? val) {
    filtro.idVaga = val;
  }

  DataFrame<CandidatoWeb> items = DataFrame<CandidatoWeb>.newClear();

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'cpf', operator: '=', label: 'CPF'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<CandidatoWeb>();

  @Output('onSelect')
  Stream<CandidatoWeb> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(CandidatoWeb selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    }
    // } else {
    //   _router.navigate(RoutePaths.formCandidato
    //       .toUrl(parameters: {'id': '${selected.idCandidato}'}));
    // }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _candidatoWebService.all(filtro);
    } catch (e, s) {
      print('ListaCandidatoWebPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<CandidatoWeb>();
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
        await _candidatoWebService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaCandidatoWebPage@excluir $e $s');
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
