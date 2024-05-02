import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

/// log
class AuditoriaRepository {
  final Connection db;

  AuditoriaRepository(this.db);

  /// lista os registros de auditoria
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Auditoria.fqtn);

    query.selectRaw('''
auditoria.*,
usuario.username,
acao.nom_acao,
funcionalidade.nom_funcionalidade,
modulo.nom_modulo
 ''');

    if (filtros?.isSearch == true) {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString?.toLowerCase()}%';

           
            query.whereRaw(
                ''' LOWER(TO_ASCII(${sField.field},'LATIN_1')) like LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
                [filtros.searchString]);
          } else {
            query.where(sField.field, sField.operator, filtros.searchString);
          }
        }
      }
    }

    query.join(
        'administracao.usuario', 'usuario.numcgm', '=', 'auditoria.numcgm');
    query.join(
        'administracao.acao', 'acao.cod_acao', '=', 'auditoria.cod_acao');

    query.join('administracao.funcionalidade',
        'funcionalidade.cod_funcionalidade', '=', 'acao.cod_funcionalidade');

    query.join('administracao.modulo', 'modulo.cod_modulo', '=',
        'funcionalidade.cod_modulo');

    if (filtros?.codCgm != null) {
      query.where('auditoria.numcgm', '=', filtros?.codCgm);
    }

    if (filtros?.codModulo != null) {
      query.where('modulo.cod_modulo', '=', filtros?.codModulo);
    }

    if (filtros?.inicio != null && filtros?.fim != null) {
      //AND substr(sw_processo.timestamp,1,10) >= '2017-03-15' AND substr(sw_processo.timestamp,1,10) <= '2017-03-15'
      query.whereRaw(
          ''' substr(auditoria.timestamp::text,1,10) >= '${filtros?.inicio?.asDateOnlyString}' AND substr(auditoria.timestamp::text,1,10) <= '${filtros?.fim?.asDateOnlyString}' ''');
    } else if (filtros?.inicio != null && filtros?.fim == null) {
      query.whereRaw(
          ''' auditoria.timestamp >= '${filtros?.inicio?.asDateOnlyString}' ''');
    } else if (filtros?.inicio == null && filtros?.fim != null) {
      query.whereRaw(
          ''' auditoria.timestamp <= '${filtros?.fim?.asDateOnlyString}' ''');
    }

    final totalRecords = await query.count('auditoria.numcgm');

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      //query.orderBy('nom_departamento');
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

  /// query muito lenta
  /// retorna uma lista de codAcao
  Future<DataFrame<Map<String, dynamic>>> ultimasAcoes() async {
    // pega os codigos das açoes
    final dados = await db.select('''SELECT 
A.cod_acao 
FROM
	administracao.auditoria
	A JOIN (
	SELECT
		administracao.auditoria.cod_acao,
		MAX ( administracao.auditoria.TIMESTAMP ) AS TIMESTAMP 
	FROM
		administracao.auditoria 
	GROUP BY
		administracao.auditoria.cod_acao 
	) ac ON A.cod_acao = ac.cod_acao 
	AND A.TIMESTAMP = ac.TIMESTAMP 
ORDER BY
	A.TIMESTAMP DESC 
	LIMIT 5''');
// pega os nomes das açoes
//   SELECT A
// 	.cod_acao,
// 	A.nom_acao,
// 	A.nom_arquivo,
// 	A.parametro,
// 	A.ordem,
// 	F.cod_funcionalidade,
// 	F.nom_funcionalidade,
// 	F.nom_diretorio AS dir_funcionalidade,
// 	F.ordem,
// 	M.cod_modulo,
// 	M.cod_responsavel,
// 	M.nom_modulo,
// 	M.nom_diretorio AS dir_modulo,
// 	M.ordem
// FROM
// 	administracao.acao A,
// 	administracao.funcionalidade F,
// 	administracao.modulo M
// WHERE
// 	A.cod_funcionalidade = F.cod_funcionalidade
// 	AND F.cod_modulo = M.cod_modulo
// 	AND A.cod_acao IN ( 37, 26, 67, 57, 59 )

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: 0,
    );
  }

  /// cria uma nova linha na tabela de auditoria
  Future<void> insert(Auditoria auditoria, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    final query = conn.table(Auditoria.fqtn);
    //auditoria.timestamp = DateTime.now();
    await query.insert(auditoria.toInsertMap());
  }
}
