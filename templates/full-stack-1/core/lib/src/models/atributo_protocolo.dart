import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
//sw_atributo_protocolo
class AtributoProtocolo implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_atributo_protocolo';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codAtributo;
  String nomAtributo;

  /// t=testo | l=lista | n=numero
  String tipo;
  String valorPadrao;

  List<String> get valoresPadrao {
    if (tipo != 'l') {
      return <String>[];
    }
    if (valorPadrao.trim().isEmpty) {
      return <String>[];
    }

    final ls = LineSplitter();
    var items = ls.convert(valorPadrao);
    return items;
  }

  AtributoProtocolo(
      {required this.codAtributo,
      required this.nomAtributo,
      required this.tipo,
      required this.valorPadrao,
      this.codAssunto,
      this.codClassificacao});

  factory AtributoProtocolo.invalido() {
    return AtributoProtocolo(
        codAtributo: -1, nomAtributo: '', tipo: '', valorPadrao: '');
  }

//propriedades anexadas
  int? codAssunto;
  int? codClassificacao;
  int? codProcesso;
  String? anoExercicio;
  String? valor;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_atributo': codAtributo,
      'nom_atributo': nomAtributo,
      'tipo': tipo,
      'valor_padrao': valorPadrao,
    };
    if (codAssunto != null) {
      map['cod_assunto'] = codAssunto;
    }
    if (codClassificacao != null) {
      map['cod_classificacao'] = codClassificacao;
    }
    if (codProcesso != null) {
      map['cod_processo'] = codProcesso;
    }
    if (anoExercicio != null) {
      map['exercicio'] = anoExercicio;
    }
    if (valor != null) {
      map['valor'] = valor;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('cod_assunto')
      ..remove('cod_classificacao')
      ..remove('cod_processo')
      ..remove('exercicio')
      ..remove('valor');
  }

  Map<String, dynamic> toInsertAtributoValorMap() {
    var map = <String, dynamic>{
      'cod_atributo': codAtributo,
      'cod_assunto': codAssunto,
      'cod_classificacao': codClassificacao,
      'cod_processo': codProcesso,
      'exercicio': anoExercicio,
      'valor': valor,
    };

    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cod_assunto')
      ..remove('cod_classificacao')
      ..remove('cod_processo')
      ..remove('exercicio')
      ..remove('valor')
      ..remove('codAtributo');
  }

  factory AtributoProtocolo.fromMap(Map<String, dynamic> map) {
    var ap = AtributoProtocolo(
      codAtributo: map['cod_atributo'] as int,
      nomAtributo: map['nom_atributo'] as String,
      tipo: map['tipo'] as String,
      valorPadrao: map['valor_padrao'] as String,
      codAssunto: map['cod_assunto'],
      codClassificacao: map['cod_classificacao'],
    );
    if (map.containsKey('cod_assunto')) {
      ap.codAssunto = map['cod_assunto'];
    }
    if (map.containsKey('cod_classificacao')) {
      ap.codClassificacao = map['cod_classificacao'];
    }
    if (map.containsKey('cod_processo')) {
      ap.codProcesso = map['cod_processo'];
    }
    if (map.containsKey('exercicio')) {
      ap.anoExercicio = map['exercicio'];
    }
    if (map.containsKey('valor')) {
      ap.valor = map['valor'];
    }
    return ap;
  }

  @override
  bool operator ==(covariant AtributoProtocolo other) {
    if (identical(this, other)) return true;

    return other.codAtributo == codAtributo;
  }

  @override
  int get hashCode {
    return codAtributo.hashCode;
  }
}
