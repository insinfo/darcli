import 'package:new_sali_core/new_sali_core.dart';

/// vincula função a AtributoDinamico
class AtributoFuncao implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'administracao';

  /// nome da tabela
  static const String tableName = 'atributo_funcao';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int4 not null key
  int codModulo;

  /// int4 not null key
  int codBiblioteca;

  /// int4 not null key
  int codFuncao;

  /// int4 not null key
  int codCadastro;

  /// int4 not null key
  int codAtributo;

  AtributoFuncao({
    required this.codModulo,
    required this.codBiblioteca,
    required this.codFuncao,
    required this.codCadastro,
    required this.codAtributo,
  });

  AtributoFuncao copyWith({
    int? cod_modulo,
    int? cod_biblioteca,
    int? cod_funcao,
    int? cod_cadastro,
    int? cod_atributo,
  }) {
    return AtributoFuncao(
      codModulo: cod_modulo ?? this.codModulo,
      codBiblioteca: cod_biblioteca ?? this.codBiblioteca,
      codFuncao: cod_funcao ?? this.codFuncao,
      codCadastro: cod_cadastro ?? this.codCadastro,
      codAtributo: cod_atributo ?? this.codAtributo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_biblioteca': codBiblioteca,
      'cod_funcao': codFuncao,
      'cod_cadastro': codCadastro,
      'cod_atributo': codAtributo,
    };
  }

  factory AtributoFuncao.fromMap(Map<String, dynamic> map) {
    return AtributoFuncao(
      codModulo: map['cod_modulo'] as int,
      codBiblioteca: map['cod_biblioteca'] as int,
      codFuncao: map['cod_funcao'] as int,
      codCadastro: map['cod_cadastro'] as int,
      codAtributo: map['cod_atributo'] as int,
    );
  }

  @override
  String toString() {
    return 'AtributoFuncao(cod_modulo: $codModulo, cod_biblioteca: $codBiblioteca, cod_funcao: $codFuncao, cod_cadastro: $codCadastro, cod_atributo: $codAtributo)';
  }

  @override
  bool operator ==(covariant AtributoFuncao other) {
    if (identical(this, other)) return true;

    return other.codModulo == codModulo &&
        other.codBiblioteca == codBiblioteca &&
        other.codFuncao == codFuncao &&
        other.codCadastro == codCadastro &&
        other.codAtributo == codAtributo;
  }

  @override
  int get hashCode {
    return codModulo.hashCode ^
        codBiblioteca.hashCode ^
        codFuncao.hashCode ^
        codCadastro.hashCode ^
        codAtributo.hashCode;
  }
}
