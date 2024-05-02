import 'package:new_sali_core/new_sali_core.dart';

class Permissao implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'permissao';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int numCgm;
  int codAcao;

  /// ex: 2012
  String anoExercicio;
  DateTime? timestamp;

  /// propriedade anexada modulo.nom_modulo
  String? nom_modulo;
  int? cod_modulo;
  int? cod_gestao;

  /// propriedade anexada funcionalidade.nom_funcionalidade
  String? nom_funcionalidade;

  /// propriedade anexada funcionalidade.cod_funcionalidade
  int? cod_funcionalidade;
  String? nom_acao;
  int? cod_acao;
  bool? tem_permissao;

  Permissao({
    required this.numCgm,
    required this.codAcao,
    required this.anoExercicio,
    this.timestamp,
  });

  String? nomAcao;

  Permissao copyWith({
    int? numCgm,
    int? codAcao,
    String? anoExercicio,
    DateTime? timestamp,
  }) {
    return Permissao(
      numCgm: numCgm ?? this.numCgm,
      codAcao: codAcao ?? this.codAcao,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'numcgm': numCgm,
      'cod_acao': codAcao,
      'ano_exercicio': anoExercicio,
      'timestamp': timestamp?.toString(),
    };

    if (nomAcao != null) {
      map['nom_acao'] = nomAcao;
    }
    if (nom_modulo != null) {
      map['nom_modulo'] = nom_modulo;
    }
    if (cod_modulo != null) {
      map['cod_modulo'] = cod_modulo;
    }
    if (cod_gestao != null) {
      map['cod_gestao'] = cod_gestao;
    }
    if (cod_gestao != null) {
      map['cod_gestao'] = cod_gestao;
    }
    if (nom_funcionalidade != null) {
      map['nom_funcionalidade'] = nom_funcionalidade;
    }
    if (cod_funcionalidade != null) {
      map['cod_funcionalidade'] = cod_funcionalidade;
    }
    if (nom_acao != null) {
      map['nom_acao'] = nom_acao;
    }
    if (cod_acao != null) {
      map['cod_acao'] = cod_acao;
    }
    if (tem_permissao != null) {
      map['tem_permissao'] = tem_permissao;
    }

    return map;
  }

  factory Permissao.fromMap(Map<String, dynamic> map) {
    var permi = Permissao(
      numCgm: map['numcgm'] as int,
      codAcao: map['cod_acao'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      timestamp:
          map['timestamp'] != null ? DateTime.parse(map['timestamp']) : null,
    );
    if (map['nom_acao'] != null) {
      permi.nomAcao = map['nom_acao'];
    }

    if (map['nom_modulo'] != null) {
      permi.nom_modulo = map['nom_modulo'];
    }
    if (map['cod_modulo'] != null) {
      permi.cod_modulo = map['cod_modulo'];
    }
    if (map['cod_gestao'] != null) {
      permi.cod_gestao = map['cod_gestao'];
    }
    if (map['nom_funcionalidade'] != null) {
      permi.nom_funcionalidade = map['nom_funcionalidade'];
    }
    if (map['cod_funcionalidade'] != null) {
      permi.cod_funcionalidade = map['cod_funcionalidade'];
    }
    if (map['nom_acao'] != null) {
      permi.nom_acao = map['nom_acao'];
    }
    if (map['cod_acao'] != null) {
      permi.cod_acao = map['cod_acao'];
    }
    if (map['tem_permissao'] != null) {
      permi.tem_permissao = map['tem_permissao'];
    }

    return permi;
  }

  @override
  String toString() {
    return 'Permissao(numcgm: $numCgm, cod_acao: $codAcao, ano_exercicio: $anoExercicio, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant Permissao other) {
    if (identical(this, other)) return true;

    return other.numCgm == numCgm &&
        other.codAcao == codAcao &&
        other.anoExercicio == anoExercicio;
  }

  @override
  int get hashCode {
    return numCgm.hashCode ^ codAcao.hashCode ^ anoExercicio.hashCode;
  }
}
