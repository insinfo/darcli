import 'package:new_sali_core/new_sali_core.dart';

class AssuntoAcao implements BaseModel {
  static const String schemaName = 'protocolo';
  static const String tableName = 'assunto_acao';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// primary key int4
  int codAssunto;

  /// primary key int4
  int codClassificacao;

  /// primary key int4
  int codAcao;

  AssuntoAcao({
    required this.codAssunto,
    required this.codClassificacao,
    required this.codAcao,
  });

  AssuntoAcao copyWith({
    int? cod_assunto,
    int? cod_classificacao,
    int? cod_acao,
  }) {
    return AssuntoAcao(
      codAssunto: cod_assunto ?? this.codAssunto,
      codClassificacao: cod_classificacao ?? this.codClassificacao,
      codAcao: cod_acao ?? this.codAcao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_assunto	': codAssunto,
      'cod_classificacao	': codClassificacao,
      'cod_acao	': codAcao,
    };
  }

  factory AssuntoAcao.fromMap(Map<String, dynamic> map) {
    return AssuntoAcao(
      codAssunto: map['cod_assunto	'] as int,
      codClassificacao: map['cod_classificacao	'] as int,
      codAcao: map['cod_acao	'] as int,
    );
  }

  @override
  String toString() =>
      'AssuntoAcao(cod_assunto	: $codAssunto	, cod_classificacao	: $codClassificacao	, cod_acao	: $codAcao	)';

  @override
  bool operator ==(covariant AssuntoAcao other) {
    if (identical(this, other)) return true;

    return other.codAssunto == codAssunto &&
        other.codClassificacao == codClassificacao &&
        other.codAcao == codAcao;
  }

  @override
  int get hashCode =>
      codAssunto.hashCode ^ codClassificacao.hashCode ^ codAcao.hashCode;
}
