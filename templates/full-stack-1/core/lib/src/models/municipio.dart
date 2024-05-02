// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:new_sali_core/src/models/base_model.dart';

class Municipio implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_municipio';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codMunicipio;
  int codUf;
  String nomMunicipio;

  /// propriedade anexada somente para uso na UI
  bool selected = false;
  bool disabled = false;

  Municipio({
    required this.codMunicipio,
    required this.codUf,
    required this.nomMunicipio,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_municipio': codMunicipio,
      'cod_uf': codUf,
      'nom_municipio': nomMunicipio,
    };
  }

  factory Municipio.fromMap(Map<String, dynamic> map) {
    return Municipio(
      codMunicipio: map['cod_municipio'] as int,
      codUf: map['cod_uf'] as int,
      nomMunicipio: map['nom_municipio'] as String,
    );
  }
}
