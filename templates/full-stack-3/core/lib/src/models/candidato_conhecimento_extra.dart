import 'package:sibem_core/core.dart';

/// candidatos_conhecimentos_extras
class CandidatoConhecimentoExtra implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'candidatos_conhecimentos_extras';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idConhecimentoExtraFqCol =
      '$tableName.$idConhecimentoExtraCol';
  static const String idConhecimentoExtraCol = 'idConhecimentoExtra';

  static const String nivelConhecimentoFqCol =
      '$tableName.$nivelConhecimentoCol';
  static const String nivelConhecimentoCol = 'nivelConhecimento';

  static const String idCandidatoFqCol = '$tableName.$idCandidatoCol';
  static const String idCandidatoCol = 'idCandidato';

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
