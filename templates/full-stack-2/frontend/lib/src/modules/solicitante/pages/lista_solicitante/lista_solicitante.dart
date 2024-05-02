import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/shared/services/auth_service.dart';
import 'package:esic_frontend/src/modules/solicitante/services/solicitante_service.dart';
import 'package:esic_frontend/src/shared/components/datatable/datatable.dart';

import 'package:esic_frontend/src/shared/components/loading/loading.dart';
import 'package:esic_frontend/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend/src/shared/route_paths.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngrouter/angular_router.dart';
import 'dart:html' as html;

@Component(
  selector: 'lista-solicitante-page',
  templateUrl: 'lista_solicitante.html',
  styleUrls: ['lista_solicitante.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DatatableComponent,
  ],
  providers: [ClassProvider(SolicitanteService)],
)
class ListaSolicitantePage implements OnActivate {
  final SolicitanteService service;
  final AuthService authService;

  ListaSolicitantePage(this.service, this.authService, this._router);

  final Router _router;

  @ViewChild('pageContainer')
  html.DivElement? pageContainer;

  @ViewChild('tagContainer')
  html.HtmlElement? tagContainer;

  SimpleLoading simpleLoading = SimpleLoading();

  List<DatatableSearchField> searchInFields = [
    DatatableSearchField(field: 'nome', label: 'Nome', operator: 'ilike'),
    DatatableSearchField(
        field: 'cpfcnpj', label: 'CPF/CNPJ', operator: 'ilike'),
  ];

  DatatableSettings datatableSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'nome', title: 'Nome'),
    DatatableCol(key: 'cpfcnpj', title: 'CPF/CNPJ'),
    DatatableCol(
        key: 'datacadastro', title: 'Cadastrado', format: DatatableFormat.date),
    DatatableCol(key: 'email', title: 'E-mail'),
    DatatableCol(key: 'telefone', title: 'Telefone'),
    //DatatableCol(key: 'logradouro||numero||bairro||cidade', title: 'Endereço'),
    DatatableCol(
      key: 'logradouro',
      title: 'Endereço',
      customRender: (itemMap, itemInstance) {
        var sol = itemInstance as Solicitante;
        var buffer = StringBuffer();
        buffer.write(sol.logradouro);
        if (sol.logradouro.trim() != '' && sol.numero != '') {
          buffer.write(', ');
        }
        if (sol.numero.trim() != '') {
          buffer.write('Nº: ');
        }
        buffer.write(sol.numero);
        if (sol.bairro.trim() != '') {
          buffer.write(' - ');
        }
        buffer.write(sol.bairro);
        return buffer.toString();
      },
    ),
  ]);

  DataFrame<Solicitante> solicitantes =
      DataFrame<Solicitante>(items: [], totalRecords: 0);

  Filters filtros =
      Filters(limit: 12, orderDir: 'desc', orderBy: 'datacadastro');

  Future<void> getAllSollictantes() async {
    try {
      simpleLoading.show(target: pageContainer);
      solicitantes = await service.getAll(filtros);
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao obter dados',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> onRequestData(Filters fil) async {
    filtros = fil;
    await getAllSollictantes();
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await getAllSollictantes();
  }

  void cadastrar() {
    _router
        .navigate(RoutePaths.solicitanteForm.toUrl(parameters: {'id': 'new'}));
  }

  void onRowClick(dynamic selected) {
    var item = selected as Solicitante;
    _router.navigate(
        RoutePaths.solicitanteForm.toUrl(parameters: {'id': '${item.id}'}));
  }
}
