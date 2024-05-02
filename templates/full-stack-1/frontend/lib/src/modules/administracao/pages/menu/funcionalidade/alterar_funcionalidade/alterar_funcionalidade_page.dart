// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html' as html;

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

/// Alterar Funcionalidade
@Component(
  selector: 'alterar-funcionalidade-page',
  templateUrl: 'alterar_funcionalidade_page.html',
  styleUrls: ['alterar_funcionalidade_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    CustomSelectComponent,
    AcaoFavoritaComp,
  ],
  providers: [],
)
class AlterarFuncionalidadePage implements OnActivate {
  AlterarFuncionalidadePage(this.hostElement, this.notificationComponentService,
      this._moduloService, this._funcionalidadeService);

  final ModuloService _moduloService;
  final FuncionalidadeService _funcionalidadeService;

  final NotificationComponentService notificationComponentService;

  final html.Element hostElement;

  @ViewChild('modalAlterar')
  CustomModalComponent? modalAlterar;

  Funcionalidade funcionalidadeSelected = Funcionalidade.invalid();

  var filtrosFuncionalidade = Filters(limit: 12, offset: 0);

  var modulos = DataFrame<Modulo>.newClear();

  var funcionalidades = DataFrame<Funcionalidade>.newClear();

  Modulo? _moduloFiltroSel;
  set moduloFiltroSel(Modulo? val) {
    _moduloFiltroSel = val;
    filtrosFuncionalidade.codModulo = val?.codModulo;
    loadFuncionalidades();
  }

  Modulo? get moduloFiltroSel {
    return _moduloFiltroSel;
  }

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(
        key: 'cod_funcionalidade',
        title: 'Código',
        sortingBy: 'cod_funcionalidade',
        enableSorting: true),
    DatatableCol(
        key: 'nom_funcionalidade',
        title: 'Nome',
        sortingBy: 'nom_funcionalidade',
        enableSorting: true),
  ]);
  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(
        field: 'nom_funcionalidade', operator: 'like', label: 'Nome'),
    DatatableSearchField(
        field: 'cod_funcionalidade', operator: '=', label: 'Código'),
  ];
  void onDtRequestData(e) {
    loadFuncionalidades();
  }

  void onSelectItem(Funcionalidade sel) async {
    funcionalidadeSelected = sel;
    modalAlterar?.open();
  }

  Future<void> loadModulos({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      modulos = await _moduloService.all(Filters(limit: 100));
    } catch (e, s) {
      print('AlterarAcaoPage@loadModulos $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> loadFuncionalidades({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      funcionalidades = await _funcionalidadeService.all(filtrosFuncionalidade);
    } catch (e, s) {
      print('AlterarFuncionalidadePage@loadFuncionalidades $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await loadFuncionalidades();
    await loadModulos();
  }

  bool validateForm() {
    if (funcionalidadeSelected.nomFuncionalidade.trim().length < 3) {
      SimpleDialogComponent.showAlert('Nome não pode estar vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    return true;
  }

  Future<void> salvar() async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show(target: hostElement);
      if (!validateForm()) {
        return;
      }
      await _funcionalidadeService.update(funcionalidadeSelected);
      modalAlterar?.close();
      loadFuncionalidades(showLoading: false);
      final msg =
          'Funcionalidade "${funcionalidadeSelected.nomFuncionalidade}" atualizada com sucesso.';
      notificationComponentService.notify(msg,
          type: NotificationCompColor.info, icon: 'check');
    } catch (e, s) {
      final msg =
          'Não foi possível atualizar a Funcionalidade, verifique as informações preenchidas!';
      print('AlterarFuncionalidadePage@salvar $e $s');
      SimpleDialogComponent.showAlert(msg,
          subMessage: '$e $s', dialogColor: DialogColor.DANGER);
      notificationComponentService.notify(msg,
          type: NotificationCompColor.danger, icon: 'warning');
    } finally {
      simpleLoading.hide();
    }
  }
}
