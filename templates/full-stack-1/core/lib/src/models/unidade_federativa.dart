// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:new_sali_core/src/models/base_model.dart';

class UnidadeFederativa implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_uf';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// int4 primary key
  int codUf;

  /// int4 FOREIGN KEY
  int codPais;

  /// varchar 50
  String nomUf;

  /// char 2
  String siglaUf;

  /// propriedade anexada somente para uso na UI
  bool selected = false;
  bool disabled = false;

  UnidadeFederativa({
    required this.codUf,
    required this.codPais,
    required this.nomUf,
    required this.siglaUf,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_uf': codUf,
      'cod_pais': codPais,
      'nom_uf': nomUf,
      'sigla_uf': siglaUf,
    };
    return map;
  }

  factory UnidadeFederativa.fromMap(Map<String, dynamic> map) {
    return UnidadeFederativa(
      codUf: map['cod_uf'] as int,
      codPais: map['cod_pais'] as int,
      nomUf: map['nom_uf'] as String,
      siglaUf: map['sigla_uf'] as String,
    );
  }
}
