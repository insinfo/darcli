import 'package:esic_backend/src/shared/utils/utils.dart';
import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class SolicitanteRepository {
  final DbLayer db;
  SolicitanteRepository(this.db);

  Future<DataFrame<Map<String, dynamic>>> getAllAsMap(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('lda_solicitante');

    /*final dataInicio = filtros?.getAdditionalParamByName('dataInicio');
    final dataFim = filtros?.getAdditionalParamByName('dataFim');
    if (CoreUtils.isNotNullOrEmpty(dataInicio) &&
        CoreUtils.isNotNullOrEmpty(dataFim)) {
      query.whereRaw("\"datacadastro\" BETWEEN '$dataInicio' AND '$dataFim'");
    } else if (CoreUtils.isNotNullOrEmpty(dataInicio)) {
      query.whereSafe('"datacadastro"', '=', dataInicio);
    } else if (CoreUtils.isNotNullOrEmpty(dataFim)) {
      query.whereSafe('"datacadastro"', '=', dataFim);
    }*/

    if (filtros?.isSearch == true) {
      query.whereGroup((q) {
        //q.orWhereSafe('"numeroProcesso"', 'ilike', value);
        //q.orWhereSafe('"nomeOrgao"', 'ilike', value);
        for (var sField in filtros!.searchInFields) {
          if (sField.active) {
            if (sField.operator == 'ilike' || sField.operator == 'like') {
              var substitutionField = sField.field;
              if (sField.field.contains('.')) {
                substitutionField = sField.field.split('.').last;
              }
              var substitutionValues = {
                substitutionField: '%${filtros.searchString?.toLowerCase()}%',
              };

              q.whereRaw(
                  'LOWER(${db.putInQuotes(sField.field)}::text) like ${db.formatSubititutioValue(sField.field)}',
                  andOr: 'OR',
                  substitutionValues: substitutionValues);
            } else {
              q.orWhereSafe(
                  '"${sField.field}"', sField.operator, filtros.searchString);
            }
          }
        }
        return q;
      });
    }

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

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<Map<String, dynamic>> getByIdAsMap(int id) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitante')
        .whereSafe('idsolicitante', '=', id)
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
//
      await db.getRelationFromMaps(
          dados, 'lda_faixaetaria', 'idfaixaetaria', 'idfaixaetaria',
          defaultNull: null, relationName: 'faixaEtaria', isSingle: true);

      await db.getRelationFromMaps(
          dados, 'lda_escolaridade', 'idescolaridade', 'idescolaridade',
          defaultNull: null, relationName: 'escolaridade', isSingle: true);

      await db.getRelationFromMaps(
          dados, 'lda_tipotelefone', 'idtipotelefone', 'idtipotelefone',
          defaultNull: null, relationName: 'tipoTelefone', isSingle: true);

      await db.getRelationFromMaps(dados, 'gen_estados', 'sigla', 'uf',
          defaultNull: null, relationName: 'estado', isSingle: true);

      var data = dados[0];
      return data;
    }
    throw UserNotFoundException();
  }

  Future<Solicitante> getById(int id) async {
    return Solicitante.fromMap(await getByIdAsMap(id));
  }

  Future<Map<String, dynamic>> getByCpfOrCnpjAsMap(String cpfcnpj) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitante')
        .whereSafe('cpfcnpj', '=', cpfcnpj)
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
      var data = dados[0];
      return data;
    }
    throw UserNotFoundException();
  }

  Future<bool> userExistByCpfOrCnpj(String cpfcnpj) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitante')
        .whereSafe('cpfcnpj', '=', cpfcnpj)
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getByCpfOrCnpjAndSenhaAsMap(
      String cpfcnpj, String senhaSemMD5) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitante')
        .whereSafe('cpfcnpj', '=', cpfcnpj)
        .whereSafe('chave', '=', Utils.stringToMd5(senhaSemMD5))
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
      var data = dados[0];
      return data;
    }
    throw UserNotFoundException();
  }

  Future<Solicitante> getByCpfOrCnpjAndSenha(
      String cpfcnpj, String senhaSemMD5) async {
    return Solicitante.fromMap(
        await getByCpfOrCnpjAndSenhaAsMap(cpfcnpj, senhaSemMD5));
  }

  Future<Solicitante> getByCpfOrCnpj(String cpfcnpj) async {
    return Solicitante.fromMap(await getByCpfOrCnpjAsMap(cpfcnpj));
  }

  Future<Solicitante> confirmaCadastro(String idSolicitanteMd5) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_solicitante')
        .whereRaw("MD5(idsolicitante::text) = '$idSolicitanteMd5'")
        //.whereSafe('idsolicitante', '=', idsolicitante)
        // .whereRaw('dataconfirmacao is null')
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
      var solicitante = Solicitante.fromMap(dados[0]);
      if (solicitante.dataConfirmacao != null) {
        throw Exception('Sua confirmação de cadastro já foi realizada');
      }
      await db.update()
      .whereRaw("MD5(idsolicitante::text) = '$idSolicitanteMd5'")
      .table('lda_solicitante')       
      .setAll({
        'dataconfirmacao': DateTime.now().toString(),
        'confirmado': 1,
      }).exec();
      return solicitante;
    } else {
      throw UserNotFoundException();
    }
  }

  Future<int> insert(Solicitante solicitante, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    var query = com
        .insertGetId(defaultIdColName: 'idsolicitante')
        .into('lda_solicitante')
        .setAll(solicitante.toDbInsert());
    final resp = await query.exec();
    final id = resp.first.first;
    return id;
  }

  /*Future<void> insertWithAnexos(Fac fac) async {
    if (fac != null) {
      //final fileService = AnexoFileService();

      try {
        await db.transaction((ctx) async {
          // salva Procedimento
          await insert(fac, connection: ctx);
          // salva Anexos
          if (fac?.anexos != null) {
            for (var anexo in fac.anexos) {
              anexo.fisicalFileName = await fileService.create(anexo);
              anexo.idProcedimento = idProcedimento;
              await ctx
                  .insert()
                  .into(Anexo.TABLE_NAME)
                  .setAll(anexo.toDbInsert())
                  .exec();
            }
          }
        });
      } catch (e, s) {
        print('insertWithAnexos\r\n$e\r\n$s');
        if (fac?.anexos != null) {
          for (var anexo in fac.anexos) {
            await fileService.deleteIfExist(anexo.fisicalFileName);
          }
        }
        rethrow;
      }
    }
  }*/

  /*Future<void> updateWithAnexos(Fac fac) async {
    if (fac != null) {
      //final fileService = AnexoFileService();
      print('updateWithAnexos');
      try {
        await db.transaction((ctx) async {
          // update Procedimento
          await update(fac, connection: ctx);

          // salva Anexos
         if (fac?.anexos != null) {
            for (var anexo in fac.anexos) {
              if (anexo.isNew == true) {
                print('anexo.isNew == true');
                anexo.fisicalFileName = await fileService.create(anexo);
                anexo.idProcedimento = procedimento.id;
                await ctx
                    .insert()
                    .into(Anexo.TABLE_NAME)
                    .setAll(anexo.toDbInsert())
                    .exec();
              } else if (anexo.isNew == false && anexo.isRemove == true) {
                print('anexo.isNew == false');
                print('anexo.fisicalFileName ${anexo.fisicalFileName}');
                await fileService.deleteIfExist(anexo.fisicalFileName);
                await ctx
                    .delete()
                    .from(Anexo.TABLE_NAME)
                    .where('id=?', anexo.id)
                    .exec();
              }
            }
          }
        });
      } catch (e, s) {
       
        rethrow;
      }
    }
  }*/

  Future<void> update(Solicitante solicitante, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    //atualiza fac
    await com
        .update()
        .table('lda_solicitante')
        .setAll(solicitante.toDbUpdate())
        .whereSafe('idsolicitante', '=', solicitante.id)
        .exec();
  }

  Future<void> updateSenha(String novaSenha, int idSolicitante,
      {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    //atualiza
    await com
        .update()
        .table('lda_solicitante')
        .setAll({'chave': Utils.stringToMd5(novaSenha)})
        .whereSafe('idsolicitante', '=', idSolicitante)
        .exec();
  }

  Future<void> delete(Solicitante solicitante) async {
    await deleteById(solicitante.id);
  }

  Future<void> deleteById(int id) async {
    await db
        .delete()
        .from('lda_solicitante')
        .where('idsolicitante=?', id)
        .exec();
  }

  Future<void> deleteAllByIds(List<int> ids) async {
    for (var id in ids) {
      await deleteById(id);
    }
  }

  Future<void> deleteAll(List<Solicitante> solicitantes) async {
    for (var fac in solicitantes) {
      await delete(fac);
    }
  }
}
