// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

/// 1	No Protocolo
/// 2	Em andamento, a receber
/// 3	Em andamento, recebido
/// 4	Anexado
/// 5	Arquivado temporario
/// 9	Arquivado definitivo
/// 10	Em pagamento
/// 11	Arquivado ferias
class SituacaoProcesso implements BaseModel {
  
  static const String schemaName = 'public';
  static const String tableName = 'sw_situacao_processo';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codSituacao;
  String nomSituacao;

  SituacaoProcesso({
    required this.codSituacao,
    required this.nomSituacao,
  });

  SituacaoProcesso copyWith({
    int? codSituacao,
    String? nomSituacao,
  }) {
    return SituacaoProcesso(
      codSituacao: codSituacao ?? this.codSituacao,
      nomSituacao: nomSituacao ?? this.nomSituacao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_situacao': codSituacao,
      'nom_situacao': nomSituacao,
    };
  }

  factory SituacaoProcesso.fromMap(Map<String, dynamic> map) {
    return SituacaoProcesso(
      codSituacao: map['cod_situacao'] as int,
      nomSituacao: map['nom_situacao'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SituacaoProcesso.fromJson(String source) =>
      SituacaoProcesso.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SituacaoProcesso(cod_situacao: $codSituacao, nom_situacao: $nomSituacao)';

  @override
  bool operator ==(covariant SituacaoProcesso other) {
    if (identical(this, other)) return true;

    return other.codSituacao == codSituacao;
  }

  @override
  int get hashCode => codSituacao.hashCode;
}
