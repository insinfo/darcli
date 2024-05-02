import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class MenuService extends RestServiceBase {
  final AuthService _authService;

  MenuService(RestConfig conf, this._authService) : super(conf) {}

  String path = '/administracao/menu';

  Future<List<MenuItem>> getAll({bool forceRefresh = false}) async {
    // var cache = LocalStorageMapCache(
    //   'menuItems_${_authService.authPayload.numCgm}',
    //   cacheValidDuration: Duration(minutes: 10),
    // );
    // bool shouldRefreshFromApi =
    //     (await cache.isShouldRefresh()) || forceRefresh == true;

    //if (shouldRefreshFromApi) {
    //final items = await getListEntity<MenuItem>(path, builder:  MenuItem.fromMap);
    final jsonString =
        await getJson('$path/${_authService.authPayload.numCgm}');
    final mapList =
        (jsonString as List).map((e) => e as Map<String, dynamic>).toList();
    // cache.putItem(json);
    final menuItems = mapList.map((e) => MenuItem.fromMap(e)).toList();
    //print('MenuService@getAll pegou da API');
    return menuItems;
    //}
    // print('MenuService@getAll pegou do cache');
    // var data = await cache.getItem();
    // final items = data.map((e) => MenuItem.fromMap(e)).toList();
    // return items;
  }
}
