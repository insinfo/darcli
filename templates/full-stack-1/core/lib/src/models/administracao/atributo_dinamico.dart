import 'package:new_sali_core/new_sali_core.dart';

/// define um AtributoDinamico (campo de formulario)
class AtributoDinamico implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'administracao';

  /// nome da tabela
  static const String tableName = 'atributo_dinamico';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// int4 not null key
  int codModulo;

  /// int4 not null key
  int codCadastro;

  /// int4 not null key
  int codAtributo;

  /// int4 not null
  int codTipo;

  /// bool
  /// Atributo Obrigatorio se naoNulo == false
  bool naoNulo;

  /// varchar 80
  String nomAtributo;

  ///  text
  String? valorPadrao;

  /// varchar 80
  String? ajuda;

  /// varchar 40
  String? mascara;

  bool ativo;

  bool? interno;

  bool indexavel;

  /// propriedade anexada
  String? nomTipo;

  /// propriedade anexada
  String? descricao;

  /// propriedade anexada
  List<AtributoValorPadrao> valoresPadrao = [];

  /// propriedade anexada
  String? valor;

  AtributoDinamico({
    required this.codModulo,
    required this.codCadastro,
    required this.codAtributo,
    required this.codTipo,
    required this.naoNulo,
    required this.nomAtributo,
    this.valorPadrao,
    this.ajuda,
    this.mascara,
    required this.ativo,
    this.interno,
    required this.indexavel,
  });

  AtributoDinamico copyWith({
    int? codModulo,
    int? codCadastro,
    int? codAtributo,
    int? codTipo,
    bool? naoNulo,
    String? nomAtributo,
    String? valorPadrao,
    String? ajuda,
    String? mascara,
    bool? ativo,
    bool? interno,
    bool? indexavel,
  }) {
    return AtributoDinamico(
      codModulo: codModulo ?? this.codModulo,
      codCadastro: codCadastro ?? this.codCadastro,
      codAtributo: codAtributo ?? this.codAtributo,
      codTipo: codTipo ?? this.codTipo,
      naoNulo: naoNulo ?? this.naoNulo,
      nomAtributo: nomAtributo ?? this.nomAtributo,
      valorPadrao: valorPadrao ?? this.valorPadrao,
      ajuda: ajuda ?? this.ajuda,
      mascara: mascara ?? this.mascara,
      ativo: ativo ?? this.ativo,
      interno: interno ?? this.interno,
      indexavel: indexavel ?? this.indexavel,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_cadastro': codCadastro,
      'cod_atributo': codAtributo,
      'cod_tipo': codTipo,
      'nao_nulo': naoNulo,
      'nom_atributo': nomAtributo,
      'valor_padrao': valorPadrao,
      'ajuda': ajuda,
      'mascara': mascara,
      'ativo': ativo,
      'interno': interno,
      'indexavel': indexavel,
    };
    if (nomTipo != null) {
      map['nom_tipo'] = nomTipo;
    }
    if (descricao != null) {
      map['descricao'] = descricao;
    }
    if (valoresPadrao.isNotEmpty) {
      map['valores_padrao'] = valoresPadrao.map((e) => e.toMap()).toList();
    }
    if (valor != null) {
      map['valor'] = valor;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('nom_tipo')
      ..remove('descricao')
      ..remove('valores_padrao')
      ..remove('valor');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('nom_tipo')
      ..remove('descricao')
      ..remove('valores_padrao')
      ..remove('valor');
  }

  factory AtributoDinamico.fromMap(Map<String, dynamic> map) {
    final atd = AtributoDinamico(
      codModulo: map['cod_modulo'],
      codCadastro: map['cod_cadastro'] as int,
      codAtributo: map['cod_atributo'] as int,
      codTipo: map['cod_tipo'] as int,
      naoNulo: map['nao_nulo'] as bool,
      nomAtributo: map['nom_atributo'] as String,
      valorPadrao: map['valor_padrao'],
      ajuda: map['ajuda'],
      mascara: map['mascara'],
      ativo: map['ativo'] as bool,
      interno: map['interno'],
      indexavel: map['indexavel'] as bool,
    );
    if (map.containsKey('nom_tipo')) {
      atd.nomTipo = map['nom_tipo'];
    }
    if (map.containsKey('descricao')) {
      atd.descricao = map['descricao'];
    }
    if (map.containsKey('valores_padrao')) {
      if (map['valores_padrao'] is List<AtributoValorPadrao>) {
        atd.valoresPadrao = map['valores_padrao'];
      } else if (map['valores_padrao'] is List<dynamic>)
        atd.valoresPadrao = (map['valores_padrao'] as List)
            .map((m) => AtributoValorPadrao.fromMap(m))
            .toList();
    }
    if (map.containsKey('valor')) {
      atd.valor = map['valor'];
    }

    return atd;
  }

  @override
  String toString() {
    return 'AtributoDinamico(cod_modulo: $codModulo, cod_cadastro: $codCadastro, cod_atributo: $codAtributo, cod_tipo: $codTipo, nao_nulo: $naoNulo, nom_atributo: $nomAtributo, valor_padrao: $valorPadrao, ajuda: $ajuda, mascara: $mascara, ativo: $ativo, interno: $interno, indexavel: $indexavel)';
  }

  @override
  bool operator ==(covariant AtributoDinamico other) {
    if (identical(this, other)) return true;
    return other.codModulo == codModulo &&
        other.codCadastro == codCadastro &&
        other.codAtributo == codAtributo;
  }

  @override
  int get hashCode {
    return codModulo.hashCode ^ codCadastro.hashCode ^ codAtributo.hashCode;
  }
}
