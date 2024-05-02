import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/rest_config.dart';
import 'package:new_sali_frontend/src/shared/services/rest_service_base.dart';

class UsuarioService extends RestServiceBase {
  UsuarioService(RestConfig conf) : super(conf);

  String path = '/administracao/usuarios';

  Future<DataFrame<Usuario>> all(Filters filtros) async {
    var data = await getDataFrame<Usuario>('$path',
        builder: (x) => Usuario.fromMap(x), filtros: filtros);
    return data;
  }

  Future<Usuario> insert(Usuario usuario) async {
    var data = await insertEntity(usuario, '$path');
    return Usuario.fromMap(data);
  }

  Future<Usuario> update(Usuario usuario) async {
    var data = await updateEntity(usuario, '$path');
    return Usuario.fromMap(data);
  }
}
