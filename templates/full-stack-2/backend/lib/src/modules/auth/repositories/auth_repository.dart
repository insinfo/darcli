import 'package:esic_backend/src/shared/utils/utils.dart';
import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class AuthRepository {
  final DbLayer db;
  AuthRepository(this.db);

  Future<Solicitante> authenticateSite(LoginPayload loginPayload) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitante')
        .whereSafe('cpfcnpj', '=', loginPayload.login)
        .whereSafe('chave', '=', Utils.stringToMd5(loginPayload.password))
        .limit(1);

    var dados = await query.getAsMap();

    if (dados.isNotEmpty == true) {
      var sol = Solicitante.fromMap(dados[0]);

      if (sol.confirmado != 1) {
        throw UserNotActivatedException();
      }
      return sol;
    }
    throw UserNotFoundException();
  }
}
