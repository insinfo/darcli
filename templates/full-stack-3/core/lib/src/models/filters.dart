import 'dart:collection';
import 'dart:convert';

import 'package:sibem_core/core.dart';

class FilterSearchField {
  String label;

  /// campo da tabela
  String field;
  bool active;
  String operator;

  FilterSearchField(
      {required this.label,
      required this.field,
      this.active = false,
      this.operator = '='});

  factory FilterSearchField.fromMap(Map<String, dynamic> map) {
    return FilterSearchField(
      label: map['label'],
      field: map['field'],
      active: map['active'],
      operator: map['operator'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'field': field,
      'active': active,
      'operator': operator,
    };
  }
}

class Filters {
  int? limit = 12;
  int? offset = 0;

  String? searchString;
  List<FilterSearchField> searchInFields = [];

  String? orderBy;
  String? orderDir = 'desc';
  Map<String, String> additionalParams = {};
  List<Filter> additionalFilters = [];

  /// pode ser usado para filtrar candidatos encaminhados para um empregador
  int? idEmpregador;
  int? idCargo;

  bool? ativo;
  bool? bloqueioEncaminhamento;
  int? codCnae;

  int? idCidade;
  int? idPais;

  /// filtro para tela de listagem de Candidatos WEB
  bool? isValidado;

  /// Empregador Status de Validação
  String? statusValidacao;

  String? statusEncaminhamento;

  /// para filtrar vaga compativel com um Candidato com o cpf informado
  String? cpfCandidato;

  /// filtrar candidatos que coincidem com a vaga
  int? idVaga;

  /// filtrar candidatos que Coincidir com Cargo
  bool? matchCargo;

  /// filtrar candidatos que Coincidir com escolaridade
  bool? matchEscolaridade;

  /// filtrar candidatos que Coincidir com Fumante
  bool? matchFumante;

  /// filtrar candidatos que Coincidir com Experiencia
  bool? matchExperiencia;

  /// filtrar candidatos que Coincidir com a idade exigida
  bool? matchIdade;

  /// filtrar candidatos que Coincidir com Curso obrigatorios
  bool? matchCurso;

  /// filtrar candidatos que Coincidir com Sexo exigido
  bool? matchSexo;

  /// filtrar candidatos que são PCDs ou PNE
  bool? matchPcd;

  /// filtrar candidatos que Coincidir com Genero exigido (identidade de Genero)
  bool? matchGenero;

  /// filtrar candidatos que Coincidir com Conhecimentos Extras
  bool? matchConhecimentosExtras;

  /// filtrar candidatos que tem o seu cadastro valido ou seja a data de atualização/cadastro não inferior a um ano atraz
  bool? matchValidadeCadastro;

  void addSearchInField(FilterSearchField filterSearchField) {
    searchInFields.add(filterSearchField);
  }

  bool? forceRefresh;

  /// propriedade anexada somente para tela candidato
  String? nomeVaga;

  Filters({
    this.limit = 12,
    this.offset = 0,
    this.searchString,
    this.orderBy,
    this.orderDir = 'desc',
    this.idEmpregador,
    this.idCargo,
    this.idVaga,
    this.ativo,
    this.codCnae,
    this.idCidade,
    this.idPais,
    this.bloqueioEncaminhamento,
    this.isValidado,
    this.cpfCandidato,
    this.forceRefresh,
    this.matchCargo,
    this.matchEscolaridade,
    this.matchFumante,
    this.matchExperiencia,
    this.matchIdade,
    this.matchCurso,
    this.matchSexo,
    this.matchPcd,
    this.matchGenero,
    this.matchConhecimentosExtras,
    this.matchValidadeCadastro,
    this.statusValidacao,
    this.statusEncaminhamento,
  });

  bool get isOrder => orderBy != null;
  bool get isSearch => searchString != null && searchString?.trim() != '';

  bool get isLimit => limit != null;
  bool get isOffset => offset != null;

  Filters.fromMap(Map<String, dynamic> map) {
    fillFromMap(map);
  }

  final _defaultParams = [
    'limit',
    'offset',
    'search',
    'orderBy',
    'orderDir',
    'additionalFilters'
  ];

