import 'package:eloquent/eloquent.dart';
import 'package:sibem_backend/sibem_backend.dart';

class AuthRepository {
  final Connection db;
  AuthRepository(this.db);

  Future<UsuarioWeb> authenticateSite(LoginPayload loginPayload) async {
    final userExist = await db
        .table(UsuarioWeb.fqtn)
        .selectRaw('*')
        .where('login', '=', loginPayload.login)
        .first();

    if (userExist == null) {
      throw UserNotFoundException();
    }

    final userMap = await db
        .table(UsuarioWeb.fqtn)
        .selectRaw('*')
        .where('login', '=', loginPayload.login)
        .where('chave', '=', Criptografia.stringToMd5(loginPayload.password))
        .first();

    if (userMap == null) {
      throw InvalidPasswordException();
    }

    final user = UsuarioWeb.fromMap(userMap);

    if (user.isConfirmado == false) {
      throw UserNotActivatedException();
    }
    //verifica se este usuario ja se cadastrou e se ja foi validado
    try {
      print('user.isCandidato ${user.isCandidato}');
      if (user.isCandidato) {
        final cand = await CandidatoWebRepository(db).getByCpf(user.login);
         print('cand.validado ${cand.validado}');
        user.isValidado = cand.validado == true;
      } else {
        final emp =
            await EmpregadorWebRepository(db).getByCpfOrCnpj(user.login);
        user.isValidado = emp.statusValidacao == EmpregadorStatusValidacao.validado;
      }
    } catch (e,s) {
      print('authenticateSite $e $s');
      user.isValidado = false;
    }

    return user;
  }

  Future<UsuarioWeb> getByLogin(String login) async {
    final map = await db
        .table(UsuarioWeb.fqtn)
        .selectRaw('*')
        .where('login', '=', login)
        .first();

    if (map != null) {
      final user = UsuarioWeb.fromMap(map);
      return user;
    }
    throw UserNotFoundException();
  }

  Future<UsuarioWeb> getByLoginAndSenha(
      String login, String senhaSemMD5) async {
    return UsuarioWeb.fromMap(
        await getByLoginAndSenhaAsMap(login, senhaSemMD5));
  }

  Future<Map<String, dynamic>> getByLoginAndSenhaAsMap(
      String login, String senhaSemMD5) async {
    final query = db
        .table(UsuarioWeb.fqtn)
        .selectRaw('*')
        .where('login', '=', login)
        .where('chave', '=', Criptografia.stringToMd5(senhaSemMD5));
    final map = await query.first();
    if (map != null) {
      return map;
    }
    throw UserNotFoundException();
  }

  Future<void> updateSenha(String novaSenha, int id) async {
    await db
        .table(UsuarioWeb.fqtn)
        .where('id', '=', id)
        .update({'chave': Criptografia.stringToMd5(novaSenha)});
  }
}
