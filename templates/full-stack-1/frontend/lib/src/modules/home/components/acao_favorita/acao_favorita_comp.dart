import 'dart:html' as html;

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

/// <acao-favorita-comp></acao-favorita-comp>
@Component(
  selector: 'acao-favorita-comp',
  templateUrl: 'acao_favorita_comp.html',
  styleUrls: ['acao_favorita_comp.css'],
  directives: [
    coreDirectives,
    NoDataComponent,
  ],
)
class AcaoFavoritaComp implements OnInit {
  final AcaoFavoritaService _acaoFavoritaService;
  final AuthService _authService;
  //final SimpleLoading _simpleLoading = SimpleLoading();
  final html.Element rootElement;
  final Router _router;

  @Input()
  bool homeLayout = false;

  AcaoFavoritaComp(this._acaoFavoritaService, this.rootElement, this._router,
      this._authService);

  DataFrame<AcaoFavorita> get favoritos => _acaoFavoritaService.favoritos;

  /// saber se ja esta pagina ja é um favorito
  bool get currentPageIsFavorito =>
      favoritos.where((f) => f.codAcao == codAcaoCurrentPage).isNotEmpty;

  int? get codAcaoCurrentPage => _router.current != null
      ? int.tryParse(_router.current!.queryParameters['a'].toString())
      : null;

  Future<void> favoriteCurrentPage() async {
    final loading = SimpleLoading();
    try {
      loading.show(target: rootElement);
      if (codAcaoCurrentPage != null) {
        await _acaoFavoritaService.insertFromAcao(codAcaoCurrentPage!);
        _acaoFavoritaService.isLoadFavoritos = false;
        await loadFavoritos(showLoading: false);
      }
    } catch (e, s) {
      print('AcaoFavoritaComp@favoriteCurrentPage $e $s');
    } finally {
      loading.hide();
    }
  }

  Filters filtrosFavoritos = Filters(limit: 50);

  Future<void> loadFavoritos({bool showLoading = true}) async {
    final loading = SimpleLoading();
    try {
      if (showLoading) {
        loading.show(target: rootElement);
      }
      _acaoFavoritaService.favoritos = await _acaoFavoritaService.all(
          _authService.authPayload.numCgm, filtrosFavoritos);
    } catch (e, s) {
      print('AcaoFavoritaComp@loadFavoritos $e $s');
    } finally {
      if (showLoading) {
        loading.hide();
      }
    }
  }

  void reload() {
    loadFavoritos();
  }

  void ordernarByDataDesc() {
    filtrosFavoritos.orderBy = 'data_cadastro';
    filtrosFavoritos.orderDir = 'desc';
    reload();
  }

  void ordernarByDataAsc() {
    filtrosFavoritos.orderBy = 'data_cadastro';
    filtrosFavoritos.orderDir = 'asc';
    reload();
  }

  void ordernarByNomeAsc() {
    filtrosFavoritos.orderBy = 'nom_acao';
    filtrosFavoritos.orderDir = 'asc';
    reload();
  }

  @override
  void ngOnInit() async {
    // print('AcaoFavoritaComp@ngOnInit ${_authService.loginStatus}');
    if (_acaoFavoritaService.isLoadFavoritos == false &&
        _authService.loginStatus == LoginStatus.logged) {
      await loadFavoritos();
      _acaoFavoritaService.isLoadFavoritos = true;
    }
  }

  void irParaFavorito(AcaoFavorita fav) {
    //http://localhost:8005/#/restrito/consultar-processo?a=67&f=19&m=5&g=1
    var menus = _authService.menus.where((m) => m.codAcao == fav.codAcao);
    if (menus.isNotEmpty) {
      var menu = menus.first;
      var queryParameters = {
        'a': '${menu.codAcao}',
        'f': '${menu.codFuncionalidade}',
        'm': '${menu.codModulo}',
        'g': '${menu.codGestao}',
      };
      _router.navigate(RoutePaths.mapRotaToAcao(fav.codAcao).toUrl(),
          NavigationParams(queryParameters: queryParameters));
    }
  }

  Future<void> removeFavorito(AcaoFavorita fav) async {
    final loading = SimpleLoading();
    try {
      loading.show(target: rootElement);
      await _acaoFavoritaService.deleteById(fav.id);
      await loadFavoritos(showLoading: false);
    } catch (e, s) {
      print('AcaoFavoritaComp@removeFavorito $e $s');
    } finally {
      loading.hide();
    }
  }
}
