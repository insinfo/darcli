// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

/// CopiaDigital processo do Modulo Protocolo do Sali/Siamweb
class CopiaDigital implements BaseModel {

  static const String schemaName = 'public';
  static const String tableName = 'sw_copia_digital';
  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int codCopia;
  int codDocumento;
  int codProcesso;
  String exercicio;
  bool imagem;
  String anexo;

  CopiaDigital({
    required this.codCopia,
    required this.codDocumento,
    required this.codProcesso,
    required this.exercicio,
    required this.imagem,
    required this.anexo,
  });

  CopiaDigital copyWith({
    int? codCopia,
    int? codDocumento,
    int? codProcesso,
    String? exercicio,
    bool? imagem,
    String? anexo,
  }) {
    return CopiaDigital(
      codCopia: codCopia ?? this.codCopia,
      codDocumento: codDocumento ?? this.codDocumento,
      codProcesso: codProcesso ?? this.codProcesso,
      exercicio: exercicio ?? this.exercicio,
      imagem: imagem ?? this.imagem,
      anexo: anexo ?? this.anexo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_copia': codCopia,
      'cod_documento': codDocumento,
      'cod_processo': codProcesso,
      'exercicio': exercicio,
      'imagem': imagem,
      'anexo': anexo,
    };
  }

  factory CopiaDigital.fromMap(Map<String, dynamic> map) {
    return CopiaDigital(
      codCopia: map['cod_copia'] as int,
      codDocumento: map['cod_documento'] as int,
      codProcesso: map['cod_processo'] as int,
      exercicio: map['exercicio'] as String,
      imagem: map['imagem'] as bool,
      anexo: map['anexo'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CopiaDigital.fromJson(String source) =>
      CopiaDigital.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CopiaDigital(cod_copia: $codCopia, cod_documento: $codDocumento, cod_processo: $codProcesso, exercicio: $exercicio, imagem: $imagem, anexo: $anexo)';
  }

  @override
  bool operator ==(covariant CopiaDigital other) {
    if (identical(this, other)) return true;

    return other.codCopia == codCopia &&
        other.codDocumento == codDocumento &&
        other.codProcesso == codProcesso &&
        other.exercicio == exercicio &&
        other.imagem == imagem &&
        other.anexo == anexo;
  }

  @override
  int get hashCode {
    return codCopia.hashCode ^
        codDocumento.hashCode ^
        codProcesso.hashCode ^
        exercicio.hashCode ^
        imagem.hashCode ^
        anexo.hashCode;
  }
}
