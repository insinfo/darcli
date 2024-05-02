import 'package:new_sali_core/new_sali_core.dart';

/// a tabela 'cadastro' parece definir qual modulo suporta atributo dinamico
class Cadastro implements BaseModel {
  // /// nome do esquema
  // static const String schemaName = 'administracao';

  // /// nome da tabela
  // static const String tableName = 'cadastro';

  // /// nome da tabela totalmente qualificado
  // static const String fqtn = '$schemaName.$tableName';

  /// int4 not null key
  int codModulo;

  /// int4 not null key
  int codCadastro;

  /// varchar 80 null
  String nomCadastro;

  /// varchar 80 null
  String mapeamento;

  Cadastro({
    required this.codModulo,
    required this.codCadastro,
    required this.nomCadastro,
    required this.mapeamento,
  });

  Cadastro copyWith({
    int? codModulo,
    int? codCadastro,
    String? nomCadastro,
    String? mapeamento,
  }) {
    return Cadastro(
      codModulo: codModulo ?? this.codModulo,
      codCadastro: codCadastro ?? this.codCadastro,
      nomCadastro: nomCadastro ?? this.nomCadastro,
      mapeamento: mapeamento ?? this.mapeamento,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_cadastro': codCadastro,
      'nom_cadastro': nomCadastro,
      'mapeamento': mapeamento,
    };
  }

  factory Cadastro.fromMap(Map<String, dynamic> map) {
    return Cadastro(
      codModulo: map['cod_modulo'] as int,
      codCadastro: map['cod_cadastro'] as int,
      nomCadastro: map['nom_cadastro'] as String,
      mapeamento: map['mapeamento'] as String,
    );
  }

  @override
  String toString() {
    return 'Cadastro(codModulo: $codModulo, codCadastro: $codCadastro, nomCadastro: $nomCadastro, mapeamento: $mapeamento)';
  }

  @override
  bool operator ==(covariant Cadastro other) {
    if (identical(this, other)) return true;

    return other.codModulo == codModulo && other.codCadastro == codCadastro;
  }

  @override
  int get hashCode {
    return codModulo.hashCode ^ codCadastro.hashCode;
  }
}
