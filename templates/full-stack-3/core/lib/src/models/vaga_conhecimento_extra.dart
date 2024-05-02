import 'package:sibem_core/core.dart';

class VagaConhecimentoExtra implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'vagas_conhecimentos_extras';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idVagaFqCol = '$tableName.$idVagaCol';
  static const String idVagaCol = 'idVaga';

  static const String idConhecimentoExtraFqCol =
      '$tableName.$idConhecimentoExtraCol';
  static const String idConhecimentoExtraCol = 'idConhecimentoExtra';

  static const String obrigatorioFqCol = '$tableName.$obrigatorioCol';
  static const String obrigatorioCol = 'obrigatorio';

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
