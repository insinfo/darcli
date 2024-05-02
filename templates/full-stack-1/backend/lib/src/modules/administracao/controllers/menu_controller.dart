import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class MenuController {
  static String cacheName = 'menu_principal';

  /// lista o menu para o usuario
  static Future<dynamic> getMenu(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final token = req.authToken;
      // o anoExercicio é sempre 2023 pois as permições seram sempre 2023 a patir do app
      final anoExercicio = '2023'; //token.anoExercicio;

      //final filtros = Filters.fromMap(req.queryParameters);

      // final cache = DiskListMapCache(
      //     req.uri.toString(), AppConfig.inst().appCacheDir,
      //     cacheName: '${cacheName}_${token.numCgm}',
      //     cacheValidDuration: const Duration(days: 365));

      // bool shouldRefreshFromApi =
      //     ((await cache.isShouldRefresh()) || filtros.forceRefresh == true);

      // if (shouldRefreshFromApi) {
      conn = await req.dbConnect();
      final items =
          await MenuRepository(conn).getHierarquia(anoExercicio, token.numCgm);
      await conn.disconnect();
      final maps = items.map((e) => e.toMap()).toList();
      // cache.putItem(maps);
      return res.responseJson(maps);
      // }

      // final items = await cache.getItem();
      // return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('MenuController@getMenu $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
