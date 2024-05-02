import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class UnidadeController {
  static String cacheName = 'unidades';

  /// lista todas as unidades
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
        final page = await UnidadeRepository(conn).all(filtros: filtros);
        await conn.disconnect();
        final map = page.toMap();
        cache.putItem(map);
        return res.responseJson(map);
      }

      final items = await cache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('UnidadeController@all $e $s');
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

      final repo = UnidadeRepository(conn);
      final item = Unidade.fromMap(req.bodyAsMap);
      item.usuarioResponsavel = req.authToken.numCgm;

      await conn.transaction((ctx) async {
        // cadastra
        await repo.insert(item, connection: ctx);
      });

      // cadastra auditoria
      // INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '6', 'aa unidade teste'); ;
      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: req.authToken.codUsuario,
          codAcao: 6,
          timestamp: DateTime.now(),
          objeto: item.nomUnidade,
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
      print('UnidadeController@insert $e $s');
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
      final repo = UnidadeRepository(conn);
      final item = Unidade.fromMap(req.bodyAsMap);
      await conn.transaction((ctx) async {
        // atualiza
        await repo.update(item, connection: ctx);
      });
      // cadastra auditoria
      // INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '8', '');
      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: token.codUsuario,
          codAcao: 8,
          timestamp: DateTime.now(),
          objeto:
              '${item.codOrgao}.${item.codUnidade}/${item.anoExercicio} - ${item.nomUnidade}',
          transacao: true,
        ),
      );
      await conn.disconnect();

      //limpa o cache
      await DiskMapCache.clearByName(cacheName, AppConfig.inst().appCacheDir);

      return res.responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('UnidadeController@update $e $s');
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
          .map((e) => Unidade.fromMap(e as Map<String, dynamic>))
          .toList();

      conn = await req.dbConnect();

      final repo = UnidadeRepository(conn);

      for (var item in items) {
        await conn.transaction((ctx) async {
          await repo.delete(item, connection: ctx);
        });

        // cadastra Auditoria
        // INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '7', '01.001/2023 - aa unidade teste 2'); ;
        await AuditoriaRepository(conn).insert(
          Auditoria(
            numCgm: token.numCgm,
            codAcao: 7,
            timestamp: DateTime.now(),
            objeto:
                '${item.codOrgao}.${item.codUnidade}/${item.anoExercicio} - ${item.nomOrgao}',
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
      print('UnidadeController@deleteAll $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
