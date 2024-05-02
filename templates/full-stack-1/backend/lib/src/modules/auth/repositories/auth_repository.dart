import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class AuthRepository {
  final Connection db;

  AuthRepository(this.db);

  Future<AuthPayload> authenticate(LoginPayload loginPayload) async {
// check if a postgres user exists?
//SELECT * FROM pg_roles WHERE rolname='sw.isaque.santana'

//SELECT rolpassword,* FROM pg_authid WHERE rolname='sw.isaque.santana';
//-- md5096a9661b2b6c6e9b78ad5cde38f25d5

//Para uma senha criptografada MD5, rolpassword a coluna começará com a string md5 seguida por um hash
//MD5 hexadecimal de 32 caracteres.
//O hash MD5 será a senha do usuário concatenada ao seu nome de usuário.
//Por exemplo, se o usuário joe tiver a senha xyzzy, o PostgreSQL armazenará o hash md5 de xyzzyjoe.

// Se a senha for criptografada com SCRAM-SHA-256, ela terá o formato:
// SCRAM-SHA-256$ <iteration count>: <salt>$ <StoredKey>:<ServerKey>
// onde salt, StoredKeye ServerKeyestão no formato codificado Base64. Este formato é o mesmo especificado pelo RFC 5803.
// Uma senha que não segue nenhum desses formatos é considerada não criptografada.

    final rolpassword = BackendUtils.geraSenhaPsql(
        loginPayload.password, loginPayload.username);
    //sw.admin > md581518985c02d2be0196536a8fe3f1354
    var query = db.table('pg_authid');
    query.selectRaw('''
us.*,
pessoa.nom_cgm,
set.nom_setor,
set.ano_exercicio AS ano_exercicio_setor,
set.id as id_setor,
pf.cpf
 ''');
    query.join('administracao.usuario as us', db.raw('us.username'), '=',
        db.raw("'${loginPayload.username}'"));
    query.join('public.sw_cgm as pessoa', 'pessoa.numcgm', '=', 'us.numcgm');
    query.join('public.sw_cgm_pessoa_fisica as pf', 'pf.numcgm', '=', 'us.numcgm','left');
    query.join('administracao.setor as set', (JoinClause jc) {
      jc.on('us.cod_setor', '=', 'set.cod_setor');
      jc.on('us.cod_orgao', '=', 'set.cod_orgao');
      jc.on('us.cod_unidade', '=', 'set.cod_unidade');
      jc.on('us.cod_departamento', '=', 'set.cod_departamento');
      jc.on('us.ano_exercicio', '=', 'set.ano_exercicio');
    });
    query.where('rolname', '=', 'sw.${loginPayload.username}');
    query.where('us.status', '=', 'A');

    var map = await query.first();

    if (map == null) {
      throw UserNotFoundException();
    }

    query.where('rolpassword', '=', rolpassword);
    map = await query.first();
    if (map == null) {
      throw UserPasswordIncorrectException();
    }

    //const expiresInDays = 365 * 3;
    /// hora que o token vai expirar
    const int expirationSec = 32400; //32400 segundo = 9 horas
    final expiry = DateTime.now().add(Duration(seconds: expirationSec));
    map['expiry'] = expiry;

    return AuthPayload.fromMap(map);
  }

  /// ALTER USER "sw.username" PASSWORD 'senha';
  Future<void> trocaSenhaQualqueUser(String novaSenha, String username) async {
    final query = await db.table('pg_authid');
    query.selectRaw('*');
    query.where('rolname', '=', 'sw.$username');

    //print('AuthRepository@trocaSenhaQualqueUser start');

    final user = await query.first();
    //print('AuthRepository@trocaSenhaQualqueUser get user');
    if (user == null) {
      throw UserNotFoundException();
    }
    //--set password_encryption = 'md5';
    //SHOW  password_encryption;
    // para evitar a encriptação do tipo SCRAN
    await db.affectingStatement(
        ''' set password_encryption = 'md5'; ''');

    // ignore: unused_local_variable
    final res = await db.affectingStatement(
        ''' ALTER USER "sw.$username" PASSWORD '$novaSenha' ''');

    //print('AuthRepository@trocaSenhaQualqueUser troca Senha');
  }

  Future<void> trocaSenha(
      String senhaAtual, String novaSenha, String username) async {
    var rolpassword = BackendUtils.geraSenhaPsql(senhaAtual, username);

    var query = await db.table('pg_authid');
    query.selectRaw('*');
    query.where('rolname', '=', 'sw.$username');
    var user = await query.first();
    if (user == null) {
      throw UserNotFoundException();
    }

    query.where('rolpassword', '=', rolpassword);

    user = await query.first();
    if (user == null) {
      throw UserPasswordIncorrectException(message: 'Senha atual incorreta!');
    }
    // ignore: unused_local_variable
    var res = await db.affectingStatement(
        ''' ALTER USER "sw.$username" PASSWORD '$novaSenha' ''');
    //print('trocaSenha $res');
  }
}
