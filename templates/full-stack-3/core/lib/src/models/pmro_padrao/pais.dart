import 'package:sibem_core/core.dart';

class Pais extends SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'paises';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  String nome;

  Pais({
    required this.id,
    required this.nome,
  });

  factory Pais.fromMap(Map<String, dynamic> map) {
    return Pais(id: map['id'], nome: map['nome']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'nome': nome};
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }
}
