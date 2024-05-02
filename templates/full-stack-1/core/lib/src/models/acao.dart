import 'package:new_sali_core/new_sali_core.dart';

/// Exempl: Ação 57 = Incluir Processo
class Acao implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'acao';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// id not null
  int codAcao;

  /// not null
  int codFuncionalidade;

  /// not null
  String nomArquivo;

  /// not null
  /// Exemplo: exportar | reemitir | consultar | alterar | incluir | excluir
  String parametro;

  /// not null
  int ordem;

  /// anulavel
  String? complementoAcao;

  /// not null
  String nomAcao;

  /// anulavel não | null
  String? habilitada;

  /// propriedade anexada vem da tabela de ligação assunto_acao
  int? codAssunto;
  int? codClassificacao;

  Acao({
    required this.codAcao,
    required this.codFuncionalidade,
    required this.nomArquivo,
    required this.parametro,
    required this.ordem,
    this.complementoAcao,
    required this.nomAcao,
    this.habilitada,
  });

  factory Acao.invalid() {
    return Acao(
      codAcao: -1,
      codFuncionalidade: -1,
      nomArquivo: '',
      parametro: '',
      ordem: 1,
      nomAcao: '',
      habilitada: null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_acao': codAcao,
      'cod_funcionalidade': codFuncionalidade,
      'nom_arquivo': nomArquivo,
      'parametro': parametro,
      'ordem': ordem,
      'complemento_acao': complementoAcao,
      'nom_acao': nomAcao,
      'habilitada': habilitada,
    };

    if (codAssunto != null) {
      map['cod_assunto'] = codAssunto;
    }
    if (codClassificacao != null) {
      map['cod_classificacao'] = codClassificacao;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('cod_assunto')
      ..remove('cod_classificacao');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cod_acao')
      ..remove('cod_assunto')
      ..remove('cod_classificacao');
  }

  Acao copyWith({
    int? cod_acao,
    int? cod_funcionalidade,
    String? nom_arquivo,
    String? parametro,
    int? ordem,
    String? complemento_acao,
    String? nom_acao,
    String? habilitada,
  }) {
    return Acao(
      codAcao: cod_acao ?? this.codAcao,
      codFuncionalidade: cod_funcionalidade ?? this.codFuncionalidade,
      nomArquivo: nom_arquivo ?? this.nomArquivo,
      parametro: parametro ?? this.parametro,
      ordem: ordem ?? this.ordem,
      complementoAcao: complemento_acao ?? this.complementoAcao,
      nomAcao: nom_acao ?? this.nomAcao,
      habilitada: habilitada ?? this.habilitada,
    );
  }

  factory Acao.fromMap(Map<String, dynamic> map) {
    var acao = Acao(
      codAcao: map['cod_acao'] as int,
      codFuncionalidade: map['cod_funcionalidade'] as int,
      nomArquivo: map['nom_arquivo'] as String,
      parametro: map['parametro'] as String,
      ordem: map['ordem'] as int,
      complementoAcao: map['complemento_acao'] != null
          ? map['complemento_acao'] as String
          : null,
      nomAcao: map['nom_acao'] as String,
      habilitada:
          map['habilitada'] != null ? map['habilitada'] as String : null,
    );
    if (map.containsKey('cod_assunto')) {
      acao.codAssunto = map['cod_assunto'];
    }
    if (map.containsKey('cod_classificacao')) {
      acao.codClassificacao = map['cod_classificacao'];
    }
    return acao;
  }

  @override
  String toString() {
    return 'Acao(cod_acao: $codAcao, cod_funcionalidade: $codFuncionalidade, nom_arquivo: $nomArquivo, parametro: $parametro, ordem: $ordem, complemento_acao: $complementoAcao, nom_acao: $nomAcao, habilitada: $habilitada)';
  }

  @override
  bool operator ==(covariant Acao other) {
    if (identical(this, other)) return true;
    return other.codAcao == codAcao;
  }

  @override
  int get hashCode {
    return codAcao.hashCode;
  }
}
