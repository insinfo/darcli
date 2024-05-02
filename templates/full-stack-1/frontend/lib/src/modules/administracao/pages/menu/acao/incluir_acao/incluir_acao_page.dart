// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html' as html;

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

/// acao 87 = Incluir Local
/// Incluir Ação | funcionalidade cod_funcionalidade 6 | cod_modulo 2
/// Incluir Ação 9041
@Component(
  selector: 'incluir-acao-page',
  templateUrl: 'incluir_acao_page.html',
  styleUrls: ['incluir_acao_page.css'],
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
class IncluirAcaoPage implements OnActivate {
  final AcaoService _acaoService;
  final ModuloService _moduloService;
  final FuncionalidadeService _funcionalidadeService;

  final NotificationComponentService notificationComponentService;

  final html.Element hostElement;

  Acao acao = Acao.invalid();

  Filters filtrosModulos = Filters(limit: 100);
  Filters filtrosFuncionalidades = Filters(limit: 100);
  var modulos = DataFrame<Modulo>.newClear();
  var funcionalidades = DataFrame<Funcionalidade>.newClear();

  Modulo? _moduloSel;
  set moduloSel(Modulo? val) {
    _moduloSel = val;
    filtrosFuncionalidades.codModulo = val?.codModulo;
    loadFuncionalidades();
  }

  Modulo? get moduloSel {
    return _moduloSel;
  }

  Funcionalidade? _funcionalidadeSel;
  set funcionalidadeSel(Funcionalidade? val) {
    _funcionalidadeSel = val;
    acao.codFuncionalidade = val?.codFuncionalidade ?? -1;
  }

  Funcionalidade? get funcionalidadeSel {
    return _funcionalidadeSel;
  }

  IncluirAcaoPage(
      this._acaoService,
      this.hostElement,
      this.notificationComponentService,
      this._moduloService,
      this._funcionalidadeService);

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    currentQueryParameters = current.queryParameters;
    await loadModulos();
  }

  Map<String, String> currentQueryParameters = {};

  Future<void> loadModulos({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      modulos = await _moduloService.all(filtrosModulos);
    } catch (e, s) {
      print('IncluirAcaoPage@loadModulos $e $s');
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
      funcionalidades =
          await _funcionalidadeService.all(filtrosFuncionalidades);
    } catch (e, s) {
      print('IncluirAcaoPage@loadFuncionalidades $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  bool validateForm() {
    if (moduloSel == null) {
      SimpleDialogComponent.showAlert('Selecione um Modulo!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (acao.codFuncionalidade == -1) {
      SimpleDialogComponent.showAlert('Selecione uma Funcionalidade!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (acao.nomAcao.trim().length < 3) {
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
      await _acaoService.insert(acao);

      notificationComponentService.notify('Ação cadastrada com sucesso.');
      acao = Acao.invalid();
    } catch (e, s) {
      print('IncluirAcaoPage@salva $e $s');
      SimpleDialogComponent.showAlert(
        'Não foi possível cadastrar, verifique as informações preenchidas.',
        subMessage: '$e',
        dialogColor: DialogColor.DANGER,
      );
    } finally {
      simpleLoading.hide();
    }
  }
}
