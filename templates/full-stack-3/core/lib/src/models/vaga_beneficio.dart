import 'package:sibem_core/core.dart';

class VagaBeneficio implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'vagas_beneficios';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String idVagaFqCol = '$tableName.$idVagaCol';
  static const String idVagaCol = 'idVaga';

  static const String valorFqCol = '$tableName.$valorCol';
  static const String valorCol = 'valor';

  static const String observacaoFqCol = '$tableName.$observacaoCol';
  static const String observacaoCol = 'observacao';

  int id;
  int idVaga;
  String beneficio;
  double? valor;
  String? observacao;

  VagaBeneficio({
    this.id = -1,
    required this.idVaga,
    required this.beneficio,
    this.valor,
    this.observacao,
  });

  factory VagaBeneficio.fromMap(Map<String, dynamic> map) {
    return VagaBeneficio(
        id: map['id'],
        idVaga: map['idVaga'],
        beneficio: map['beneficio'],
        valor: map['valor'],
        observacao: map['observacao']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'idVaga': idVaga,
      'beneficio': beneficio,
      'valor': valor,
      'observacao': observacao,
    };
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('check');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('check');
  }
}
