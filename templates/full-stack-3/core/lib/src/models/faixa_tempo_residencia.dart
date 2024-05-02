import 'package:sibem_core/core.dart';

class FaixaTempoResidencia implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'faixas_tempo_residencia';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int tempoMinimo;
  String unidadeTempoMinimo;
  int tempoMaximo;
  String unidaeTempoMaximo;

  FaixaTempoResidencia({
    required this.id,
    required this.tempoMinimo,
    required this.unidadeTempoMinimo,
    required this.tempoMaximo,
    required this.unidaeTempoMaximo,
  });

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tempoMinimo': tempoMinimo,
      'unidadeTempoMinimo': unidadeTempoMinimo,
      'tempoMaximo': tempoMaximo,
      'unidaeTempoMaximo': unidaeTempoMaximo,
    };
  }

  factory FaixaTempoResidencia.fromMap(Map<String, dynamic> map) {
    return FaixaTempoResidencia(
      id: map['id'],
      tempoMinimo: map['tempoMinimo'],
      unidadeTempoMinimo: map['unidadeTempoMinimo'],
      tempoMaximo: map['tempoMaximo'],
      unidaeTempoMaximo: map['unidaeTempoMaximo'],
    );
  }
}
