

import 'package:new_sali_core/new_sali_core.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
//sw_assunto_atributo
class AssuntoAtributo implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_assunto_atributo';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codAtributo;
  int codAssunto;
  int codClassificacao;

  //propriedade anexada
  int? codProcesso;
  String? anoExercicio;
  String? valor;

  AssuntoAtributo({
    required this.codAtributo,
    required this.codAssunto,
    required this.codClassificacao,
    this.codProcesso,
    this.anoExercicio,
    this.valor,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_atributo': codAtributo,
      'cod_assunto': codAssunto,
      'cod_classificacao': codClassificacao,
    };

    if (codProcesso != null) {
      map['cod_processo'] = codProcesso;
    }
    if (codProcesso != null) {
      map['ano_exercicio'] = anoExercicio;
    }
    if (valor != null) {
      map['valor'] = valor;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('cod_processo')
      ..remove('ano_exercicio')
      ..remove('valor');
  }

  factory AssuntoAtributo.fromMap(Map<String, dynamic> map) {
    var assA = AssuntoAtributo(
      codAtributo: map['cod_atributo'] as int,
      codAssunto: map['cod_assunto'] as int,
      codClassificacao: map['cod_classificacao'] as int,
    );

    if (map.containsKey('cod_processo')) {
      assA.codProcesso = map['cod_processo'];
    }
    if (map.containsKey('ano_exercicio')) {
      assA.anoExercicio = map['ano_exercicio'];
    }
    if (map.containsKey('valor')) {
      assA.valor = map['valor'];
    }
    return assA;
  }

  
}
