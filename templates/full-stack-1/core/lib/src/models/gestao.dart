// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

class Gestao implements BaseModel {

  static const String schemaName = 'administracao';
  static const String tableName = 'gestao';
  /// id
  int codGestao;

  /// 1 Administrativa | 2 Financeira | 3 Patrimonial | 4 Recursos Humanos | 5 Tributaria
  String nomGestao;
  String nomDiretorio;
  int ordem;
  /// 2.03.52
  String versao;


  Gestao({
    required this.codGestao,
    required this.nomGestao,
    required this.nomDiretorio,
    required this.ordem,
    required this.versao,
  });

  Gestao copyWith({
    int? cod_gestao,
    String? nom_gestao,
    String? nom_diretorio,
    int? ordem,
    String? versao,
  }) {
    return Gestao(
      codGestao: cod_gestao ?? this.codGestao,
      nomGestao: nom_gestao ?? this.nomGestao,
      nomDiretorio: nom_diretorio ?? this.nomDiretorio,
      ordem: ordem ?? this.ordem,
      versao: versao ?? this.versao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_gestao': codGestao,
      'nom_gestao': nomGestao,
      'nom_diretorio': nomDiretorio,
      'ordem': ordem,
      'versao': versao,
    };
  }

  factory Gestao.fromMap(Map<String, dynamic> map) {
    return Gestao(
      codGestao: map['cod_gestao'] as int,
      nomGestao: map['nom_gestao'] as String,
      nomDiretorio: map['nom_diretorio'] as String,
      ordem: map['ordem'] as int,
      versao: map['versao'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Gestao.fromJson(String source) =>
      Gestao.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Gestao(cod_gestao: $codGestao, nom_gestao: $nomGestao, nom_diretorio: $nomDiretorio, ordem: $ordem, versao: $versao)';
  }

  @override
  bool operator ==(covariant Gestao other) {
    if (identical(this, other)) return true;
    return other.codGestao == codGestao;
  }

  @override
  int get hashCode {
    return codGestao.hashCode;
  }
}
