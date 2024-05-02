// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';
/// 2	mascara_setor	99.999.999.999/9999
class Configuracao implements BaseModel {

  static const String schemaName = 'administracao';
  static const String tableName = 'configuracao';

  String exercicio;
  int codModulo;
  /// ex: tipo_numeracao_processo | mascara_setor 
  String parametro;
  String valor;

  Configuracao({
    required this.exercicio,
    required this.codModulo,
    required this.parametro,
    required this.valor,
  });

  Configuracao copyWith({
    String? exercicio,
    int? codModulo,
    String? parametro,
    String? valor,
  }) {
    return Configuracao(
      exercicio: exercicio ?? this.exercicio,
      codModulo: codModulo ?? this.codModulo,
      parametro: parametro ?? this.parametro,
      valor: valor ?? this.valor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exercicio': exercicio,
      'cod_modulo': codModulo,
      'parametro': parametro,
      'valor': valor,
    };
  }

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      exercicio: map['exercicio'] as String,
      codModulo: map['cod_modulo'] as int,
      parametro: map['parametro'] as String,
      valor: map['valor'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Configuracao.fromJson(String source) =>
      Configuracao.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Configuracao(exercicio: $exercicio, cod_modulo: $codModulo, parametro: $parametro, valor: $valor)';
  }

  @override
  bool operator ==(covariant Configuracao other) {
    if (identical(this, other)) return true;

    return other.exercicio == exercicio &&
        other.codModulo == codModulo &&
        other.parametro == parametro;
  }

  @override
  int get hashCode {
    return exercicio.hashCode ^ codModulo.hashCode ^ parametro.hashCode;
  }
}
