import 'package:new_sali_core/new_sali_core.dart';

/// define uma funcao vinculada a AtributoDinamico
class Funcao implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'administracao';

  /// nome da tabela
  static const String tableName = 'funcao';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int4 nor null key
  int codModulo;

  /// int4 nor null key
  int codBiblioteca;

  /// int4 nor null key
  int codFuncao;

  /// int4 nor null
  int codTipoRetorno;

  /// varchar 255
  String? nomFuncao;

  Funcao({
    required this.codModulo,
    required this.codBiblioteca,
    required this.codFuncao,
    required this.codTipoRetorno,
    this.nomFuncao,
  });

  Funcao copyWith({
    int? cod_modulo,
    int? cod_biblioteca,
    int? cod_funcao,
    int? cod_tipo_retorno,
    String? nom_funcao,
  }) {
    return Funcao(
      codModulo: cod_modulo ?? this.codModulo,
      codBiblioteca: cod_biblioteca ?? this.codBiblioteca,
      codFuncao: cod_funcao ?? this.codFuncao,
      codTipoRetorno: cod_tipo_retorno ?? this.codTipoRetorno,
      nomFuncao: nom_funcao ?? this.nomFuncao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_biblioteca': codBiblioteca,
      'cod_funcao': codFuncao,
      'cod_tipo_retorno': codTipoRetorno,
      'nom_funcao': nomFuncao,
    };
  }

  factory Funcao.fromMap(Map<String, dynamic> map) {
    return Funcao(
      codModulo: map['cod_modulo'] as int,
      codBiblioteca: map['cod_biblioteca'] as int,
      codFuncao: map['cod_funcao'] as int,
      codTipoRetorno: map['cod_tipo_retorno'] as int,
      nomFuncao:
          map['nom_funcao'] != null ? map['nom_funcao'] as String : null,
    );
  }

  @override
  String toString() {
    return 'AtributoDinamico(cod_modulo: $codModulo, cod_biblioteca: $codBiblioteca, cod_funcao: $codFuncao, cod_tipo_retorno: $codTipoRetorno, nom_funcao: $nomFuncao)';
  }

  @override
  bool operator ==(covariant Funcao other) {
    if (identical(this, other)) return true;

    return other.codModulo == codModulo &&
        other.codBiblioteca == codBiblioteca &&
        other.codFuncao == codFuncao;
  }

  @override
  int get hashCode {
    return codModulo.hashCode ^ codBiblioteca.hashCode ^ codFuncao.hashCode;
  }
}
