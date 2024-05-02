import 'package:new_sali_core/new_sali_core.dart';

///
class AtributoIntegridade implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'administracao';

  /// nome da tabela
  static const String tableName = 'atributo_integridade';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int4 nor null key
  int codModulo;

  /// int4 nor null key
  int codCadastro;

  /// int4 nor null key
  int codAtributo;

  /// int4 nor null key
  int codIntegridade;

  /// text null
  String regra;


  AtributoIntegridade({
    required this.codModulo,
    required this.codCadastro,
    required this.codAtributo,
    required this.codIntegridade,
    required this.regra,
  });

  AtributoIntegridade copyWith({
    int? cod_modulo,
    int? cod_cadastro,
    int? cod_atributo,
    int? cod_integridade,
    String? regra,
  }) {
    return AtributoIntegridade(
      codModulo: cod_modulo ?? this.codModulo,
      codCadastro: cod_cadastro ?? this.codCadastro,
      codAtributo: cod_atributo ?? this.codAtributo,
      codIntegridade: cod_integridade ?? this.codIntegridade,
      regra: regra ?? this.regra,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_cadastro': codCadastro,
      'cod_atributo': codAtributo,
      'cod_integridade': codIntegridade,
      'regra': regra,
    };
  }

  factory AtributoIntegridade.fromMap(Map<String, dynamic> map) {
    return AtributoIntegridade(
      codModulo: map['cod_modulo'] as int,
      codCadastro: map['cod_cadastro'] as int,
      codAtributo: map['cod_atributo'] as int,
      codIntegridade: map['cod_integridade'] as int,
      regra: map['regra'] as String,
    );
  }

  @override
  String toString() {
    return 'AtributoIntegridade(cod_modulo: $codModulo, cod_cadastro: $codCadastro, cod_atributo: $codAtributo, cod_integridade: $codIntegridade, regra: $regra)';
  }

  @override
  bool operator ==(covariant AtributoIntegridade other) {
    if (identical(this, other)) return true;

    return other.codModulo == codModulo &&
        other.codCadastro == codCadastro &&
        other.codAtributo == codAtributo &&
        other.codIntegridade == codIntegridade &&
        other.regra == regra;
  }

  @override
  int get hashCode {
    return codModulo.hashCode ^
        codCadastro.hashCode ^
        codAtributo.hashCode ^
        codIntegridade.hashCode ^
        regra.hashCode;
  }
}
