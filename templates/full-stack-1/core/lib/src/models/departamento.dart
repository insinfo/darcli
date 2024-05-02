// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/src/models/base_model.dart';

class Departamento implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'departamento';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codDepartamento;
  int codOrgao;

  /// Equivale ao ano Execicio do Orgão
  /// pois tanto setor/departamento/unidade usa o ano do orgão
  String anoExercicio;

  int codUnidade;
  int usuarioResponsavel;
  String nomDepartamento;

  /// Campo criado pela PMRO 1 | 0
  String? situacao;

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

  String? nomOrgao;
  String? nomUnidade;

  Departamento({
    required this.codDepartamento,
    required this.codOrgao,
    required this.anoExercicio,
    required this.codUnidade,
    required this.usuarioResponsavel,
    required this.nomDepartamento,
    this.situacao,
  });

  factory Departamento.invalid() {
    return Departamento(
        anoExercicio: '-1',
        codDepartamento: -1,
        codOrgao: -1,
        codUnidade: -1,
        usuarioResponsavel: 0,
        nomDepartamento: '',
        situacao: '1');
  }

  Departamento copyWith({
    int? codDepartamento,
    int? codOrgao,
    String? anoExercicio,
    int? codUnidade,
    int? usuarioResponsavel,
    String? nomDepartamento,
    String? situacao,
  }) {
    return Departamento(
      codDepartamento: codDepartamento ?? this.codDepartamento,
      codOrgao: codOrgao ?? this.codOrgao,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codUnidade: codUnidade ?? this.codUnidade,
      usuarioResponsavel: usuarioResponsavel ?? this.usuarioResponsavel,
      nomDepartamento: nomDepartamento ?? this.nomDepartamento,
      situacao: situacao ?? this.situacao,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_departamento': codDepartamento,
      'cod_orgao': codOrgao,
      'ano_exercicio': anoExercicio,
      'cod_unidade': codUnidade,
      'usuario_responsavel': usuarioResponsavel,
      'nom_departamento': nomDepartamento,
      'situacao': situacao,
    };
    if (nomOrgao != null) {
      map['nom_orgao'] = nomOrgao;
    }
    if (nomUnidade != null) {
      map['nom_unidade'] = nomUnidade;
    }
    return map;
  }

  factory Departamento.fromMap(Map<String, dynamic> map) {
    final dep = Departamento(
      codDepartamento: map['cod_departamento'] as int,
      codOrgao: map['cod_orgao'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codUnidade: map['cod_unidade'] as int,
      usuarioResponsavel: map['usuario_responsavel'] as int,
      nomDepartamento: map['nom_departamento'] as String,
      situacao: map['situacao'],
    );
    if (map.containsKey('nom_orgao')) {
      dep.nomOrgao = map['nom_orgao'];
    }
    if (map.containsKey('nom_unidade')) {
      dep.nomUnidade = map['nom_unidade'];
    }
    return dep;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('nom_orgao')
      ..remove('nom_unidade');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cod_departamento')
      ..remove('nom_orgao')
      ..remove('nom_unidade');
  }

  String toJson() => json.encode(toMap());

  factory Departamento.fromJson(String source) =>
      Departamento.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Departamento(cod_departamento: $codDepartamento, cod_orgao: $codOrgao, ano_exercicio: $anoExercicio, cod_unidade: $codUnidade, usuario_responsavel: $usuarioResponsavel, nom_departamento: $nomDepartamento, situacao: $situacao)';
  }

  @override
  bool operator ==(covariant Departamento other) {
    if (identical(this, other)) return true;

    return other.codDepartamento == codDepartamento &&
        other.codOrgao == codOrgao &&
        other.anoExercicio == anoExercicio &&
        other.codUnidade == codUnidade;
  }

  @override
  int get hashCode {
    return codDepartamento.hashCode ^
        codOrgao.hashCode ^
        anoExercicio.hashCode ^
        codUnidade.hashCode;
  }
}
