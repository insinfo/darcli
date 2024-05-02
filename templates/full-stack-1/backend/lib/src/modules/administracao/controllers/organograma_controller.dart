import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class OrganogramaController {

   static String cacheName = 'organogramas';

  /// lista a hierarquia de Organograma como uma arvore 
  static Future<dynamic> getHierarquia(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {


      final filtros = Filters.fromMap(req.queryParameters);

      final cache = DiskMapCache(
          req.uri.toString(), AppConfig.inst().appCacheDir,
          cacheName: cacheName, cacheValidDuration: const Duration(days: 60));

      bool shouldRefreshFromApi =
          ((await cache.isShouldRefresh()) || filtros.forceRefresh == true);

      if (shouldRefreshFromApi) {
        conn = await req.dbConnect();
        final page = await OrganogramaRepository(conn).getHierarquiaAsMap(filtros);
        await conn.disconnect();
        final map = page.toMap();
        cache.putItem(map);
        return res.responseJson(map);
      }

      final items = await cache.getItem();

      return res.responseJson(items);

    } catch (e, s) {
      await conn?.disconnect();
      print('SetorController@getHierarquia $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    } 
  }

  // static Future<dynamic> getHierarquia(
  //     RequestContext req, ResponseContext res) async {
  //   Connection? conn;
  //   try {
  //     conn = await req.dbConnect();
  //     final result = await OrganogramaRepository(conn).getHierarquia();
  //     await conn.disconnect();
  //     res.responseModelList(result);
  //   } catch (e, s) {
  //     await conn?.disconnect();
  //     print('OrganogramaController@getHierarquia $e $s');
  //     return res.responseError(StatusMessage.ERROR_GENERIC,
  //         exception: e, stackTrace: s);
  //   } 
  // }
}
