import 'package:new_sali_core/new_sali_core.dart';

/// documento (exigencia de documento vinculado a assunto de processo)
/// tipo de documento que pode estar anexado ao processo
/// sw_documento
class Documento implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_documento';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// int4 primary key not null
  int codDocumento;

  /// varchar 60 not null
  String nomDocumento;

  /// propriedade anexada de sw_documento_assunto
  int? codClassificacao;

  /// propriedade anexada de sw_documento_assunto
  int? codAssunto;

  /// propriedade anexada de sw_documento_processo
  int? codProcesso;

  /// propriedade anexada de sw_documento_processo
  String? anoExercicio;

  Documento({
    required this.codDocumento,
    required this.nomDocumento,
  });

  /// cria uma instancia preenchida com dados invalidos
  factory Documento.invalido() {
    return Documento(codDocumento: -1, nomDocumento: '');
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_documento': codDocumento,
      'nom_documento': nomDocumento,
    };
    if (codClassificacao != null) {
      map['cod_classificacao'] = codClassificacao;
    }
    if (codAssunto != null) {
      map['cod_assunto'] = codAssunto;
    }

    if (codProcesso != null) {
      map['cod_processo'] = codProcesso;
    }
    if (anoExercicio != null) {
      map['exercicio'] = anoExercicio;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('cod_classificacao')
      ..remove('cod_assunto')
      ..remove('cod_processo')
      ..remove('exercicio');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cod_documento')
      ..remove('cod_classificacao')
      ..remove('cod_assunto')
      ..remove('cod_processo')
      ..remove('exercicio');
  }

  factory Documento.fromMap(Map<String, dynamic> map) {
    var doc = Documento(
      codDocumento: map['cod_documento'],
      nomDocumento: map['nom_documento'],
    );
    if (map.containsKey('cod_classificacao')) {
      doc.codClassificacao = map['cod_classificacao'];
    }
    if (map.containsKey('cod_assunto')) {
      doc.codAssunto = map['cod_assunto'];
    }
    if (map.containsKey('cod_processo')) {
      doc.codProcesso = map['cod_processo'];
    }
    if (map.containsKey('exercicio')) {
      doc.anoExercicio = map['exercicio'];
    }

    return doc;
  }

  @override
  bool operator ==(covariant Documento other) {
    if (identical(this, other)) return true;
    return other.codDocumento == codDocumento;
  }

  @override
  int get hashCode {
    return codDocumento.hashCode;
  }
}
