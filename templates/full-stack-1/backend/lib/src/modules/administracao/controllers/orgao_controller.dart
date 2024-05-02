import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class OrgaoController {
  static String cacheName = 'orgaos';

  /// lista todos os Orgãos
  static Future<dynamic> all(RequestContext req, ResponseContext res) async {
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
        final page = await OrgaoRepository(conn).all(filtros: filtros);
        await conn.disconnect();
        cache.putItem(page.toMap());
        return res.responseJson(page.toMap());
      }

      final items = await cache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('OrgaoController@all $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> insert(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      // abre a conexão
      conn = await req.dbConnect();

      final repo = OrgaoRepository(conn);
      final item = Orgao.fromMap(req.bodyAsMap);
      item.usuarioResponsavel = req.authToken.numCgm;
      item.anoExercicio = DateTime.now().year.toString();

      await conn.transaction((ctx) async {
        // cadastra
        await repo.insert(item, connection: ctx);
      });

      // cadastra auditoria
      //  INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '3', 'teste orgao');
      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: req.authToken.codUsuario,
          codAcao: 3,
          timestamp: DateTime.now(),
          objeto: item.nomOrgao,
          transacao: true,
        ),
      );
      // fecha a conexão
      await conn.disconnect();
      //limpa o cache
      await DiskMapCache.clearByName(cacheName, AppConfig.inst().appCacheDir);

      return res.responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('OrgaoController@insert $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> update(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final token = req.authToken;
      conn = await req.dbConnect();
      final repo = OrgaoRepository(conn);
      final item = Orgao.fromMap(req.bodyAsMap);
      await conn.transaction((ctx) async {
        // atualiza
        await repo.update(item, connection: ctx);
      });
      // cadastra auditoria
      //INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '5', '01/2023 - teste orgao auterado'); ;
      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: token.codUsuario,
          codAcao: 5,
          timestamp: DateTime.now(),
          objeto: '${item.codOrgao}/${item.anoExercicio} - ${item.nomOrgao}',
          transacao: true,
        ),
      );
      await conn.disconnect();

      //limpa o cache
      await DiskMapCache.clearByName(cacheName, AppConfig.inst().appCacheDir);

      return res.responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('OrgaoController@update $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> deleteAll(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final token = req.authToken;

      final items = req.bodyAsList!
          .map((e) => Orgao.fromMap(e as Map<String, dynamic>))
          .toList();

      conn = await req.dbConnect();

      final repo = OrgaoRepository(conn);

      for (var item in items) {
        await conn.transaction((ctx) async {
          await repo.delete(
            item,
            connection: ctx,
          );
        });

        // cadastra Auditoria
        // INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '4', '01/2023 - teste orgao auterado'); ;
        await AuditoriaRepository(conn).insert(
          Auditoria(
            numCgm: token.numCgm,
            codAcao: 4,
            timestamp: DateTime.now(),
            objeto: '${item.codOrgao}/${item.anoExercicio} - ${item.nomOrgao}',
            transacao: true,
          ),
        );
      }
      await conn.disconnect();

      //limpa o cache
      await DiskMapCache.clearByName(cacheName, AppConfig.inst().appCacheDir);

      return res.responseSuccess();
    } catch (e, s) {
      await conn?.disconnect();
      print('OrgaoController@deleteAll $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
