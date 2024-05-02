import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class UsuarioService extends RestServiceBase {
  UsuarioService(RestConfig conf) : super(conf);

  String path = '/usuarios-web';

  Future<UsuarioWeb> getById(int id) async {
    return await getEntity<UsuarioWeb>('$path/$id',
        builder: UsuarioWeb.fromMap);
  }

  /// cadastra
  Future<void> insert(UsuarioWeb item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(UsuarioWeb item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<UsuarioWeb> items) async {
    await deleteAllEntity(items, path);
  }
}
