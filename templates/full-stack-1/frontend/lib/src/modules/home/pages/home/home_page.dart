import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/modules/estatistica/components/process_setor_primero_tramite/process_setor_primero_tramite.dart';
import 'package:new_sali_frontend/src/modules/estatistica/components/processos_assunto/processos_assunto_comp.dart';
import 'package:new_sali_frontend/src/modules/estatistica/components/processos_classificacao/processos_classificacao_comp.dart';
import 'package:new_sali_frontend/src/modules/estatistica/components/total_processos_ano/processos_ano_comp.dart';
import 'package:new_sali_frontend/src/modules/estatistica/components/total_processos_situacao/processos_situacao_comp.dart';
import 'package:new_sali_frontend/src/modules/protocolo/services/processo_favorito_service.dart';
import 'package:new_sali_frontend/src/shared/directives/contenteditable_model_directive.dart';

import 'dart:html' as html;

@Component(
  selector: 'home-page',
  templateUrl: 'home_page.html',
  styleUrls: ['home_page.css'],
  directives: [
    routerDirectives,
    coreDirectives,
    formDirectives,
    ProcessSetorPrimeroTramiteComp,
    ProcessosAnoComp,
    ProcessosSituacaoComp,
    ProcessosClassificacaoComp,
    ProcessosAssuntoComp,
    NoDataComponent,
    ContentEditableModelDirective,
    FooterComponent,
    AcaoFavoritaComp,
  ],
  pipes: [commonPipes],
  exports: [],
)
class HomePage implements OnInit, OnActivate {
  final ProcessoFavoritoService _processoFavoritoService;
  final AuthService _authService;

  final limitProcessosFavoritos = 20;

  //final SimpleLoading _simpleLoading = SimpleLoading();

  @ViewChild('processosAnoComp')
  ProcessosAnoComp? processosAnoComp;

  @ViewChild('processosSituacaoComp')
  ProcessosSituacaoComp? processosSituacaoComp;

  @ViewChild('processosClassificacaoComp')
  ProcessosClassificacaoComp? processosClassificacaoComp;

  @ViewChild('processosAssuntoComp')
  ProcessosAssuntoComp? processosAssuntoComp;

  @ViewChild('processSetorPrimeroTramiteComp')
  ProcessSetorPrimeroTramiteComp? processSetorPrimeroTramiteComp;

  @ViewChild('acaoFavoritaComp')
  AcaoFavoritaComp? acaoFavoritaComp;

  @ViewChild('containerFavoritos')
  html.Element? containerFavoritos;

  final html.Element rootElement;

  // ignore: unused_field
  final Router _router;

  HomePage(this._processoFavoritoService, this.rootElement, this._router,
      this._authService);

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    //print('HomePage@onActivate $previous $current');
    await loadProcsFavoritos();

    await acaoFavoritaComp?.loadFavoritos();
    await processosAnoComp?.load();
    await processosSituacaoComp?.load();
    await processosClassificacaoComp?.load();
    await processosAssuntoComp?.load();
    await processSetorPrimeroTramiteComp?.load();
  }

  @override
  void ngOnInit() {
    print('HomePage@ngOnInit');
  }

  DataFrame<ProcessoFavorito> procsFavoritos = DataFrame.newClear();
  Filters filtrosFavoritos = Filters(limit: 50);

  Future<void> loadProcsFavoritos({bool showLoading = true}) async {
    final loading = SimpleLoading();
    try {
      if (showLoading) {
        loading.show(target: containerFavoritos);
      }
      var favs = await _processoFavoritoService.all(
          _authService.authPayload.numCgm, filtrosFavoritos);
      favs.forEach((f) {
        if (f.descricao == null || f.descricao == '') {
          f.descricao = 'Sem descrição';
        }
      });
      procsFavoritos = favs;
    } catch (e, s) {
      print('HomePage@loadProcsFavoritos $e $s');
    } finally {
      if (showLoading) {
        loading.hide();
      }
    }
  }

  /// vai para pagina Consultar Processo e lista processos do suaurio logado
  void goToConsultaProcessoOfLogged() {
    
  }

  void reloadFavoritos() async {
    loadProcsFavoritos();
  }

  void ordernarByDataDesc() {
    filtrosFavoritos.orderBy = 'data_cadastro';
    filtrosFavoritos.orderDir = 'desc';
    reloadFavoritos();
  }

  void ordernarByDataAsc() {
    filtrosFavoritos.orderBy = 'data_cadastro';
    filtrosFavoritos.orderDir = 'asc';
    reloadFavoritos();
  }

  void ordernarByDescricaoAsc() {
    filtrosFavoritos.orderBy = 'descricao';
    filtrosFavoritos.orderDir = 'asc';
    reloadFavoritos();
  }

  void ordernarByProcessoAsc() {
    filtrosFavoritos.orderBy = 'cod_processo/ano_exercicio';
    filtrosFavoritos.orderDir = 'asc';
    reloadFavoritos();
  }

  void ordernarByProcessoDesc() {
    filtrosFavoritos.orderBy = 'cod_processo/ano_exercicio';
    filtrosFavoritos.orderDir = 'desc';
    reloadFavoritos();
  }

  Future<void> removeFavorito(ProcessoFavorito fav) async {
    final loading = SimpleLoading();
    try {
      loading.show(target: containerFavoritos);
      await _processoFavoritoService.deleteById(fav.id);
      procsFavoritos.remove(fav);
    } catch (e, s) {
      print('HomePage@removeFavorito $e $s');
    } finally {
      loading.hide();
    }
  }

  Future<void> irParaProcFavorito(ProcessoFavorito fav) async {
    // _router.navigate(
    //     RoutePaths.visualizaProcesso.toUrl(parameters: {
    //       'ae': '${fav.anoExercicio}',
    //       'cdp': '${fav.codProcesso}'
    //     }),
    //     NavigationParams(
    //         queryParameters: {'a': '67', 'f': '19', 'm': '5', 'g': '1'}));
  }

  Future<void> abilitarEdicaoFavorito(
      ProcessoFavorito fav, html.Element fieldDescricao) async {
    fieldDescricao.contentEditable = 'true';
    // if (fav.descricao == null || fav.descricao == 'Sem descrição') {
    //   fav.descricao = '';
    // }
    fieldDescricao.focus();
  }

  bool isAtualizandoFavorito = false;
  Future<void> atualizaFavorito(ProcessoFavorito fav) async {
    final loading = SimpleLoading();
    if (isAtualizandoFavorito == false) {
      try {
        isAtualizandoFavorito = true;
        loading.show(target: containerFavoritos);
        await _processoFavoritoService.updateById(fav);
      } catch (e, s) {
        print('HomePage@atualizaFavorito $e $s');
      } finally {
        isAtualizandoFavorito = false;
        loading.hide();
      }
    }
  }
}
