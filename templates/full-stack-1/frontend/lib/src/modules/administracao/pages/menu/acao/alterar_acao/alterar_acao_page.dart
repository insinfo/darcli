// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html' as html;

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

/// Alterar Ação 9042
@Component(
  selector: 'alterar-acao-page',
  templateUrl: 'alterar_acao_page.html',
  styleUrls: ['alterar_acao_page.css'],
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
class AlterarAcaoPage implements OnActivate {
  AlterarAcaoPage(
      this._acaoService,
      this.hostElement,
      this.notificationComponentService,
      this._moduloService,
      this._funcionalidadeService);

  final AcaoService _acaoService;
  final ModuloService _moduloService;
  final FuncionalidadeService _funcionalidadeService;
  final NotificationComponentService notificationComponentService;

  final html.Element hostElement;

  @ViewChild('modalAlterar')
  CustomModalComponent? modalAlterar;

  Acao acaoSelected = Acao.invalid();

  var filtrosAcao = Filters(limit: 12, offset: 0);
  var filtrosFuncionalidade = Filters(limit: 100, offset: 0);

  var modulos = DataFrame<Modulo>.newClear();
  var funcionalidadesForFiltro = DataFrame<Funcionalidade>.newClear();
  var acoes = DataFrame<Acao>.newClear();

  Modulo? _moduloFiltroSel;
  set moduloFiltroSel(Modulo? val) {
    _moduloFiltroSel = val;
    filtrosAcao.codModulo = val?.codModulo;
    filtrosFuncionalidade.codModulo = val?.codModulo;
    loadFuncionalidades();
  }

  Modulo? get moduloFiltroSel {
    return _moduloFiltroSel;
  }

  Funcionalidade? _funcionalidadeFiltroSel;
  set funcionalidadeFiltroSel(Funcionalidade? val) {
    _funcionalidadeFiltroSel = val;
    filtrosAcao.codFuncionalidade = val?.codFuncionalidade;
  }

  Funcionalidade? get funcionalidadeFiltroSel {
    return _funcionalidadeFiltroSel;
  }

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(
        key: 'cod_acao',
        title: 'Código',
        sortingBy: 'cod_acao',
        enableSorting: true),
    DatatableCol(
        key: 'nom_acao',
        title: 'Nome',
        sortingBy: 'nom_acao',
        enableSorting: true),
  ]);
  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nom_acao', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'cod_acao', operator: '=', label: 'Código'),
  ];
  void onDtRequestData(e) {
    loadAcoes();
  }

  void onSelectItem(Acao acao) async {
    acaoSelected = acao;
    modalAlterar?.open();
  }

  Future<void> loadAcoes({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      acoes = await _acaoService.all(filtrosAcao);
    } catch (e, s) {
      print('AlterarAcaoPage@loadAcoes $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
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
      funcionalidadesForFiltro =
          await _funcionalidadeService.all(filtrosFuncionalidade);
    } catch (e, s) {
      print('AlterarAcaoPage@loadFuncionalidades $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await loadAcoes();
    await loadModulos();
  }

  bool validateForm() {
    if (acaoSelected.nomAcao.trim().length < 3) {
      SimpleDialogComponent.showAlert('Descrição não pode estar vazio!',
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
      await _acaoService.update(acaoSelected);
      modalAlterar?.close();
      loadAcoes(showLoading: false);
      final msg = 'Ação "${acaoSelected.nomAcao}" atualizada com sucesso.';
      notificationComponentService.notify(msg,
          type: NotificationCompColor.info, icon: 'check');
    } catch (e, s) {
      final msg =
          'Não foi possível atualizar a Ação, verifique as informações preenchidas!';
      print('AlterarAcaoPage@salvar $e $s');
      SimpleDialogComponent.showAlert(msg,
          subMessage: '$e $s', dialogColor: DialogColor.DANGER);
      notificationComponentService.notify(msg,
          type: NotificationCompColor.danger, icon: 'warning');
    } finally {
      simpleLoading.hide();
    }
  }
}
