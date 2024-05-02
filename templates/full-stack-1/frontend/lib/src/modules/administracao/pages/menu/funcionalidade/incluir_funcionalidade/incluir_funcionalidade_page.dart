// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html' as html;

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

/// Incluir Funcionalidade
@Component(
  selector: 'incluir-funcionalidade-page',
  templateUrl: 'incluir_funcionalidade_page.html',
  styleUrls: ['incluir_funcionalidade_page.css'],
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
class IncluirFuncionalidadePage implements OnActivate {
  final ModuloService _moduloService;
  final FuncionalidadeService _funcionalidadeService;

  final NotificationComponentService notificationComponentService;

  final html.Element hostElement;

  Funcionalidade funcionalidade = Funcionalidade.invalid();

  Filters filtrosModulos = Filters(limit: 100);

  var modulos = DataFrame<Modulo>.newClear();

  Modulo? _moduloSel;
  set moduloSel(Modulo? val) {
    _moduloSel = val;
    funcionalidade.codModulo = _moduloSel?.codModulo ?? -1;
  }

  Modulo? get moduloSel {
    return _moduloSel;
  }

  IncluirFuncionalidadePage(this.hostElement, this.notificationComponentService,
      this._moduloService, this._funcionalidadeService);

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
      print('IncluirFuncionalidadePage@loadModulos $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  bool validateForm() {
    if (moduloSel == null || funcionalidade.codModulo == -1) {
      SimpleDialogComponent.showAlert('Selecione um Modulo!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    if (funcionalidade.nomFuncionalidade.trim().length < 3) {
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
      await _funcionalidadeService.insert(funcionalidade);

      notificationComponentService
          .notify('Funcionalidade cadastrada com sucesso.');
      funcionalidade = Funcionalidade.invalid();
    } catch (e, s) {
      print('IncluirFuncionalidadePage@salva $e $s');
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
