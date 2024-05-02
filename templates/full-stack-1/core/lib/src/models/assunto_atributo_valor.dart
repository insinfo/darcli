import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
//sw_assunto_atributo_valor
class AssuntoAtributoValor implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_assunto_atributo_valor';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codAtributo;
  int codAssunto;
  int codClassificacao;
  int codProcesso;
  String anoExercicio;
  String valor;

  //propriedade anexada
  String? nomAtributo;
  String? tipo;
  String? valorPadrao;

  AssuntoAtributoValor({
    required this.codAtributo,
    required this.codAssunto,
    required this.codClassificacao,
    required this.codProcesso,
    required this.anoExercicio,
    required this.valor,
    this.nomAtributo,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_atributo': codAtributo,
      'cod_assunto': codAssunto,
      'cod_classificacao': codClassificacao,
      'cod_processo': codProcesso,
      'exercicio': anoExercicio,
      'valor': valor,
    };

    if (nomAtributo != null) {
      map['nom_atributo'] = nomAtributo;
    }
    if (tipo != null) {
      map['tipo'] = tipo;
    }
    if (valorPadrao != null) {
      map['valor_padrao'] = valorPadrao;
    }
    return map;
  }

  factory AssuntoAtributoValor.fromMap(Map<String, dynamic> map) {
    var aav = AssuntoAtributoValor(
      codAtributo: map['cod_atributo'] as int,
      codAssunto: map['cod_assunto'] as int,
      codClassificacao: map['cod_classificacao'] as int,
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['exercicio'] as String,
      valor: map['valor'] as String,
    );
    if (map.containsKey('nom_atributo')) {
      aav.nomAtributo = map['nom_atributo'];
    }
    if (map.containsKey('tipo')) {
      aav.tipo = map['tipo'];
    }
    if (map.containsKey('valor_padrao')) {
      aav.valorPadrao = map['valor_padrao'];
    }

    return aav;
  }

  String toJson() => json.encode(toMap());

  factory AssuntoAtributoValor.fromJson(String source) =>
      AssuntoAtributoValor.fromMap(json.decode(source) as Map<String, dynamic>);
}
