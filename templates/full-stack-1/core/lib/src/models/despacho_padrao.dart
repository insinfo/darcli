import 'dart:convert';

import 'package:new_sali_core/src/models/base_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DespachoPadrao implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_despacho_padrao';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int 4 not null limit 32
  int codDespacho;

  /// char limit 30
  String? titulo;

  /// text
  String? texto;

  DespachoPadrao({
    required this.codDespacho,
    this.titulo,
    this.texto,
  });

  factory DespachoPadrao.invalido() {
    return DespachoPadrao(codDespacho: -1, titulo: '');
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_despacho': codDespacho,
      'titulo': titulo,
      'texto': texto,
    };
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('cod_despacho');
  }

  factory DespachoPadrao.fromMap(Map<String, dynamic> map) {
    return DespachoPadrao(
      codDespacho: map['cod_despacho'] as int,
      titulo: map['titulo'] != null ? map['titulo'] as String : null,
      texto: map['texto'] != null ? map['texto'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DespachoPadrao.fromJson(String source) =>
      DespachoPadrao.fromMap(json.decode(source) as Map<String, dynamic>);
}
