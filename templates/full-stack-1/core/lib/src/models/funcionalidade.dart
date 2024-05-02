// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

class Funcionalidade implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'funcionalidade';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codFuncionalidade;
  int codModulo;
  String nomFuncionalidade;
  String nomDiretorio;
  int ordem;

  Funcionalidade({
    required this.codFuncionalidade,
    required this.codModulo,
    required this.nomFuncionalidade,
    required this.nomDiretorio,
    required this.ordem,
  });

  factory Funcionalidade.invalid() {
    return Funcionalidade(
        codFuncionalidade: -1,
        codModulo: -1,
        nomFuncionalidade: '',
        nomDiretorio: '',
        ordem: 1);
  }

  Funcionalidade copyWith({
    int? cod_funcionalidade,
    int? cod_modulo,
    String? nom_funcionalidade,
    String? nom_diretorio,
    int? ordem,
  }) {
    return Funcionalidade(
      codFuncionalidade: cod_funcionalidade ?? this.codFuncionalidade,
      codModulo: cod_modulo ?? this.codModulo,
      nomFuncionalidade: nom_funcionalidade ?? this.nomFuncionalidade,
      nomDiretorio: nom_diretorio ?? this.nomDiretorio,
      ordem: ordem ?? this.ordem,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_funcionalidade': codFuncionalidade,
      'cod_modulo': codModulo,
      'nom_funcionalidade': nomFuncionalidade,
      'nom_diretorio': nomDiretorio,
      'ordem': ordem,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('cod_funcionalidade');
  }

  factory Funcionalidade.fromMap(Map<String, dynamic> map) {
    return Funcionalidade(
      codFuncionalidade: map['cod_funcionalidade'] as int,
      codModulo: map['cod_modulo'] as int,
      nomFuncionalidade: map['nom_funcionalidade'] as String,
      nomDiretorio: map['nom_diretorio'] as String,
      ordem: map['ordem'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Funcionalidade.fromJson(String source) =>
      Funcionalidade.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Funcionalidade(cod_funcionalidade: $codFuncionalidade, cod_modulo: $codModulo, nom_funcionalidade: $nomFuncionalidade, nom_diretorio: $nomDiretorio, ordem: $ordem)';
  }

  @override
  bool operator ==(covariant Funcionalidade other) {
    if (identical(this, other)) return true;

    return other.codFuncionalidade == codFuncionalidade;
  }

  @override
  int get hashCode {
    return codFuncionalidade.hashCode;
  }
}
