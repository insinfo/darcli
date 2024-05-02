// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

class Orgao implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'orgao';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codOrgao;

  /// tanto setor/departamento/unidade usa este ano do orgão
  String anoExercicio;

  /// 0
  int usuarioResponsavel;
  String nomOrgao;

  /// 0 | 1
  String situacao;

  String get situacaoFormatada {
    if (situacao == '0') {
      return 'Inativo';
    } else if (situacao == '1') {
      return 'Ativo';
    }
    return 'Desconhecido';
  }

  /// propriedade anexada somente para UI
  bool selected = false;
  bool disabled = false;

  Orgao({
    required this.codOrgao,
    required this.anoExercicio,
    required this.usuarioResponsavel,
    required this.nomOrgao,
    required this.situacao,
  });

  factory Orgao.invalid() {
    return Orgao(
        codOrgao: -1,
        anoExercicio: DateTime.now().year.toString(),
        usuarioResponsavel: 0,
        nomOrgao: '',
        situacao: '1');
  }

  Orgao copyWith({
    int? codOrgao,
    String? anoExercicio,
    int? usuarioResponsavel,
    String? nomOrgao,
    String? situacao,
  }) {
    return Orgao(
      codOrgao: codOrgao ?? this.codOrgao,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      usuarioResponsavel: usuarioResponsavel ?? this.usuarioResponsavel,
      nomOrgao: nomOrgao ?? this.nomOrgao,
      situacao: situacao ?? this.situacao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_orgao': codOrgao,
      'ano_exercicio': anoExercicio,
      'usuario_responsavel': usuarioResponsavel,
      'nom_orgao': nomOrgao,
      'situacao': situacao,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('cod_orgao');
  }

  factory Orgao.fromMap(Map<String, dynamic> map) {
    return Orgao(
      codOrgao: map['cod_orgao'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      usuarioResponsavel: map['usuario_responsavel'] as int,
      nomOrgao: map['nom_orgao'] as String,
      situacao: map['situacao'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Orgao.fromJson(String source) =>
      Orgao.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Orgao(cod_orgao: $codOrgao, ano_exercicio: $anoExercicio, usuario_responsavel: $usuarioResponsavel, nom_orgao: $nomOrgao, situacao: $situacao)';
  }

  @override
  bool operator ==(covariant Orgao other) {
    if (identical(this, other)) return true;

    return other.codOrgao == codOrgao && other.anoExercicio == anoExercicio;
  }

  @override
  int get hashCode {
    return codOrgao.hashCode ^ anoExercicio.hashCode;
  }
}
