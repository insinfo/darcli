import 'package:new_sali_core/new_sali_core.dart';

/// define um TipoAtributo para AtributoDinamico
/// 1	Numerico	Tipo de dados para números
/// 2	Texto	Tipo de dados para textos
/// 3	Lista	Tipo de dados para listas
/// 4	Lista Múltipla	Tipo de dados para listas de múltipla escolha
/// 5	Data	Tipo de dados para datas
/// 6	Numerico (*,2)	Tipo de dados para Números (*,2)
/// 7	Texto Longo	Tipo de dados para textos maiores que 500 caracteres
class TipoAtributo implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'administracao';

  /// nome da tabela
  static const String tableName = 'tipo_atributo';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int4 not null key
  int codTipo;

  /// varchar 20 not null
  String nomTipo;

  /// text not null
  String descricao;

  TipoAtributo({
    required this.codTipo,
    required this.nomTipo,
    required this.descricao,
  });

  TipoAtributo copyWith({
    int? cod_tipo,
    String? nom_tipo,
    String? descricao,
  }) {
    return TipoAtributo(
      codTipo: cod_tipo ?? this.codTipo,
      nomTipo: nom_tipo ?? this.nomTipo,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_tipo': codTipo,
      'nom_tipo': nomTipo,
      'descricao': descricao,
    };
  }

  factory TipoAtributo.fromMap(Map<String, dynamic> map) {
    return TipoAtributo(
      codTipo: map['cod_tipo'] as int,
      nomTipo: map['nom_tipo'] as String,
      descricao: map['descricao'] as String,
    );
  }

  @override
  String toString() =>
      'TipoAtributo(cod_tipo: $codTipo, nom_tipo: $nomTipo, descricao: $descricao)';

  @override
  bool operator ==(covariant TipoAtributo other) {
    if (identical(this, other)) return true;

    return other.codTipo == codTipo;
  }

  @override
  int get hashCode => codTipo.hashCode;
}
