import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';

import 'package:new_sali_core/new_sali_core.dart';

class EstatisticaController {
  /// total de processos por periodo e setor destino do primero tramite
  static Future<dynamic> processByPeriodoSetorPrimeroTramite(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      if (req.uri == null) {
        throw ArgumentError('Request URI is null');
      }

      final filtros = Filters.fromMap(req.queryParameters);

      final processByPeriodoCache = DiskListMapCache(
          req.uri.toString(), AppConfig.inst().appCacheDir,
          cacheName: 'process_periodo_setor',
          cacheValidDuration: const Duration(days: 5));

      bool shouldRefreshFromApi =
          ((await processByPeriodoCache.isShouldRefresh()) ||
              filtros.forceRefresh == true);

      if (shouldRefreshFromApi) {
        conn = await req.dbConnect();
        final items = await EstatisticaRepository(conn)
            .processByPeriodoSetorPrimeroTramite(filtros: filtros);
        await conn.disconnect();
        processByPeriodoCache.putItem(items);
        return res.responseJson(items);
      }

      final items = await processByPeriodoCache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('EstatisticaController@processByPeriodoSetorPrimeroTramite $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  /// lista o total de Processos por ano desde 20 anos atras a partir do ano atual
  static Future<dynamic> totalProcessosPorAno(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      if (req.uri == null) {
        throw ArgumentError('Request URI is null');
      }

      final filtros = Filters.fromMap(req.queryParameters);

      final _processosAnoCache = DiskListMapCache(
          req.uri.toString(), AppConfig.inst().appCacheDir,
          cacheName: 'processos_ano',
          cacheValidDuration: const Duration(days: 5));

      bool shouldRefreshFromApi =
          ((await _processosAnoCache.isShouldRefresh()) ||
              filtros.forceRefresh == true);

      if (shouldRefreshFromApi) {
        conn = await req.dbConnect();
        final items = await EstatisticaRepository(conn)
            .totalProcessosPorAno(filtros: filtros);
        await conn.disconnect();
        _processosAnoCache.putItem(items);
        return res.responseJson(items);
      }

      final items = await _processosAnoCache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('EstatisticaController@totalProcessosPorAno $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> processosPorSituacao(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      if (req.uri == null) {
        throw ArgumentError('Request URI is null');
      }

      final filtros = Filters.fromMap(req.queryParameters);

      final _processosSituacaoCache = DiskListMapCache(
          req.uri.toString(), AppConfig.inst().appCacheDir,
          cacheName: 'processos_situacao',
          cacheValidDuration: const Duration(days: 5));

      bool shouldRefreshFromApi =
          ((await _processosSituacaoCache.isShouldRefresh()) ||
              filtros.forceRefresh == true);

      if (shouldRefreshFromApi) {
        conn = await req.dbConnect();
        final items = await EstatisticaRepository(conn)
            .processosPorSituacao(filtros: filtros);
        await conn.disconnect();
        _processosSituacaoCache.putItem(items);

        return res.responseJson(items);
      }

      final items = await _processosSituacaoCache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('EstatisticaController@processosPorSituacao $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> totalProcessosPorClassificacao(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      if (req.uri == null) {
        throw ArgumentError('Request URI is null');
      }

      final filtros = Filters.fromMap(req.queryParameters);

      final _procClassificacaoCache = DiskListMapCache(
          req.uri.toString(), AppConfig.inst().appCacheDir,
          cacheName: 'processos_classificacao',
          cacheValidDuration: const Duration(days: 5));

      bool shouldRefreshFromApi =
          ((await _procClassificacaoCache.isShouldRefresh()) ||
              filtros.forceRefresh == true);

      if (shouldRefreshFromApi) {
        conn = await req.dbConnect();
        final items = await EstatisticaRepository(conn)
            .totalProcessosPorClassificacao(filtros: filtros);
        await conn.disconnect();
        _procClassificacaoCache.putItem(items);

        return res.responseJson(items);
      }

      final items = await _procClassificacaoCache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('EstatisticaController@totalProcessosPorClassificacao $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> totalProcessosPorAssunto(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      if (req.uri == null) {
        throw ArgumentError('Request URI is null');
      }

      final filtros = Filters.fromMap(req.queryParameters);

      var _procClassificacaoCache = DiskListMapCache(
          req.uri.toString(), AppConfig.inst().appCacheDir,
          cacheName: 'processos_assunto',
          cacheValidDuration: const Duration(days: 5));

      bool shouldRefreshFromApi =
          ((await _procClassificacaoCache.isShouldRefresh()) ||
              filtros.forceRefresh == true);

      if (shouldRefreshFromApi) {
        conn = await req.dbConnect();
        final items = await EstatisticaRepository(conn)
            .totalProcessosPorAssunto(filtros: filtros);
        await conn.disconnect();
        _procClassificacaoCache.putItem(items);

        return res.responseJson(items);
      }

      final items = await _procClassificacaoCache.getItem();
      return res.responseJson(items);
    } catch (e, s) {
      await conn?.disconnect();
      print('EstatisticaController@totalProcessosPorAssunto $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
