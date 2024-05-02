import 'package:sibem_core/core.dart';

class Escolaridade implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'escolaridades';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String ordemGraduacaoFqCol = '$tableName.$ordemGraduacaoCol';
  static const String ordemGraduacaoCol = 'ordemGraduacao';

  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String nomeFqCol = '$tableName.$nomeCol';
  static const String nomeCol = 'nome';

  /// Obrigatorio
  int id;

  /// Obrigatorio
  String nome;

  /// Obrigatorio
  int ordemGraduacao;

  Escolaridade({
    this.id = -1,
    required this.nome,
    required this.ordemGraduacao,
  });

  factory Escolaridade.fromMap(Map<String, dynamic> map) {
    return Escolaridade(
        id: map['id'],
        nome: map['nome'],
        ordemGraduacao: map['ordemGraduacao']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'ordemGraduacao': ordemGraduacao,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }
}
