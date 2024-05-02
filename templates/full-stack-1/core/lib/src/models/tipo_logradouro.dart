// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/src/models/base_model.dart';

class TipoLogradouro implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_tipo_logradouro';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codTipo;

  /// varchar 15
  String nomTipo;

  TipoLogradouro({
    required this.codTipo,
    required this.nomTipo,
  });

  TipoLogradouro copyWith({
    int? codTipo,
    String? nomTipo,
  }) {
    return TipoLogradouro(
      codTipo: codTipo ?? this.codTipo,
      nomTipo: nomTipo ?? this.nomTipo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_tipo': codTipo,
      'nom_tipo': nomTipo,
    };
  }

  factory TipoLogradouro.fromMap(Map<String, dynamic> map) {
    return TipoLogradouro(
      codTipo: map['cod_tipo'] as int,
      nomTipo: map['nom_tipo'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TipoLogradouro.fromJson(String source) =>
      TipoLogradouro.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TipoLogradouro(cod_tipo: $codTipo, nom_tipo: $nomTipo)';

  @override
  bool operator ==(covariant TipoLogradouro other) {
    if (identical(this, other)) return true;

    return other.codTipo == codTipo;
  }

  @override
  int get hashCode => codTipo.hashCode;
}
