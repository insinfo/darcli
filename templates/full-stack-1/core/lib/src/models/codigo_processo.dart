import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CodigoProcesso implements BaseModel {
  int codProcesso;
  String anoExercicio;
  int? codUltimoAndamento;

  CodigoProcesso({
    required this.codProcesso,
    required this.anoExercicio,
    this.codUltimoAndamento,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'codProcesso': codProcesso,
      'anoExercicio': anoExercicio,
      'cod_ultimo_andamento': codUltimoAndamento,
    };
  }

  factory CodigoProcesso.fromMap(Map<String, dynamic> map) {
    return CodigoProcesso(
      codProcesso: map['codProcesso'] as int,
      anoExercicio: map['anoExercicio'] as String,
      codUltimoAndamento: map['cod_ultimo_andamento'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory CodigoProcesso.fromJson(String source) =>
      CodigoProcesso.fromMap(json.decode(source) as Map<String, dynamic>);

  /// retorna codigo/ano
  String get codigoFormatado => '${codProcesso}/${anoExercicio}';
}
