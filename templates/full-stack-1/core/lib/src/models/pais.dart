// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/src/models/base_model.dart';

class Pais implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_pais';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codPais;
  int codRais;
  String nomPais;
  String nacionalidade;

  /// propriedade anexada somente para uso na UI
  bool selected = false;
  bool disabled = false;

  Pais({
    required this.codPais,
    required this.codRais,
    required this.nomPais,
    required this.nacionalidade,
  });

  Pais copyWith({
    int? cod_pais,
    int? cod_rais,
    String? nom_pais,
    String? nacionalidade,
  }) {
    return Pais(
      codPais: cod_pais ?? this.codPais,
      codRais: cod_rais ?? this.codRais,
      nomPais: nom_pais ?? this.nomPais,
      nacionalidade: nacionalidade ?? this.nacionalidade,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_pais': codPais,
      'cod_rais': codRais,
      'nom_pais': nomPais,
      'nacionalidade': nacionalidade,
    };
  }

  factory Pais.fromMap(Map<String, dynamic> map) {
    return Pais(
      codPais: map['cod_pais'] as int,
      codRais: map['cod_rais'] as int,
      nomPais: map['nom_pais'] as String,
      nacionalidade: map['nacionalidade'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Pais.fromJson(String source) =>
      Pais.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Pais(cod_pais: $codPais, cod_rais: $codRais, nom_pais: $nomPais, nacionalidade: $nacionalidade)';
  }

  @override
  bool operator ==(covariant Pais other) {
    if (identical(this, other)) return true;
    return other.codPais == codPais;
  }

  @override
  int get hashCode {
    return codPais.hashCode;
  }
}
