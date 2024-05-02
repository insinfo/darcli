import 'package:new_sali_core/new_sali_core.dart';

import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'dart:html' as html;

///  Pagina `Relatório de Auditoria` Cod Ação = 30
@Component(
  selector: 'relatorio-auditoria-page',
  templateUrl: 'relatorio_auditoria_page.html',
  styleUrls: ['relatorio_auditoria_page.css'],
  directives: [
    routerDirectives,
    customFormDirectives,
    CustomSelectComponent,
    DatatableComponent,
    CustomModalComponent,
    AcaoFavoritaComp,
  ],
)
class RelatorioAuditoriaPage implements OnInit {
  final AdministracaoService _administracaoService;

  final SimpleLoading _simpleLoading = SimpleLoading();

  RelatorioAuditoriaPage(this._administracaoService);

  @ViewChild('modalUsuario')
  CustomModalComponent? modalUsuario;

  @ViewChild('inputUsuario')
  html.InputElement? inputUsuario;

  @ViewChild('datatableUsuario')
  DatatableComponent? datatableUsuario;

  DataFrame<Auditoria> auditorias = DataFrame<Auditoria>.newClear();
  DataFrame<Modulo> modulos = DataFrame<Modulo>.newClear();
  DataFrame<Usuario> usuarios = DataFrame<Usuario>.newClear();

  Filters filtrosAuditoria = Filters(limit: 12, offset: 0, orderDir: 'asc');
  Filters filtrosUsuarios = Filters(limit: 12, offset: 0);

  @Input('limitPerPageOptions')
  List<int> limitPerPageOptions = [
    1,
    5,
    6,
    7,
    10,
    12,
    20,
    24,
    25,
    50,
    100,
    500,
    1000,
    // 2000
  ];

  /// configuração do DataTable que lista registros de auditoria
  DatatableSettings dtsAuditoria = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'numcgm', title: 'CGM'),
    DatatableCol(key: 'username', title: 'Usuário'),
    DatatableCol(key: 'nom_modulo', title: 'Módulo'),
    DatatableCol(key: 'nom_funcionalidade', title: 'Funcionalidade'),
    DatatableCol(key: 'nom_acao', title: 'Ação'),
    DatatableCol(key: 'objeto', title: 'Objeto'),
    DatatableCol(
        key: 'timestamp', title: 'Data', format: DatatableFormat.dateTime),
  ]);
  List<DatatableSearchField> dtAuditoriaSearchIn = <DatatableSearchField>[
    DatatableSearchField(field: 'objeto', operator: 'like', label: 'Objeto'),
  ];

  /// configuração do DataTable que lista usuarios
  DatatableSettings dtsUsuario = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'numcgm', title: 'CGM'),
    DatatableCol(key: 'nom_cgm', title: 'Nome'),
    DatatableCol(key: 'username', title: 'Username'),
  ]);
  List<DatatableSearchField> dtUsuarioSearchIn = <DatatableSearchField>[
    DatatableSearchField(field: 'nom_cgm', operator: 'like', label: 'Nome'),
    DatatableSearchField(
        field: 'username', operator: 'like', label: 'Username'),
  ];

  @override
  void ngOnInit() async {
    // await loadAuditorias();
    await loadModulos();
    await loadUsuarios();
  }

  Future<void> loadAuditorias() async {
    try {
      _simpleLoading.show();
      auditorias = await _administracaoService.getAuditorias(filtrosAuditoria);
    } catch (e, s) {
      print('RelatorioAuditoriaPage@loadAuditorias $e $s');
      SimpleDialogComponent.showAlert(
          'Aconteceu um erro ao buscar registros de Auditoria.',
          subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  Future<void> loadModulos() async {
    try {
      _simpleLoading.show();
      modulos = await _administracaoService.getModulos(Filters(
          limit: 100, offset: 0, orderBy: 'nom_modulo', orderDir: 'asc'));
    } catch (e, s) {
      print('RelatorioAuditoriaPage@loadModulos $e $s');
      SimpleDialogComponent.showAlert(
          'Aconteceu um erro ao buscar lista de modulos.',
          subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  Future<void> loadUsuarios() async {
    try {
      _simpleLoading.show();
      usuarios = await _administracaoService.getUsuarios(filtrosUsuarios);
    } catch (e, s) {
      print('RelatorioAuditoriaPage@loadUsuarios $e $s');
      SimpleDialogComponent.showAlert(
          'Aconteceu um erro ao buscar lista de usuários.',
          subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  /// quando acontece uma ação no dataTable `lista de auditoria` como mudança de pagina faz o carregamento dos dados
  void onDtAuditoriaRequestData(f) {
    loadAuditorias();
  }

  /// quando acontece uma ação no dataTable `lista de usuários` como mudança de pagina faz o carregamento dos dados
  void onDtUsuarioRequestData(f) {
    loadUsuarios();
  }

  void openModalUsuario() {
    modalUsuario?.open();
    datatableUsuario?.setInputSearchFocus();
  }

  void onSelectUsuario(Usuario user) {
    inputUsuario?.value = user.nomCgm;
    filtrosAuditoria.codCgm = user.numCgm;
    modalUsuario?.close();
  }

  void onSelectModulo(Modulo item) {
    filtrosAuditoria.codModulo = item.codModulo;
  }

  void imprimirRelatorioAuditoria() async {
    final bytes = await geraPDFRelatorioAuditoria(auditorias);
    FrontUtils.printFileBytes(bytes, 'application/pdf');
  }

  void salvarRelatorioAuditoria() async {
    final bytes = await geraPDFRelatorioAuditoria(auditorias);
    FrontUtils.downloadFile(
        bytes, 'Relatorio Auditoria.pdf', 'application/pdf');
  }
}
