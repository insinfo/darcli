import 'package:sibem_core/core.dart';

class Uf extends SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'ufs';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int ibge;
  String sigla;
  String nome;
  int? idPais;

  Uf({
    required this.id,
    required this.ibge,
    required this.sigla,
    required this.nome,
    this.idPais,
  });

  factory Uf.fromMap(Map<String, dynamic> map) {
    return Uf(
      id: map['id'],
      ibge: map['ibge'],
      sigla: map['sigla'],
      nome: map['nome'],
      idPais: map['idPais'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ibge': ibge,
      'sigla': sigla,
      'nome': nome,
      'idPais': idPais
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }
}
