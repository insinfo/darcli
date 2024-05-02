import 'package:sibem_core/core.dart';

class Auditoria implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'auditoria';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idCol = 'id';
  static const String dataCol = 'data';
  static const String usuarioNomeCol = 'usuarioNome';
  static const String usuarioIdCol = 'usuarioId';
  static const String acaoCol = 'acao';

  int id;
  DateTime data;
  String? usuarioNome;
  int? usuarioId;
  String? acao;
  String? objeto;
  String? metodo;
  String? path;

  Auditoria({
    required this.id,
    required this.data,
    this.usuarioNome,
    this.usuarioId,
    this.acao,
    this.objeto,
    this.metodo,
    this.path,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'data': data.toIso8601String(),
      'usuarioNome': usuarioNome,
      'usuarioId': usuarioId,
      'acao': acao,
      'objeto': objeto,
      'metodo': metodo,
      'path': path,
    };

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove(idCol)
      ..remove(dataCol);
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove(idCol)
      ..remove(dataCol);
  }

  factory Auditoria.fromMap(Map<String, dynamic> map) {
    return Auditoria(
      id: map['id'] as int,
      data: map['data'] is DateTime
          ? map['data']
          : DateTime.parse(map['data'].toString()),
      usuarioNome:
          map['usuarioNome'] != null ? map['usuarioNome'] as String : null,
      usuarioId: map['usuarioId'] != null ? map['usuarioId'] as int : null,
      acao: map['acao'] != null ? map['acao'] as String : null,
      objeto: map['objeto'] != null ? map['objeto'] as String : null,
      metodo: map['metodo'] != null ? map['metodo'] as String : null,
      path: map['path'] != null ? map['path'] as String : null,
    );
  }

  @override
  String toString() {
    return 'Auditoria(id: $id, data: $data, usuarioNome: $usuarioNome, usuarioId: $usuarioId, acao: $acao, objeto: $objeto, metodo: $metodo, path: $path)';
  }

  @override
  bool operator ==(covariant Auditoria other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
