import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class PermissaoRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  PermissaoRepository(this.db);

  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Permissao.tableName);

    if (filtros?.isSearch == true) {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString?.toLowerCase()}%';
            query.whereRaw(
                ''' Lower(${sField.field}) like ? ''', [filtros.searchString]);
          } else {
            query.where(sField.field, sField.operator, filtros.searchString);
          }
        }
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      //query.orderBy('nom_pais');
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    var dados = await query.get();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<Map<String, dynamic>?> getByExercicioAndCgmAndAcaoAsMap(
      int? codAcao,
      int? codFuncionalidade,
      int? codModulo,
      int? codGestao,
      String anoExercicio,
      int numcgm) async {
    final dados = await db.select('''
SELECT
	permi.* , acao.nom_acao
FROM
	administracao.permissao AS permi
	JOIN administracao.acao AS acao ON acao.cod_acao = permi.cod_acao
	JOIN administracao.funcionalidade AS fu ON fu.cod_funcionalidade = acao.cod_funcionalidade
	JOIN administracao.modulo AS modu ON modu.cod_modulo = fu.cod_modulo
	JOIN administracao.gestao AS gest ON gest.cod_gestao = modu.cod_gestao 
WHERE
	permi.numcgm = '$numcgm' 
	AND permi.cod_acao = '$codAcao' 
	AND permi.ano_exercicio = '$anoExercicio' 
	AND fu.cod_funcionalidade = '$codFuncionalidade' 
	AND modu.cod_modulo = '$codModulo' 
	AND gest.cod_gestao = '$codGestao' 
	LIMIT 1
''');
    return dados.isNotEmpty ? dados.first : null;
  }

  Future<Permissao> getByExercicioAndCgmAndAcao(
      int? codAcao,
      int? codFuncionalidade,
      int? codModulo,
      int? codGestao,
      String anoExercicio,
      int numcgm) async {
    final ret = await getByExercicioAndCgmAndAcaoAsMap(
        codAcao, codFuncionalidade, codModulo, codGestao, anoExercicio, numcgm);
    if (ret == null) {
      throw Exception('Permissão não encontrada!');
    }
    return Permissao.fromMap(ret);
  }

  /// lista todas os modulos juntamente com funcionalidades, ações e pemissões de um usuario
  Future<DataFrame<Map<String, dynamic>>> modsFuncsAcoesPermissoesOfUser(
      int numCgm, String anoExercicio,
      {Filters? filtros}) async {
    final query = db.table(Modulo.fqtn);

    query.selectRaw('''
modulo.*,
modulo.nom_modulo,
permissao.numcgm,
funcionalidade.nom_funcionalidade,
funcionalidade.cod_funcionalidade,
acao.nom_acao,
acao.cod_acao,
CASE WHEN permissao.cod_acao IS NOT NULL THEN
	TRUE 
ELSE 
  FALSE 
END AS tem_permissao 
''');

    query.join('administracao.funcionalidade', 'funcionalidade.cod_modulo', '=',
        'modulo.cod_modulo', 'inner');//'inner' 'left'

    query.join('administracao.acao', 'acao.cod_funcionalidade', '=',
        'funcionalidade.cod_funcionalidade', 'inner');

    query.join('administracao.permissao', (JoinClause jc) {
      jc.on('permissao.cod_acao', '=', 'acao.cod_acao');
      //TODO melhorar para que Eloquent trabalho com outros tipos alem de string
      jc.on('permissao.numcgm', '=', QueryExpression("'$numCgm'"));
      jc.on('permissao.ano_exercicio', '=', QueryExpression("'$anoExercicio'"));
    }, null, null, 'left');

    if (filtros?.isSearch == true) {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString?.toLowerCase()}%';
            query.whereRaw(
                ''' Lower(${sField.field}) like ? ''', [filtros.searchString]);
          } else {
            query.where(sField.field, sField.operator, filtros.searchString);
          }
        }
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query.orderBy('modulo.nom_modulo');
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    final dados = await query.get();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  /// defines as permições de um usuario
  Future<void> definirPermissao(
      int numCgm, String anoExercicio, List<int> codsAcaoPermitidos,
      {Connection? connection}) async {
    final conn = connection ?? db;

    await conn
        .table('administracao.permissao')
        .where('numcgm', '=', numCgm)
        // .where('numcgm', '<>', 0)
        .where('ano_exercicio', '=', anoExercicio)
        .delete();

    for (final codAcao in codsAcaoPermitidos) {
      await conn.table('administracao.permissao').insert({
        'numcgm': numCgm,
        'cod_acao': codAcao,
        'ano_exercicio': anoExercicio
      });
    }
  }
}
