// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

class Setor implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'setor';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codSetor;
  int codUnidade;

  /// Equivale ao ano Execicio do Orgão
  /// pois tanto setor/departamento/unidade usa o ano do orgão
  String anoExercicio;

  int codOrgao;
  int codDepartamento;

  /// usuario Responsavel setor pode ser 0
  int usuarioResponsavel;
  String nomSetor;
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

  /// propriedade anexada nome Orgao
  String? nomOrgao;

  /// propriedade anexada nome Unidade
  String? nomUnidade;

  /// propriedade anexada nome Departamento
  String? nomDepartamento;

  /// novo idSetor serial adicionado para o 
  int id;

  Setor({
    required this.id,
    required this.codSetor,
    required this.codUnidade,
    required this.anoExercicio,
    required this.codOrgao,
    required this.codDepartamento,
    required this.usuarioResponsavel,
    required this.nomSetor,
    this.situacao,
  });

  factory Setor.invalid() {
    return Setor(
        id: -1,
        codSetor: -1,
        codOrgao: -1,
        codUnidade: -1,
        codDepartamento: -1,
        anoExercicio: DateTime.now().year.toString(),
        usuarioResponsavel: 0,
        nomSetor: '',
        situacao: '1');
  }

  Setor copyWith({
    int? id,
    int? codSetor,
    int? codUnidade,
    String? anoExercicio,
    int? codOrgao,
    int? codDepartamento,
    int? usuarioResponsavel,
    String? nomSetor,
    String? situacao,
  }) {
    return Setor(
      id: id ?? this.id,
      codSetor: codSetor ?? this.codSetor,
      codUnidade: codUnidade ?? this.codUnidade,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codOrgao: codOrgao ?? this.codOrgao,
      codDepartamento: codDepartamento ?? this.codDepartamento,
      usuarioResponsavel: usuarioResponsavel ?? this.usuarioResponsavel,
      nomSetor: nomSetor ?? this.nomSetor,
      situacao: situacao ?? this.situacao,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'cod_setor': codSetor,
      'cod_unidade': codUnidade,
      'ano_exercicio': anoExercicio,
      'cod_orgao': codOrgao,
      'cod_departamento': codDepartamento,
      'usuario_responsavel': usuarioResponsavel,
      'nom_setor': nomSetor,
      'situacao': situacao,
    };

    if (nomOrgao != null) {
      map['nom_orgao'] = nomOrgao;
    }
    if (nomUnidade != null) {
      map['nom_unidade'] = nomUnidade;
    }
    if (nomDepartamento != null) {
      map['nom_departamento'] = nomDepartamento;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('selected')
      ..remove('disabled')
      ..remove('nom_orgao')
      ..remove('nom_unidade')
      ..remove('nom_departamento');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('cod_setor')
      ..remove('selected')
      ..remove('disabled')
      ..remove('nom_orgao')
      ..remove('nom_unidade')
      ..remove('nom_departamento');
  }

  factory Setor.fromMap(Map<String, dynamic> map) {
    final setor = Setor(
      id: map['id'],
      codSetor: map['cod_setor'] as int,
      codUnidade: map['cod_unidade'] as int,
      anoExercicio: map['ano_exercicio'],
      codOrgao: map['cod_orgao'] as int,
      codDepartamento: map['cod_departamento'] as int,
      usuarioResponsavel: map['usuario_responsavel'] as int,
      nomSetor: map['nom_setor'] as String,
      situacao: map['situacao'] != null ? map['situacao'] as String : null,
    );

    if (map.containsKey('nom_orgao')) {
      setor.nomOrgao = map['nom_orgao'];
    }
    if (map.containsKey('nom_unidade')) {
      setor.nomUnidade = map['nom_unidade'];
    }
    if (map.containsKey('nom_departamento')) {
      setor.nomDepartamento = map['nom_departamento'];
    }

    return setor;
  }

  String toJson() => json.encode(toMap());

  factory Setor.fromJson(String source) =>
      Setor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Setor(cod_setor: $codSetor, cod_unidade: $codUnidade, ano_exercicio: $anoExercicio, cod_orgao: $codOrgao, cod_departamento: $codDepartamento, usuario_responsavel: $usuarioResponsavel, nom_setor: $nomSetor, situacao: $situacao)';
  }

  @override
  bool operator ==(covariant Setor other) {
    if (identical(this, other)) return true;

    return other.codSetor == codSetor &&
        other.codUnidade == codUnidade &&
        other.anoExercicio == anoExercicio &&
        other.codOrgao == codOrgao &&
        other.codDepartamento == codDepartamento;
  }

  @override
  int get hashCode {
    return codSetor.hashCode ^
        codUnidade.hashCode ^
        anoExercicio.hashCode ^
        codOrgao.hashCode ^
        codDepartamento.hashCode;
  }
}
