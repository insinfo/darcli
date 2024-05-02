import 'package:sibem_core/core.dart';

class VagaCurso implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'vagas_cursos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';
  static const String idCursoFqCol = '$tableName.$idCursoCol';
  static const String idCursoCol = 'idCurso';

  static const String idVagaFqCol = '$tableName.$idVagaCol';
  static const String idVagaCol = 'idVaga';

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
