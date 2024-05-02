import 'package:new_sali_core/new_sali_core.dart';

/// define n Valor Padrao para um AtributoDinamico
class AtributoValorPadrao implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'administracao';

  /// nome da tabela
  static const String tableName = 'atributo_valor_padrao';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int4 not null key
  int codModulo;

  /// int4 not null key
  int codCadastro;

  /// int4 not null key
  int codAtributo;

  /// int4 not null key
  int codValor;

  /// bool
  bool ativo;

  /// varchar 500
  String valorPadrao;

  AtributoValorPadrao({
    required this.codModulo,
    required this.codCadastro,
    required this.codAtributo,
    required this.codValor,
    required this.ativo,
    required this.valorPadrao,
  });

  AtributoValorPadrao copyWith({
    int? cod_modulo,
    int? cod_cadastro,
    int? cod_atributo,
    int? cod_valor,
    bool? ativo,
    String? valor_padrao,
  }) {
    return AtributoValorPadrao(
      codModulo: cod_modulo ?? this.codModulo,
      codCadastro: cod_cadastro ?? this.codCadastro,
      codAtributo: cod_atributo ?? this.codAtributo,
      codValor: cod_valor ?? this.codValor,
      ativo: ativo ?? this.ativo,
      valorPadrao: valor_padrao ?? this.valorPadrao,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_cadastro': codCadastro,
      'cod_atributo': codAtributo,
      'cod_valor': codValor,
      'ativo': ativo,
      'valor_padrao': valorPadrao,
    };

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap();
  }

  factory AtributoValorPadrao.fromMap(Map<String, dynamic> map) {
    return AtributoValorPadrao(
      codModulo: map['cod_modulo'] as int,
      codCadastro: map['cod_cadastro'] as int,
      codAtributo: map['cod_atributo'] as int,
      codValor: map['cod_valor'] as int,
      ativo: map['ativo'] as bool,
      valorPadrao: map['valor_padrao'] as String,
    );
  }

  @override
  String toString() {
    return 'AtributoValorPadrao(cod_modulo: $codModulo, cod_cadastro: $codCadastro, cod_atributo: $codAtributo, cod_valor: $codValor, ativo: $ativo, valor_padrao: $valorPadrao)';
  }

  @override
  bool operator ==(covariant AtributoValorPadrao other) {
    if (identical(this, other)) return true;

    return other.codModulo == codModulo &&
        other.codCadastro == codCadastro &&
        other.codAtributo == codAtributo &&
        other.codValor == codValor;
  }

  @override
  int get hashCode {
    return codModulo.hashCode ^
        codCadastro.hashCode ^
        codAtributo.hashCode ^
        codValor.hashCode;
  }
}
