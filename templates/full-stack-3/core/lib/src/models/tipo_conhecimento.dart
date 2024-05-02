import 'package:sibem_core/core.dart';

class TipoConhecimento implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'tipos_conhecimentos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id; //! Obrigatorio
  String nome; //! Obrigatorio

  TipoConhecimento({
    required this.id,
    required this.nome,
  });

  factory TipoConhecimento.fromMap(Map<String, dynamic> map) {
    return TipoConhecimento(
      id: map['id'],
      nome: map['nome'],
    );
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
