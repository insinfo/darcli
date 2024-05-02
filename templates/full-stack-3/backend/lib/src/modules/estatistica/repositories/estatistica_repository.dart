import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class EstatisticaRepository {
  final Connection db;
  EstatisticaRepository(this.db);

  /// total de Encaminhados por mes/ano
  Future<List<Map<String, dynamic>>> totalEncaminhadosMesAno(
      {int? ano, int? mes}) async {
    //final year = DateTime.now().year - 20;
//$path/encaminhados/mes-ano/$ano
    final query = db.table(Encaminhamento.fqtn);
    query.selectRaw('*');
    query.fromRaw('''
	(
  SELECT COUNT(encaminhamentos."idCandidato") AS total,
	EXTRACT ( 'year' FROM encaminhamentos.DATA ) AS ano,
	EXTRACT ( 'month' FROM encaminhamentos.DATA ) AS mes ,
	encaminhamentos.status
FROM
	banco_empregos.encaminhamentos 
WHERE 
  EXTRACT('year' FROM encaminhamentos.DATA) = $ano AND EXTRACT('month' FROM encaminhamentos.DATA) = $mes
GROUP BY 2,3,4	
) as t  
''');

    final dados = await query.get();
    return dados;
  }

  Future<int> totalEmpregadorParaModerar() async {
    final dados = await db
        .table(EmpregadorWeb.fqtn)
        .selectRaw('''count(*) AS total''')
        .where(EmpregadorWeb.statusValidacaoFqCol, '!=',
            EmpregadorStatusValidacao.validado.value)
        .get();
    return dados.isNotEmpty ? dados[0]['total'] : 0;
  }

  /// total de candidatos web para validar/moderar
  Future<int> totalCandidatosParaModerar() async {
    final dados = await db
        .table(CandidatoWeb.fqtn)
        .selectRaw('''count(*) AS total''')
        .whereRaw('validado = false')
        .get();
    return dados.isNotEmpty ? dados[0]['total'] : 0;
  }

  Future<int> totalVagasParaModerar() async {
    final dados = await db
        .table(Vaga.fqtn)
        .selectRaw('''count(*) AS total''')
        .whereRaw('vagas.validado = false')
        .get();
    return dados.isNotEmpty ? dados[0]['total'] : 0;
  }

  Future<int> totalVagasDisponiveis() async {
    final dados = await db
        .table(Vaga.fqtn)
        .selectRaw('''count(*) AS total''')
        .whereRaw(
            'vagas.validado = true AND vagas."bloqueioEncaminhamento" = false')
        .get();
    return dados.isNotEmpty ? dados[0]['total'] : 0;
  }
}
