import 'package:sibem_core/core.dart';

class DivisaoCnae implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'divisoes_cnae';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idCol = 'id';
  static const String secaoCol = 'secao';
  static const String nomeCol = 'nome';

  int id;
  String secao;
  String nome;

  DivisaoCnae({
    this.id = -1,
    required this.secao,
    required this.nome,
  });

  factory DivisaoCnae.invalid() {
    return DivisaoCnae(
      id: -1,
      secao: '',
      nome: '',
    );
  }

  factory DivisaoCnae.fromMap(Map<String, dynamic> map) {
    return DivisaoCnae(
      id: map['id'],
      secao: map['secao'],
      nome: map['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'secao': secao,
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
