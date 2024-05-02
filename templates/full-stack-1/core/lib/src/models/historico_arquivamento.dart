import 'package:new_sali_core/new_sali_core.dart';

/// Tipos de arquivamento
/// 1	1 - Arquivado
/// 2	Pagamento quitado
/// 3	Férias
/// 4	Aguardando certidão habite-se
/// 5	Temporário
/// 6	Aguardando Nota Fiscal
/// 7	Temporário - Cadastramento de Empresa
/// 8	Arquivo Temporário Judicial
/// 9	ARQUIVADO - Aguardando Vista
class HistoricoArquivamento implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_historico_arquivamento';

  /// nome da tabela totalmente qualificado public.sw_historico_arquivamento
  static const String fqtn = '$schemaName.$tableName';

  int codHistorico;

  /// nome do tipo de arquivamento
  String nomHistorico;

  HistoricoArquivamento({
    required this.codHistorico,
    required this.nomHistorico,
  });

  factory HistoricoArquivamento.invalido() {
    return HistoricoArquivamento(
      codHistorico: -1,
      nomHistorico: '',
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_historico': codHistorico,
      'nom_historico': nomHistorico,
    };
    return map;
  }

  /// Map para ser usando ao salvar no bamco de dados
  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  /// Map para ser usando ao salvar no bamco de dados
  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('cod_historico');
  }

  factory HistoricoArquivamento.fromMap(Map<String, dynamic> map) {
    final hi = HistoricoArquivamento(
      codHistorico: map['cod_historico'] as int,
      nomHistorico: map['nom_historico'] as String,
    );
    return hi;
  }
}
