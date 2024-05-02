// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:new_sali_core/new_sali_core.dart';

class Unidade implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'unidade';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codUnidade;

  /// Equivale ao ano Execicio do Orgão
  /// pois tanto setor/departamento/unidade usa o ano do orgão
  String anoExercicio;

  int codOrgao;

  int usuarioResponsavel;
  String nomUnidade;

  /// 0 | 1
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

  Unidade({
    required this.codUnidade,
    required this.anoExercicio,
    required this.codOrgao,
    required this.usuarioResponsavel,
    required this.nomUnidade,
    this.situacao,
  });

  factory Unidade.invalid() {
    return Unidade(
      codUnidade: -1,
      anoExercicio: '-1',
      codOrgao: -1,
      usuarioResponsavel: 0,
      nomUnidade: '',
      situacao: '1',
    );
  }

  Unidade copyWith({
    int? codUnidade,
    String? anoExercicio,
    int? codOrgao,
    int? usuarioResponsavel,
    String? nomUnidade,
    String? situacao,
  }) {
    return Unidade(
      codUnidade: codUnidade ?? this.codUnidade,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codOrgao: codOrgao ?? this.codOrgao,
      usuarioResponsavel: usuarioResponsavel ?? this.usuarioResponsavel,
      nomUnidade: nomUnidade ?? this.nomUnidade,
      situacao: situacao,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_unidade': codUnidade,
      'ano_exercicio': anoExercicio,
      'cod_orgao': codOrgao,
      'usuario_responsavel': usuarioResponsavel,
      'nom_unidade': nomUnidade,
      'situacao': situacao,
    };
    if (nomOrgao != null) {
      map['nom_orgao'] = nomOrgao;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('nom_orgao');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cod_unidade')
      ..remove('nom_orgao');
  }

  factory Unidade.fromMap(Map<String, dynamic> map) {
    final uni = Unidade(
      codUnidade: map['cod_unidade'],
      anoExercicio: map['ano_exercicio'],
      codOrgao: map['cod_orgao'],
      usuarioResponsavel: map['usuario_responsavel'],
      nomUnidade: map['nom_unidade'],
      situacao: map['situacao'],
    );
    if (map.containsKey('nom_orgao')) {
      uni.nomOrgao = map['nom_orgao'];
    }
    return uni;
  }

  @override
  String toString() {
    return 'Unidade(cod_unidade: $codUnidade, ano_exercicio: $anoExercicio, cod_orgao: $codOrgao, usuario_responsavel: $usuarioResponsavel, nom_unidade: $nomUnidade, situacao: $situacao)';
  }

  @override
  bool operator ==(covariant Unidade other) {
    if (identical(this, other)) return true;

    return other.codUnidade == codUnidade &&
        other.anoExercicio == anoExercicio &&
        other.codOrgao == codOrgao;
  }

  @override
  int get hashCode {
    return codUnidade.hashCode ^ anoExercicio.hashCode ^ codOrgao.hashCode;
  }
}
