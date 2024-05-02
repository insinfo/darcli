// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/src/models/base_model.dart';

class Escolaridade implements BaseModel {

  static const String schemaName = 'public';
  static const String tableName = 'sw_escolaridade';

  int codEscolaridade;

  /// varchar 25
  String descricao;

  Escolaridade({
    required this.codEscolaridade,
    required this.descricao,
  });

  Escolaridade copyWith({
    int? codEscolaridade,
    String? descricao,
  }) {
    return Escolaridade(
      codEscolaridade: codEscolaridade ?? this.codEscolaridade,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_escolaridade': codEscolaridade,
      'descricao': descricao,
    };
  }

  factory Escolaridade.fromMap(Map<String, dynamic> map) {
    return Escolaridade(
      codEscolaridade: map['cod_escolaridade'] as int,
      descricao: map['descricao'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Escolaridade.fromJson(String source) =>
      Escolaridade.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Escolaridade(cod_escolaridade: $codEscolaridade, descricao: $descricao)';

  @override
  bool operator ==(covariant Escolaridade other) {
    if (identical(this, other)) return true;

    return other.codEscolaridade == codEscolaridade;
  }

  @override
  int get hashCode => codEscolaridade.hashCode;
}
