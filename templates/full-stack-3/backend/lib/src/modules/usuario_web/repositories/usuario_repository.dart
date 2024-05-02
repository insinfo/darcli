import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class UsuarioWebRepository {
  final Connection db;
  UsuarioWebRepository(this.db);

  Future<bool> isExistByLogin(String login, {Connection? connection}) async {
    final conn = connection ?? db;
    final loginVal = login.replaceAll(RegExp(r'[^0-9]'), '');

    final isExist = await conn
        .table(UsuarioWeb.fqtn)
        .whereRaw(" login = ? ", [loginVal]).first();

    return isExist != null;
  }

  Future<int> create(UsuarioWeb item,
      {bool checkIfExist = false, Connection? connection}) async {
    final conn = connection ?? db;
    if (checkIfExist) {
      final login = item.login.replaceAll(RegExp(r'[^0-9]'), '');
      final isExist = await conn
          .table(UsuarioWeb.fqtn)
          .whereRaw(" login = ? ", [login]).first();
      if (isExist != null) {
        throw Exception('Este usuário já está cadastrado!');
      }
    }

    item.chave = Criptografia.stringToMd5(item.chave);
    item.nome = item.nome.trim().toTitleCase();
    item.id = await conn.table(UsuarioWeb.fqtn).insertGetId(item.toInsertMap());
    return item.id;
  }

  Future<UsuarioWeb> confirmaCadastro(String idUserMd5) async {
    final query = db
        .table(UsuarioWeb.fqtn)
        .selectRaw('*')
        .whereRaw("MD5(id::text) = '$idUserMd5'");
    final dados = await query.first();
    if (dados != null) {
      var user = UsuarioWeb.fromMap(dados);
      if (user.dataConfirmacao != null) {
        throw Exception('Sua confirmação de cadastro já foi realizada');
      }
      await db
          .table(UsuarioWeb.fqtn)
          .whereRaw("MD5(id::text) = '$idUserMd5'")
          .update({
        'data_confirmacao': DateTime.now().toString(),
        'confirmado': 1,
      });
      return user;
    } else {
      throw UserNotFoundException();
    }
  }

  Future<void> update(UsuarioWeb item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(UsuarioWeb.fqtn).where('id', '=', item.id);

    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(UsuarioWeb.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<UsuarioWeb> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
