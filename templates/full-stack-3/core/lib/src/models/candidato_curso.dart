import 'package:sibem_core/core.dart';

/// candidatos_cursos
class CandidatoCurso implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'candidatos_cursos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
