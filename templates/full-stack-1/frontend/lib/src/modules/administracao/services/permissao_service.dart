import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class PermissaoService extends RestServiceBase {
  PermissaoService(RestConfig conf) : super(conf);

  String path = '/administracao/permissoes';

  /// lista todas os modulos juntamente com funcionalidades, ações e pemissões de um usuario
  Future<DataFrame<Modulo>> modsFuncsAcoesPermissoesOfUser(
      int numCgm, String anoExercicio, Filters filtros) {
    return getDataFrame<Modulo>('$path/$numCgm/$anoExercicio',
        builder: (x) => Modulo.fromMap(x), filtros: filtros);
  }

  Future<void> definirPermissao(
      int numCgm, String anoExercicio, List<int> codsAcaoPermitidos) async {
    var resp = await rawPut(
        conf.getBackendUri('$path/$numCgm/$anoExercicio'),
        headers: conf.headers,
        body: jsonEncode({'codsAcaoPermitidos': codsAcaoPermitidos}));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }
}