  void fillFromFilters(Filters filters) {
    limit = filters.limit;
    offset = filters.offset;
    searchString = filters.searchString;
    orderBy = filters.orderBy;
    orderDir = filters.orderDir;
    searchInFields = filters.searchInFields;
    additionalParams = filters.additionalParams;
    additionalFilters = filters.additionalFilters;
  }

  dynamic getAdditionalParamByName(String name) {
    for (var pa in additionalParams.entries) {
      if (pa.key == name) {
        return pa.value;
      }
    }
  }

  void fillFromMap(Map<String, dynamic> map) {
    if (map.containsKey('limit') && map['limit'] != null) {
      limit = int.tryParse(map['limit'].toString());
    }
    if (map.containsKey('offset') && map['offset'] != null) {
      offset = int.tryParse(map['offset'].toString());
    }
    if (map.containsKey('search') && map['search'] != null) {
      searchString = map['search'];
    }
    if (map.containsKey('orderBy') && map['orderBy'] != null) {
      orderBy = map['orderBy'];
    }
    if (map.containsKey('orderDir') && map['orderDir'] != null) {
      orderDir = map['orderDir'];
    }
    if (map.containsKey('idEmpregador') && map['idEmpregador'] != null) {
      idEmpregador = int.tryParse(map['idEmpregador'].toString());
    }
    if (map.containsKey('idCargo') && map['idCargo'] != null) {
      idCargo = int.tryParse(map['idCargo'].toString());
    }
    if (map.containsKey('idVaga') && map['idVaga'] != null) {
      idVaga = int.tryParse(map['idVaga'].toString());
    }
    if (map.containsKey('ativo') && map['ativo'] != null) {
      ativo = map['ativo'].toString() == 'true';
    }
    if (map.containsKey('bloqueioEncaminhamento') &&
        map['bloqueioEncaminhamento'] != null) {
      bloqueioEncaminhamento =
          map['bloqueioEncaminhamento'].toString() == 'true';
    }

    if (map.containsKey('codCnae') && map['codCnae'] != null) {
      codCnae = int.tryParse(map['codCnae'].toString());
    }

    if (map.containsKey('idCidade') && map['idCidade'] != null) {
      idCidade = int.tryParse(map['idCidade'].toString());
    }
    if (map.containsKey('idPais') && map['idPais'] != null) {
      idPais = int.tryParse(map['idPais'].toString());
    }
    if (map.containsKey('isValidado')) {
      isValidado = map['isValidado'].toString() == 'true';
    }
    if (map.containsKey('cpfCandidato')) {
      cpfCandidato = map['cpfCandidato'];
    }
    if (map.containsKey('forceRefresh')) {
      forceRefresh = map['forceRefresh'].toString() == 'true';
    }

    if (map.containsKey('matchCargo')) {
      matchCargo = map['matchCargo'].toString() == 'true';
    }
    if (map.containsKey('matchEscolaridade')) {
      matchEscolaridade = map['matchEscolaridade'].toString() == 'true';
    }
    if (map.containsKey('matchFumante')) {
      matchFumante = map['matchFumante'].toString() == 'true';
    }
    if (map.containsKey('matchExperiencia')) {
      matchExperiencia = map['matchExperiencia'].toString() == 'true';
    }
    if (map.containsKey('matchIdade')) {
      matchIdade = map['matchIdade'].toString() == 'true';
    }
    if (map.containsKey('matchCurso')) {
      matchCurso = map['matchCurso'].toString() == 'true';
    }
    if (map.containsKey('matchSexo')) {
      matchSexo = map['matchSexo'].toString() == 'true';
    }
    if (map.containsKey('matchPcd')) {
      matchPcd = map['matchPcd'].toString() == 'true';
    }
    if (map.containsKey('matchGenero')) {
      matchGenero = map['matchGenero'].toString() == 'true';
    }
    if (map.containsKey('matchConhecimentosExtras')) {
      matchConhecimentosExtras =
          map['matchConhecimentosExtras'].toString() == 'true';
    }
    if (map.containsKey('matchValidadeCadastro')) {
      matchValidadeCadastro = map['matchValidadeCadastro'].toString() == 'true';
    }
    if (map.containsKey('statusValidacao')) {
      statusValidacao = map['statusValidacao'];
    }
    if (map.containsKey('statusEncaminhamento')) {
      statusEncaminhamento = map['statusEncaminhamento'];
    }

    if (map.containsKey('searchInFields')) {
      if (map['searchInFields'] is String) {
        final json = jsonDecode(map['searchInFields']) as List;
        searchInFields = json.map((e) => FilterSearchField.fromMap(e)).toList();
      } else if (map['searchInFields'] is List<FilterSearchField>) {
        searchInFields = map['searchInFields'];
      } else if (map['searchInFields']
          is List<LinkedHashMap<String, dynamic>>) {
        searchInFields = map['searchInFields']
            .map((e) => FilterSearchField.fromMap(e))
            .toList();
      } else if (map['searchInFields'] is List<Map<String, dynamic>>) {
        searchInFields = map['searchInFields']
            .map((e) => FilterSearchField.fromMap(e))
            .toList();
      }
    }

    map.forEach((key, value) {
      if (!_defaultParams.contains(key)) {
        additionalParams.addAll({key: value});
      }
    });

    if (map.containsKey('additionalFilters')) {
      if (map['additionalFilters'] is String) {
        var json = jsonDecode(map['additionalFilters']) as List;
        additionalFilters = json.map((e) => Filter.fromMap(e)).toList();
      } else if (map['additionalFilters'] is List<Filter>) {
        additionalFilters = map['additionalFilters'];
      } else if (map['additionalFilters']
          is List<LinkedHashMap<String, dynamic>>) {
        additionalFilters =
            map['additionalFilters'].map((e) => Filter.fromMap(e)).toList();
      } else if (map['additionalFilters'] is List<Map<String, dynamic>>) {
        additionalFilters =
            map['additionalFilters'].map((e) => Filter.fromMap(e)).toList();
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['limit'] = limit;
    map['offset'] = offset;
    map['search'] = searchString;
    map['orderBy'] = orderBy;
    map['orderDir'] = orderDir;

    if (idEmpregador != null) {
      map['idEmpregador'] = idEmpregador;
    }
    if (idCargo != null) {
      map['idCargo'] = idCargo;
    }
    if (idVaga != null) {
      map['idVaga'] = idVaga;
    }
    if (ativo != null) {
      map['ativo'] = ativo;
    }
    if (bloqueioEncaminhamento != null) {
      map['bloqueioEncaminhamento'] = bloqueioEncaminhamento;
    }

    if (codCnae != null) {
      map['codCnae'] = codCnae;
    }

    if (idCidade != null) {
      map['idCidade'] = idCidade;
    }

    if (idPais != null) {
      map['idPais'] = idPais;
    }

    if (searchInFields.isNotEmpty) {
      map['searchInFields'] = searchInFields.map((e) => e.toMap()).toList();
    }
    if (additionalFilters.isNotEmpty) {
      map['additionalFilters'] =
          additionalFilters.map((e) => e.toMap()).toList();
    }
    if (isValidado != null) {
      map['isValidado'] = isValidado;
    }
    if (cpfCandidato != null) {
      map['cpfCandidato'] = cpfCandidato;
    }
    if (forceRefresh != null) {
      map['forceRefresh'] = forceRefresh;
    }
    if (matchEscolaridade != null) {
      map['matchEscolaridade'] = matchEscolaridade;
    }
    if (matchFumante != null) {
      map['matchFumante'] = matchFumante;
    }
    if (matchExperiencia != null) {
      map['matchExperiencia'] = matchExperiencia;
    }
    if (matchCargo != null) {
      map['matchCargo'] = matchCargo;
    }
    if (matchIdade != null) {
      map['matchIdade'] = matchIdade;
    }
    if (matchCurso != null) {
      map['matchCurso'] = matchCurso;
    }
    if (matchSexo != null) {
      map['matchSexo'] = matchSexo;
    }
    if (matchPcd != null) {
      map['matchPcd'] = matchPcd;
    }
    if (matchGenero != null) {
      map['matchGenero'] = matchGenero;
    }
    if (matchConhecimentosExtras != null) {
      map['matchConhecimentosExtras'] = matchConhecimentosExtras;
    }
    if (matchValidadeCadastro != null) {
      map['matchValidadeCadastro'] = matchValidadeCadastro;
    }
    if (statusValidacao != null) {
      map['statusValidacao'] = statusValidacao;
    }
    if (statusEncaminhamento != null) {
      map['statusEncaminhamento'] = statusEncaminhamento;
    }

    return map;
  }

  void reset({
    bool clearAdditionalParams = true,
    bool clearAdditionalFilters = true,
    bool clearSearchInFields = false,
  }) {
    limit = 12;
    offset = 0;
    searchString = null;
    orderBy = null;
    orderDir = 'desc';
    if (clearAdditionalParams) {
      additionalParams = {};
    }
    if (clearAdditionalFilters) {
      additionalFilters = [];
    }
    if (clearSearchInFields) {
      searchInFields = [];
    }
    codCnae = null;
  }

  Map<String, String> getParams() {
    var stringParams = <String, String>{};
    if (additionalParams.isNotEmpty == true) {
      stringParams.addAll(additionalParams);
    }
    if (limit != null) {
      stringParams['limit'] = limit.toString();
    }
    if (offset != null) {
      stringParams['offset'] = offset.toString();
    }
    if (searchString != null) {
      stringParams['search'] = searchString!;
    }
    if (orderBy != null) {
      stringParams['orderBy'] = orderBy!;
    }
    if (orderDir != null) {
      stringParams['orderDir'] = orderDir!;
    }
    if (idEmpregador != null) {
      stringParams['idEmpregador'] = idEmpregador.toString();
    }
    if (idCargo != null) {
      stringParams['idCargo'] = idCargo.toString();
    }
    if (idVaga != null) {
      stringParams['idVaga'] = idVaga.toString();
    }
    if (ativo != null) {
      stringParams['ativo'] = ativo.toString();
    }
    if (bloqueioEncaminhamento != null) {
      stringParams['bloqueioEncaminhamento'] =
          bloqueioEncaminhamento.toString();
    }

    if (codCnae != null) {
      stringParams['codCnae'] = codCnae.toString();
    }
    if (idCidade != null) {
      stringParams['idCidade'] = idCidade.toString();
    }

    if (additionalFilters.isNotEmpty == true) {
      stringParams['additionalFilters'] =
          jsonEncode(additionalFilters.map((e) => e.toMap()).toList());
    }

    if (searchInFields.isNotEmpty == true) {
      stringParams['searchInFields'] =
          jsonEncode(searchInFields.map((e) => e.toMap()).toList());
    }

    if (isValidado != null) {
      stringParams['isValidado'] = isValidado.toString();
    }

    if (cpfCandidato != null) {
      stringParams['cpfCandidato'] = cpfCandidato.toString();
    }

    if (forceRefresh != null) {
      stringParams['forceRefresh'] = forceRefresh.toString();
    }
    if (matchEscolaridade != null) {
      stringParams['matchEscolaridade'] = matchEscolaridade.toString();
    }
    if (matchFumante != null) {
      stringParams['matchFumante'] = matchFumante.toString();
    }
    if (matchExperiencia != null) {
      stringParams['matchExperiencia'] = matchExperiencia.toString();
    }
    if (matchCargo != null) {
      stringParams['matchCargo'] = matchCargo.toString();
    }
    if (matchIdade != null) {
      stringParams['matchIdade'] = matchIdade.toString();
    }
    if (matchCurso != null) {
      stringParams['matchCurso'] = matchCurso.toString();
    }
    if (matchSexo != null) {
      stringParams['matchSexo'] = matchSexo.toString();
    }
    if (matchPcd != null) {
      stringParams['matchPcd'] = matchPcd.toString();
    }
    if (matchGenero != null) {
      stringParams['matchGenero'] = matchGenero.toString();
    }
    if (matchConhecimentosExtras != null) {
      stringParams['matchConhecimentosExtras'] =
          matchConhecimentosExtras.toString();
    }
    if (matchValidadeCadastro != null) {
      stringParams['matchValidadeCadastro'] = matchValidadeCadastro.toString();
    }
    if (statusValidacao != null) {
      stringParams['statusValidacao'] = statusValidacao!;
    }
    if (statusEncaminhamento != null) {
      stringParams['statusEncaminhamento'] = statusEncaminhamento!;
    }

    return stringParams;
  }
}
