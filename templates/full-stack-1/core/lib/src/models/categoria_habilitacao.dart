import 'package:new_sali_core/src/models/base_model.dart';

class CategoriaHabilitacao implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_categoria_habilitacao';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codCategoria;
  String nomCategoria;

  CategoriaHabilitacao({
    required this.codCategoria,
    required this.nomCategoria,
  });

  CategoriaHabilitacao copyWith({
    int? cod_categoria,
    String? nom_categoria,
  }) {
    return CategoriaHabilitacao(
      codCategoria: cod_categoria ?? this.codCategoria,
      nomCategoria: nom_categoria ?? this.nomCategoria,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_categoria': codCategoria,
      'nom_categoria': nomCategoria,
    };
  }

  factory CategoriaHabilitacao.fromMap(Map<String, dynamic> map) {
    return CategoriaHabilitacao(
      codCategoria: map['cod_categoria'] as int,
      nomCategoria: map['nom_categoria'] as String,
    );
  }

  @override
  String toString() =>
      'CategoriaHabilitacao(cod_categoria: $codCategoria, nom_categoria: $nomCategoria)';

  @override
  bool operator ==(covariant CategoriaHabilitacao other) {
    if (identical(this, other)) return true;

    return other.codCategoria == codCategoria;
  }

  @override
  int get hashCode => codCategoria.hashCode;
}
