import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class PermissaoController {
  /// lista todas os modulos juntamente com funcionalidades, ações e pemissões de um usuario
  static Future<dynamic> modsFuncsAcoesPermissoesOfUser(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      //:numCgm/:anoExercicio
      int numCgm = int.parse(req.params['numCgm']);
      String anoExercicio = req.params['anoExercicio'];
      conn = await req.dbConnect();
      final page = await PermissaoRepository(conn)
          .modsFuncsAcoesPermissoesOfUser(numCgm, anoExercicio,
              filtros: filtros);
      await conn.disconnect();
      return res.responsePage(page);
    } catch (e, s) {
      print('PermissaoController@modsFuncsAcoesPermissoesOfUser $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    } finally {
      await conn?.disconnect();
    }
  }

  static Future<dynamic> definirPermissao(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final token = req.authToken;

      int numCgm = int.parse(req.params['numCgm']);
      String anoExercicio = req.params['anoExercicio'];

      var data = req.bodyAsMap['codsAcaoPermitidos'];

      if (!(data is List)) {
        throw Exception('codsAcaoPermitidos tem que ser uma lista');
      }

      List<int> codsAcaoPermitidos = data.map((e) => e as int).toList();
      conn = await req.dbConnect();
      final repo = PermissaoRepository(conn);
      Usuario? user;
      await conn.transaction((ctx) async {
        user = await UsuarioRepository(ctx).byNumCgm(numCgm, connection: ctx);
        await repo.definirPermissao(numCgm, anoExercicio, codsAcaoPermitidos,
            connection: ctx);
      });

      // cadastra Auditoria
      //INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('0', '26', 'isaque.santana'); ;
      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: token.codUsuario,
          codAcao: 26,
          timestamp: DateTime.now(),
          objeto: '${user?.username}',
          transacao: true,
        ),
      );
      await conn.disconnect();
      //limpa o cache do menu para aparecer as novas permições do usuario
      await DiskMapCache.clearByName(MenuController.cacheName + '_${numCgm}',
          AppConfig.inst().appCacheDir);

      return res.responseSuccess();
    } catch (e, s) {
      await conn?.disconnect();
      print('PermissaoController@definirPermissao $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
