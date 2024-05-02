import 'package:sibem_core/core.dart';

class Municipio implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'municipios';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int idUF;
  String ibge;
  String nome;
  String? siglaUF;

  Municipio({
    this.id = -1,
    required this.idUF,
    required this.ibge,
    required this.nome,
    this.siglaUF,
  });

  factory Municipio.fromMap(Map<String, dynamic> map) {
    return Municipio(
        id: map['id'],
        idUF: map['idUF'],
        ibge: map['ibge'],
        nome: map['nome'],
        siglaUF: map['siglaUF']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idUF': idUF,
      'ibge': ibge,
      'nome': nome,
      'siglaUF': siglaUF
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }
}
