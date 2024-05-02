import 'package:esic_backend/src/modules/anexo/repositories/anexo_repository.dart';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_backend/src/shared/services/anexo_file_service.dart';
import 'package:esic_backend/src/shared/utils/utils.dart';
import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class SolicitacaoRepository {
  final DbLayer db;
  SolicitacaoRepository(this.db);

  Future<DataFrame<Map<String, dynamic>>> getAllAsMap(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('''
    lda_solicitacao.*,
    lda_solicitante.nome AS solicitantenome,
    coalesce(secOrigem.sigla, 'Solicitante') AS secretariaorigemnome,
  CASE
	  WHEN secDestino.sigla IS NULL THEN
		  COALESCE ( secSelecionada.sigla, 'SIC Central' ) 
    ELSE 'SIC Central' 
	END AS secretariadestinonome,
	lda_movimentacao.idsecretariadestino,
	lda_movimentacao.datarecebimento,
	lda_movimentacao.idmovimentacao,
	datediff('days',  CURRENT_DATE, lda_solicitacao.dataprevisaoresposta) AS prazorestante
    ''').from('lda_solicitacao');
    // solicitante
    query.join('lda_solicitante',
        'lda_solicitante.idsolicitante = lda_solicitacao.idsolicitante',
        type: JoinType.INNER);
    // movimentacao
    query.join('lda_movimentacao',
        '''lda_movimentacao.idmovimentacao = (SELECT MAX(M.idmovimentacao) FROM lda_movimentacao M WHERE M.idsolicitacao = lda_solicitacao.idsolicitacao)''',
        type: JoinType.LEFT);
    // secretaria Origem
    query.join('sis_secretaria',
        'secOrigem.idsecretaria = lda_movimentacao.idsecretariaorigem',
        alias: 'secOrigem', type: JoinType.LEFT);
    // secretaria Destino
    query.join('sis_secretaria',
        'secDestino.idsecretaria = lda_movimentacao.idsecretariadestino',
        alias: 'secDestino', type: JoinType.LEFT);
    // secretaria Selecionada
    query.join('sis_secretaria',
        'secSelecionada.idsecretaria = lda_solicitacao.idsecretariaselecionada',
        alias: 'secSelecionada', type: JoinType.LEFT);
    var situcao = filtros?.getAdditionalParamByName('situacao');
    if (situcao != null) {
      if (situcao.contains('+')) {
        var stuacoes = situcao.split('+');
        query.whereRaw(
            "situacao  IN ( ${stuacoes.map((s) => "'$s'").join(',')} )");
      } else if (situcao.contains('Todos')) {
        //
      } else {
        query.whereRaw("situacao = '$situcao'");
      }
    } else {
      query.whereRaw("situacao IN ( 'A','T' )");
    }

    if (filtros?.isSearch == true) {
      query.whereGroup((q) {
        for (var sField in filtros!.searchInFields) {
          if (sField.active) {
            if (sField.field != 'protocoloAno') {
              if (sField.operator == 'ilike' || sField.operator == 'like') {
                var substitutionField = sField.field;
                if (sField.field.contains('.')) {
                  substitutionField = sField.field.split('.').last;
                }
                final substitutionValues = {
                  substitutionField:
                      '%${Utils.unaccent(filtros.searchString?.toLowerCase())}%',
                };

                q.whereRaw(
                    "LOWER(unaccent(${db.putInQuotes(sField.field)}::text)) like ${db.formatSubititutioValue(sField.field)}",
                    andOr: 'OR',
                    substitutionValues: substitutionValues);
              } else {
                q.orWhereSafe(
                    '"${sField.field}"', sField.operator, filtros.searchString);
              }
            } else {
              q.whereRaw(
                  "numprotocolo::text || '/' || anoprotocolo::text ${sField.operator} @numprotocolo",
                  substitutionValues: {
                    'numprotocolo': filtros.searchString,
                  });
            }
          }
        }

        return q;
      });
    }
    //print(query.toSql());
    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      var orderBy = filtros!.orderBy!;

      query.order(orderBy,
          dir: filtros.orderDir == 'asc' ? SortOrder.ASC : SortOrder.DESC);
    } else {
      // query.order('datacadastro', dir: SortOrder.DESC);
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    //print(query.toSql());
    var dados = await query.getAsMap();

    await db.getRelationFromMaps(
        dados, 'lda_tiposolicitacao', 'idtiposolicitacao', 'idtiposolicitacao',
        relationName: 'tipoSolicitacao', isSingle: true);

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllOfPessoa(int idPessoa,
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('''
    lda_solicitacao.*  
    ''').from('lda_solicitacao');

    query.whereSafe('idsolicitante', '=', idPessoa);

    var situcao = filtros?.getAdditionalParamByName('situacao');
    if (situcao != null) {
      if (situcao.contains('+')) {
        var stuacoes = situcao.split('+');
        query.whereRaw(
            "situacao  IN ( ${stuacoes.map((s) => "'$s'").join(',')} )");
      } else if (situcao.contains('Todos')) {
        //
      } else {
        query.whereRaw("situacao = '$situcao'");
      }
    } else {
      query.whereRaw("situacao IN ( 'A','T' )");
    }

    if (filtros?.isSearch == true) {
      query.whereGroup((q) {
        for (var sField in filtros!.searchInFields) {
          if (sField.active) {
            if (sField.field != 'protocoloAno') {
              if (sField.operator == 'ilike' || sField.operator == 'like') {
                var substitutionField = sField.field;
                if (sField.field.contains('.')) {
                  substitutionField = sField.field.split('.').last;
                }
                final substitutionValues = {
                  substitutionField:
                      '%${Utils.unaccent(filtros.searchString?.toLowerCase())}%',
                };

                q.whereRaw(
                    'LOWER(${db.putInQuotes(sField.field)}::text) like ${db.formatSubititutioValue(sField.field)}',
                    andOr: 'OR',
                    substitutionValues: substitutionValues);
              } else {
                q.orWhereSafe(
                    '"${sField.field}"', sField.operator, filtros.searchString);
              }
            } else {
              q.whereRaw(
                  "numprotocolo::text || '/' || anoprotocolo::text ${sField.operator} @numprotocolo",
                  substitutionValues: {
                    'numprotocolo': filtros.searchString,
                  });
            }
          }
        }
        return q;
      });
    }
    //print(query.toSql());
    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.order(filtros!.orderBy!,
          dir: filtros.orderDir == 'asc' ? SortOrder.ASC : SortOrder.DESC);
    } else {
      // query.order('datacadastro', dir: SortOrder.DESC);
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    //print(query.toSql());
    var dados = await query.getAsMap();

    await db.getRelationFromMaps(
        dados, 'lda_tiposolicitacao', 'idtiposolicitacao', 'idtiposolicitacao',
        relationName: 'tipoSolicitacao', isSingle: true);

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<Map<String, dynamic>> getById(int id) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitacao')
        .whereSafe('idsolicitacao', '=', id)
        .limit(1);

    var dados = await query.getAsMap();

    await db.getRelationFromMaps(
        dados, 'lda_tiposolicitacao', 'idtiposolicitacao', 'idtiposolicitacao',
        relationName: 'tipoSolicitacao', isSingle: true);

    //usuario que respondeu
    await db.getRelationFromMaps(
        dados, 'sis_usuario', 'idusuario', 'idusuarioresposta',
        relationName: 'usuarioResposta', isSingle: true);

    //anexos
    await db.getRelationFromMaps(
        dados, 'lda_anexo', 'idsolicitacao', 'idsolicitacao',
        relationName: 'anexos', isSingle: false, defaultNull: null);

    if (dados.isNotEmpty == true) {
      var data = dados[0];
      if (data['anexos'] != null) {
        var anexos = data['anexos'] as List;
        for (var anex in anexos) {
          anex['link'] =
              AppConfig.inst().storageDns + "/${anex['fisicalfilename']}";
        }
      }

      return data;
    }
    throw Exception('Not found');
  }

  Future<Map<String, dynamic>> getByIdOfPessoa(int idPessoa, int id) async {
    var query = db.select().fieldRaw('''
            t.*, c.nome as solicitantenome,
            urec.nome as usuariorecebimentonome,
            upro.nome as usuarioprorrogacaonome, 
            ures.nome as usuariorespostanome
        ''');
    query.fromRaw('lda_solicitacao as t');
    //solicitante
    query.join('lda_solicitante', 'c.idsolicitante = t.idsolicitante',
        alias: 'c', type: JoinType.LEFT);
    //usuario recebimento
    query.join('sis_usuario', 'urec.idusuario = t.idusuariorecebimento',
        alias: 'urec', type: JoinType.LEFT);
    //usuario prorrogacao
    query.join('sis_usuario', 'upro.idusuario = t.idusuarioprorrogacao',
        alias: 'upro', type: JoinType.LEFT);
    //usuario resposta
    query.join('sis_usuario', 'ures.idusuario = t.idusuarioresposta',
        alias: 'ures', type: JoinType.LEFT);

    query.whereSafe('t.idsolicitacao', '=', id);
    query.whereSafe('t.idsolicitante', '=', idPessoa);
    query.limit(1);

    // print(query.toSql());
    var dados = await query.getAsMap();

    await db.getRelationFromMaps(
        dados, 'lda_tiposolicitacao', 'idtiposolicitacao', 'idtiposolicitacao',
        relationName: 'tipoSolicitacao', isSingle: true);

    //anexos
    await db.getRelationFromMaps(
        dados, 'lda_anexo', 'idsolicitacao', 'idsolicitacao',
        relationName: 'anexos', isSingle: false);

    if (dados.isNotEmpty == true) {
      var data = dados[0];
      if (data['anexos'] != null) {
        var anexos = data['anexos'] as List;
        for (var anex in anexos) {
          anex['link'] =
              AppConfig.inst().storageDns + "/${anex['fisicalfilename']}";
        }
      }
      return data;
    }
    throw Exception('Not found');
  }

  /// recupera o proximo tipo de solicitação para uma solicitação informada
  Future<int> getProximoTipoSolicitacao(int? idsolicitacao) async {
    //se for passado uma solicitação
    if (idsolicitacao != null) {
      var dados = await db
          .select()
          .fieldRaw('idtiposolicitacao_seguinte')
          .from('lda_tiposolicitacao')
          .whereRaw(
              'idtiposolicitacao = (select idtiposolicitacao from lda_solicitacao where idsolicitacao = $idsolicitacao)')
          .getAsMap();
      if (dados.length > 0) {
        var idTipoSolicitacao = dados[0]['idtiposolicitacao_seguinte'];
        if (idTipoSolicitacao == null) {
          throw Exception(
              'Não é possível inserir novo recurso para essa solicitação, pois essa solicitação já está na última instância!');
        } else {
          return -1;
        }
      } else {
        throw Exception(
            'Não foi encontrado tipo de solicitação para essa solicitação!');
      }
    } else {
      //recupera a solicitação inicial
      var dados = await db
          .select()
          .fieldRaw('idtiposolicitacao')
          .from('lda_tiposolicitacao')
          .whereRaw("instancia = 'I'")
          .getAsMap();

      if (dados.length > 0) {
        return dados[0]['idtiposolicitacao'] as int;
      } else {
        throw Exception(
            'Não foi encontrado instância inicial cadastrada no sistema!');
      }
    }
  }

  Future<int> insert(Solicitacao item, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    final map = item.toDbInsert();
    var query = com
        .insertGetId(defaultIdColName: 'idsolicitacao')
        .into('lda_solicitacao')
        .setAll(map);
    final resp = await query.exec();
    final id = resp.first.first;
    return id;
  }

  Future<void> receber(Solicitacao item, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    //atualiza fac
    await com
        .update()
        .table('lda_solicitacao')
        .setAll({
          'datarecebimentosolicitacao': item.dataRecebimentoSolicitacao,
          'idusuariorecebimento': item.idUsuarioRecebimento,
        })
        .whereSafe('idsolicitacao', '=', item.id)
        .exec();
  }

  Future<void> update(Solicitacao item, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    //atualiza fac
    await com
        .update()
        .table('lda_solicitacao')
        .setAll(item.toDbUpdate())
        .whereSafe('idsolicitacao', '=', item.id)
        .exec();
  }

  /// obtem do tipo de solicitacação a instancia atual de uma solicitação
  Future<String> getInstancia(int idsolicitacao, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    var instancia = await com.raw("""
          select t.instancia from lda_solicitacao s, lda_tiposolicitacao t
          where s.idtiposolicitacao = t.idtiposolicitacao
          and s.idsolicitacao = '$idsolicitacao' 
                               """).firstAsMap();

    return instancia!['instancia'];
  }

  Future<void> prorrogar(Solicitacao solicitacao, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    //var data = solicitacao.toDbUpdate();
    await com
        .update()
        .table('lda_solicitacao')
        .setAll({
          'idusuarioprorrogacao': solicitacao.idUsuarioProrrogacao,
          'dataprorrogacao': solicitacao.dataProrrogacao,
          'motivoprorrogacao': solicitacao.motivoProrrogacao,
          'dataprevisaoresposta': solicitacao.dataPrevisaoResposta,
        })
        .whereSafe('idsolicitacao', '=', solicitacao.id)
        .exec();
  }

  Future<void> responder(Solicitacao solicitacao,
      {DbLayer? connection, bool withTransaction = true}) async {
    var com = connection != null ? connection : db;
    final fileService = AnexoFileService();
    if (withTransaction) {
      await com.transaction((ctx) async {
        // salva solicitacao
        await ctx
            .update()
            .table('lda_solicitacao')
            .setAll({
              'situacao': solicitacao.situacao,
              'idusuarioresposta': solicitacao.idUsuarioResposta,
              'dataresposta': solicitacao.dataResposta,
              'resposta': solicitacao.resposta,
              'idsecretariaresposta': solicitacao.idSecretariaResposta,
            })
            .whereSafe('idsolicitacao', '=', solicitacao.id)
            .exec();

        // salva Anexos
        if (solicitacao.anexos.isNotEmpty == true) {
          final anexoRepository = AnexoRepository(ctx);
          for (var anexo in solicitacao.anexos) {
            if (anexo.bytes.isNotEmpty) {
              anexo.fisicalFileName = await fileService.create(anexo);
              await anexoRepository.insert(anexo);
            }
          }
        }
      });
    }
  }

  Future<void> delete(Solicitacao item) async {
    await deleteById(item.id);
  }

  Future<void> deleteById(int id) async {
    await db
        .delete()
        .from('lda_solicitacao')
        .where('idsolicitacao=?', id)
        .exec();
  }

  Future<void> deleteAllByIds(List<int> ids) async {
    for (var id in ids) {
      await deleteById(id);
    }
  }

  Future<void> deleteAll(List<Solicitacao> items) async {
    for (var item in items) {
      await delete(item);
    }
  }
}
