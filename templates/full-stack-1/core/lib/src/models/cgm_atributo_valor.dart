import 'package:new_sali_core/new_sali_core.dart';

class CgmAtributoValor implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_cgm_atributo_valor';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int numCgm;
  int codAtributo;
  String valor;

  CgmAtributoValor({
    required this.numCgm,
    required this.codAtributo,
    required this.valor,
  });

  CgmAtributoValor copyWith({
    int? numcgm,
    int? cod_atributo,
    String? valor,
  }) {
    return CgmAtributoValor(
      numCgm: numcgm ?? this.numCgm,
      codAtributo: cod_atributo ?? this.codAtributo,
      valor: valor ?? this.valor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'numcgm': numCgm,
      'cod_atributo': codAtributo,
      'valor': valor,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('numcgm')
      ..remove('cod_atributo');
  }

  factory CgmAtributoValor.fromMap(Map<String, dynamic> map) {
    return CgmAtributoValor(
      numCgm: map['numcgm'] as int,
      codAtributo: map['cod_atributo'] as int,
      valor: map['valor'] as String,
    );
  }

  @override
  String toString() =>
      'CgmAtributoValor(numcgm: $numCgm, cod_atributo: $codAtributo, valor: $valor)';

  @override
  bool operator ==(covariant CgmAtributoValor other) {
    if (identical(this, other)) return true;

    return other.numCgm == numCgm && other.codAtributo == codAtributo;
  }

  @override
  int get hashCode => numCgm.hashCode ^ codAtributo.hashCode;
}
