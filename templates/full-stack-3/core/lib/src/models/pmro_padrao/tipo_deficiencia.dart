import 'package:sibem_core/core.dart';

class TipoDeficiencia implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'tipos_deficiencias';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// Obrigatorio
  int id;

  /// Obrigatorio
  String nome;

  TipoDeficiencia({
    required this.id,
    required this.nome,
  });

  factory TipoDeficiencia.fromMap(Map<String, dynamic> map) {
    return TipoDeficiencia(
      id: map['id'],
      nome: map['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'nome': nome,
    };
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }
}
