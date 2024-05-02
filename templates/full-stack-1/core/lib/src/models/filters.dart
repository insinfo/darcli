// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';
import 'dart:convert';

import 'filter.dart';

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

  /// ano exercicio "0000" | "2003"
  String? anoExercicio;

  /// num_cgm
  int? codCgm;
  String? cpf;
  String? cnpj;
  int? codOrgao;
  int? codUnidade;
  int? codDepartamento;
  int? codSetor;

  /// para filtrar processo por id do setor origem
  int? idSetorOrigem;

  int? codClassificacao;
  int? codAssunto;
  int? codModulo;
  int? idListaProcessos;
  String? anoExercicioListaProcessos;
  int? codAndamento;
  String? tipoListagemProcessos;
  String? notAnoExercicio;
  int? notCodProcesso;
  int? codPais;
  int? codUf;
  bool? forceRefresh;
  int? codProcesso;

  /// pode ser assim: '${processo.codProcesso}${processo.anoExercicio}' ou '${processo.codProcesso}/${processo.anoExercicio}'
  String? codigoProcesso;

  /// para filtrar por Situação (1) Ativo | (0) Inativo
  String? situacao;

  /// remove processos apensados dos resultados
  bool? isNotProcessosComApenso;

  /// somente processos com apenso nos resultados
  bool? isOnlyProcessosComApenso;

  /// passa um Código	36962/2018 para mostrar somente os filhos dele
  String? onlyProcessosFilhoDe;

  // se true faz um join com a tabela orgaos e pega o ano_exercicio_orgao
  bool? isJoinOrgao;

  // se true faz um join com a tabela classificacao
  bool? isJoinClassificacao;
  // se true traz os AndamentoPadrao junto com assunto;
  bool? isGetAndamentoPadrao;

  /// codigo do usuario que rcebeu o processo
  /// para usar no filtro de processo
  ///  AND SW_ASSINATURA_DIGITAL.cod_usuario = 140050
  int? codUsuarioRecebeu;

  /// não trazer items desativados usado para não trazer setores inativos
  bool? removeDisabledItems;

  /// lista de ids para filtrar por Situação/Status de contrato
  List<dynamic> situacoes = [];

  DateTime? inicio;
  DateTime? fim;

  /// 	administracao.configuracao
  String? confParametro;

  String? searchString;
  List<FilterSearchField> searchInFields = [];

  String? orderBy;
  String? orderDir = 'desc';
  Map<String, String> additionalParams = {};
  List<Filter> additionalFilters = [];

  /// para Múltipla Seleção de Processos
  /// Example:  8112/2017, 40854/2018
  List<String> processos = [];

  int? codFuncionalidade;
  int? codGestao;
  /// para filtrar normas
  int? codTipoNorma;

  void addSearchInField(FilterSearchField filterSearchField) {
    searchInFields.add(filterSearchField);
  }

  /// verifica se codOrgao, codUnidade, codDepartamento, codSetor, anoExercicio são diferente de null
  /// ou seja se é pra filtrar por
  bool get isFilterBySetor =>
      codOrgao != null &&
      codOrgao != -1 &&
      codUnidade != null &&
      codUnidade != -1 &&
      codDepartamento != null &&
      codDepartamento != -1 &&
      codSetor != null &&
      codSetor != -1 &&
      anoExercicio != null &&
      anoExercicio != '' &&
      anoExercicio != '-1';

  Filters({
    this.limit = 12,
    this.offset = 0,
    this.searchString,
    this.orderBy,
    this.orderDir = 'desc',
    this.anoExercicio,
    this.codOrgao,
    this.codUnidade,
    this.codDepartamento,
    this.codSetor,
    this.idSetorOrigem,
    this.codClassificacao,
    this.codAssunto,
    this.codModulo,
    this.confParametro,
    this.codCgm,
    this.cpf,
    this.cnpj,
    this.inicio,
    this.fim,
    this.idListaProcessos,
    this.anoExercicioListaProcessos,
    this.codUsuarioRecebeu,
    this.codAndamento,
    this.isJoinOrgao,
    this.notAnoExercicio,
    this.notCodProcesso,
    this.isNotProcessosComApenso,
    this.isOnlyProcessosComApenso,
    this.onlyProcessosFilhoDe,
    this.tipoListagemProcessos,
    this.codPais,
    this.codUf,
    this.forceRefresh,
    this.isJoinClassificacao,
    this.isGetAndamentoPadrao,
    this.situacoes = const [],
    this.codProcesso,
    this.codigoProcesso,
    this.situacao,
    this.removeDisabledItems,
    this.codFuncionalidade,
    this.codGestao,
    this.codTipoNorma,
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

  String? getAdditionalParamByName(String name) {
    for (var pa in additionalParams.entries) {
      if (pa.key == name) {
        return pa.value;
      }
    }
    return null;
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
    if (map.containsKey('codOrgao')) {
      codOrgao = int.tryParse(map['codOrgao'].toString());
    }
    if (map.containsKey('codUnidade')) {
      codUnidade = int.tryParse(map['codUnidade'].toString());
    }
    if (map.containsKey('codDepartamento')) {
      codDepartamento = int.tryParse(map['codDepartamento'].toString());
    }
    if (map.containsKey('codSetor')) {
      codSetor = int.tryParse(map['codSetor'].toString());
    }
    if (map.containsKey('codFuncionalidade')) {
      codFuncionalidade = int.tryParse(map['codFuncionalidade'].toString());
    }
    if (map.containsKey('codGestao')) {
      codGestao = int.tryParse(map['codGestao'].toString());
    }

    if (map.containsKey('codTipoNorma')) {
      codTipoNorma = int.tryParse(map['codTipoNorma'].toString());
    }

    if (map.containsKey('idSetorOrigem')) {
      idSetorOrigem = int.tryParse(map['idSetorOrigem'].toString());
    }

    if (map.containsKey('codClassificacao')) {
      codClassificacao = int.tryParse(map['codClassificacao'].toString());
    }
    if (map.containsKey('codAssunto')) {
      codAssunto = int.tryParse(map['codAssunto'].toString());
    }
    if (map.containsKey('codModulo')) {
      codModulo = int.tryParse(map['codModulo'].toString());
    }
    if (map.containsKey('confParametro')) {
      confParametro = map['confParametro'];
    }
    if (map.containsKey('anoExercicio')) {
      anoExercicio = map['anoExercicio'];
    }
    if (map.containsKey('codCgm')) {
      codCgm = int.tryParse(map['codCgm'].toString());
    }

    if (map.containsKey('cpf')) {
      cpf = map['cpf'];
    }
    if (map.containsKey('cnpj')) {
      cnpj = map['cnpj'];
    }
    if (map.containsKey('processos')) {
      processos = map['processos'].toString().split(',');
    }
    if (map.containsKey('inicio')) {
      inicio = DateTime.tryParse(map['inicio'].toString());
    }
    if (map.containsKey('fim')) {
      fim = DateTime.tryParse(map['fim'].toString());
    }
    if (map.containsKey('idListaProcessos')) {
      idListaProcessos = int.tryParse(map['idListaProcessos'].toString());
    }
    if (map.containsKey('anoExercicioListaProcessos')) {
      anoExercicioListaProcessos = map['anoExercicioListaProcessos'].toString();
    }

    if (map.containsKey('codUsuarioRecebeu')) {
      codUsuarioRecebeu = int.tryParse(map['codUsuarioRecebeu'].toString());
    }
    if (map.containsKey('codAndamento')) {
      codAndamento = int.tryParse(map['codAndamento'].toString());
    }

    if (map.containsKey('isJoinOrgao') && map['isJoinOrgao'] != null) {
      isJoinOrgao = map['isJoinOrgao'].toString() == 'true';
    }
    if (map.containsKey('isJoinClassificacao') &&
        map['isJoinClassificacao'] != null) {
      isJoinClassificacao = map['isJoinClassificacao'].toString() == 'true';
    }

    if (map.containsKey('isGetAndamentoPadrao') &&
        map['isGetAndamentoPadrao'] != null) {
      isGetAndamentoPadrao = map['isGetAndamentoPadrao'].toString() == 'true';
    }

    if (map.containsKey('isNotProcessosComApenso') &&
        map['isNotProcessosComApenso'] != null) {
      isNotProcessosComApenso =
          map['isNotProcessosComApenso'].toString() == 'true';
    }
    if (map.containsKey('isOnlyProcessosComApenso') &&
        map['isOnlyProcessosComApenso'] != null) {
      isOnlyProcessosComApenso =
          map['isOnlyProcessosComApenso'].toString() == 'true';
    }

    if (map.containsKey('forceRefresh') && map['forceRefresh'] != null) {
      forceRefresh = map['forceRefresh'].toString() == 'true';
    }

    if (map.containsKey('notAnoExercicio')) {
      notAnoExercicio = map['notAnoExercicio'];
    }
    if (map.containsKey('notCodProcesso')) {
      notCodProcesso = int.tryParse(map['notCodProcesso'].toString());
    }

    if (map.containsKey('onlyProcessosFilhoDe')) {
      onlyProcessosFilhoDe = map['onlyProcessosFilhoDe'];
    }

    if (map.containsKey('tipoListagemProcessos')) {
      tipoListagemProcessos = map['tipoListagemProcessos'];
    }
    if (map.containsKey('codPais')) {
      codPais = int.tryParse(map['codPais'].toString());
    }
    if (map.containsKey('codUf')) {
      codUf = int.tryParse(map['codUf'].toString());
    }

    if (map.containsKey('codProcesso')) {
      codProcesso = int.tryParse(map['codProcesso'].toString());
    }
    if (map.containsKey('codigoProcesso')) {
      codigoProcesso = map['codigoProcesso'];
    }
    if (map.containsKey('situacao')) {
      situacao = map['situacao'];
    }

    if (map.containsKey('situacoes')) {
      situacoes = map['situacoes']
          .toString()
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }

    if (map.containsKey('searchInFields')) {
      if (map['searchInFields'] is String) {
        var json = jsonDecode(map['searchInFields']) as List;
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

    if (map.containsKey('removeDisabledItems') &&
        map['removeDisabledItems'] != null) {
      removeDisabledItems = map['removeDisabledItems'].toString() == 'true';
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    // if (limit != null) {
    map['limit'] = limit;
    // }
    // if (offset != null) {
    map['offset'] = offset;
    // }
    //if (searchString != null) {
    map['search'] = searchString;
    //}
    //if (orderBy!= null) {
    map['orderBy'] = orderBy;
    // }
    //if (orderDir != null) {
    map['orderDir'] = orderDir;
    //}

    //extras

    if (codOrgao != null) {
      map['codOrgao'] = codOrgao;
    }

    if (codUnidade != null) {
      map['codUnidade'] = codUnidade;
    }
    if (codDepartamento != null) {
      map['codDepartamento'] = codDepartamento;
    }
    if (codSetor != null) {
      map['codSetor'] = codSetor;
    }
    if (codFuncionalidade != null) {
      map['codFuncionalidade'] = codFuncionalidade;
    }
    if (codGestao != null) {
      map['codGestao'] = codGestao;
    }
    if (codTipoNorma != null) {
      map['codTipoNorma'] = codTipoNorma;
    }

    if (idSetorOrigem != null) {
      map['idSetorOrigem'] = idSetorOrigem;
    }

    if (codClassificacao != null) {
      map['codClassificacao'] = codClassificacao;
    }

    if (codAssunto != null) {
      map['codAssunto'] = codAssunto;
    }

    if (codModulo != null) {
      map['codModulo'] = codModulo;
    }
    if (confParametro != null) {
      map['confParametro'] = confParametro;
    }
    if (anoExercicio != null) {
      map['anoExercicio'] = anoExercicio;
    }

    if (codCgm != null) {
      map['codCgm'] = codCgm;
    }
    if (cpf != null) {
      map['cpf'] = cpf;
    }
    if (cnpj != null) {
      map['cnpj'] = cnpj;
    }

    if (searchInFields.isNotEmpty) {
      map['searchInFields'] = searchInFields.map((e) => e.toMap()).toList();
    }
    if (additionalFilters.isNotEmpty) {
      map['additionalFilters'] =
          additionalFilters.map((e) => e.toMap()).toList();
    }

    if (processos.isNotEmpty) {
      map['processos'] = processos.join(',');
    }

    if (situacoes.isNotEmpty) {
      map['situacoes'] = situacoes.join(',');
    }

    if (inicio != null) {
      map['inicio'] = inicio!.toIso8601String();
    }
    if (fim != null) {
      map['fim'] = fim!.toIso8601String();
    }

    if (idListaProcessos != null) {
      map['idListaProcessos'] = idListaProcessos.toString();
    }
    if (anoExercicioListaProcessos != null) {
      map['anoExercicioListaProcessos'] = anoExercicioListaProcessos;
    }
    if (codUsuarioRecebeu != null) {
      map['codUsuarioRecebeu'] = codUsuarioRecebeu;
    }
    if (codAndamento != null) {
      map['codAndamento'] = codAndamento;
    }
    if (isJoinOrgao != null) {
      map['isJoinOrgao'] = isJoinOrgao;
    }

    if (isJoinClassificacao != null) {
      map['isJoinClassificacao'] = isJoinClassificacao;
    }
    if (isGetAndamentoPadrao != null) {
      map['isGetAndamentoPadrao'] = isGetAndamentoPadrao;
    }

    if (isNotProcessosComApenso != null) {
      map['isNotProcessosComApenso'] = isNotProcessosComApenso;
    }

    if (forceRefresh != null) {
      map['forceRefresh'] = forceRefresh;
    }

    if (isOnlyProcessosComApenso != null) {
      map['isOnlyProcessosComApenso'] = isOnlyProcessosComApenso;
    }

    if (notAnoExercicio != null) {
      map['notAnoExercicio'] = notAnoExercicio;
    }
    if (notCodProcesso != null) {
      map['notCodProcesso'] = notCodProcesso;
    }

    if (onlyProcessosFilhoDe != null) {
      map['onlyProcessosFilhoDe'] = onlyProcessosFilhoDe;
    }
    if (tipoListagemProcessos != null) {
      map['tipoListagemProcessos'] = tipoListagemProcessos;
    }

    if (codPais != null) {
      map['codPais'] = codPais;
    }
    if (codUf != null) {
      map['codUf'] = codUf;
    }

    if (codProcesso != null) {
      map['codProcesso'] = codProcesso;
    }
    if (codigoProcesso != null) {
      map['codigoProcesso'] = codigoProcesso;
    }
    if (situacao != null) {
      map['situacao'] = situacao;
    }

    if (removeDisabledItems != null) {
      map['removeDisabledItems'] = removeDisabledItems;
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

    codOrgao = null;
    codUnidade = null;
    codDepartamento = null;
    codSetor = null;
    codFuncionalidade = null;
    codGestao = null;
    codTipoNorma = null;
    idSetorOrigem = null;
    codClassificacao = null;
    codAssunto = null;

    idListaProcessos = null;
    anoExercicioListaProcessos = null;
  }

  Map<String, String?> getParams() {
    var stringParams = <String, String?>{};
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
      stringParams['search'] = searchString;
    }
    if (orderBy != null) {
      stringParams['orderBy'] = orderBy;
    }
    if (orderDir != null) {
      stringParams['orderDir'] = orderDir;
    }
    //
    if (codOrgao != null) {
      stringParams['codOrgao'] = codOrgao.toString();
    }
    if (codUnidade != null) {
      stringParams['codUnidade'] = codUnidade.toString();
    }
    if (codDepartamento != null) {
      stringParams['codDepartamento'] = codDepartamento.toString();
    }
    if (codSetor != null) {
      stringParams['codSetor'] = codSetor.toString();
    }
    if (codFuncionalidade != null) {
      stringParams['codFuncionalidade'] = codFuncionalidade.toString();
    }
    if (codGestao != null) {
      stringParams['codGestao'] = codGestao.toString();
    }
    if (codTipoNorma != null) {
      stringParams['codTipoNorma'] = codTipoNorma.toString();
    }

    if (idSetorOrigem != null) {
      stringParams['idSetorOrigem'] = idSetorOrigem.toString();
    }

    if (codClassificacao != null) {
      stringParams['codClassificacao'] = codClassificacao.toString();
    }
    if (codAssunto != null) {
      stringParams['codAssunto'] = codAssunto.toString();
    }

    if (codModulo != null) {
      stringParams['codModulo'] = codModulo.toString();
    }
    if (confParametro != null) {
      stringParams['confParametro'] = confParametro;
    }

    if (anoExercicio != null) {
      stringParams['anoExercicio'] = anoExercicio;
    }

    if (codCgm != null) {
      stringParams['codCgm'] = codCgm.toString();
    }
    if (cpf != null) {
      stringParams['cpf'] = cpf;
    }
    if (cnpj != null) {
      stringParams['cnpj'] = cnpj;
    }

    if (processos.isNotEmpty) {
      stringParams['processos'] = processos.join(',');
    }

    if (situacoes.isNotEmpty) {
      stringParams['situacoes'] = situacoes.join(',');
    }

    if (additionalFilters.isNotEmpty == true) {
      stringParams['additionalFilters'] =
          jsonEncode(additionalFilters.map((e) => e.toMap()).toList());
    }

    if (searchInFields.isNotEmpty == true) {
      stringParams['searchInFields'] =
          jsonEncode(searchInFields.map((e) => e.toMap()).toList());
    }

    if (inicio != null) {
      stringParams['inicio'] = inicio!.toIso8601String();
    }
    if (fim != null) {
      stringParams['fim'] = fim!.toIso8601String();
    }
    if (idListaProcessos != null) {
      stringParams['idListaProcessos'] = idListaProcessos.toString();
    }
    if (anoExercicioListaProcessos != null) {
      stringParams['anoExercicioListaProcessos'] = anoExercicioListaProcessos;
    }

    if (codUsuarioRecebeu != null) {
      stringParams['codUsuarioRecebeu'] = codUsuarioRecebeu.toString();
    }

    if (codAndamento != null) {
      stringParams['codAndamento'] = codAndamento.toString();
    }
    if (isJoinOrgao != null) {
      stringParams['isJoinOrgao'] = isJoinOrgao.toString();
    }
    if (isJoinClassificacao != null) {
      stringParams['isJoinClassificacao'] = isJoinClassificacao.toString();
    }
    if (isGetAndamentoPadrao != null) {
      stringParams['isGetAndamentoPadrao'] = isGetAndamentoPadrao.toString();
    }

    if (isNotProcessosComApenso != null) {
      stringParams['isNotProcessosComApenso'] =
          isNotProcessosComApenso.toString();
    }

    if (forceRefresh != null) {
      stringParams['forceRefresh'] = forceRefresh.toString();
    }

    if (isOnlyProcessosComApenso != null) {
      stringParams['isOnlyProcessosComApenso'] =
          isOnlyProcessosComApenso.toString();
    }

    if (notAnoExercicio != null) {
      stringParams['notAnoExercicio'] = notAnoExercicio;
    }
    if (notCodProcesso != null) {
      stringParams['notCodProcesso'] = notCodProcesso.toString();
    }

    if (onlyProcessosFilhoDe != null) {
      stringParams['onlyProcessosFilhoDe'] = onlyProcessosFilhoDe;
    }
    if (tipoListagemProcessos != null) {
      stringParams['tipoListagemProcessos'] = tipoListagemProcessos;
    }

    if (codPais != null) {
      stringParams['codPais'] = codPais.toString();
    }
    if (codUf != null) {
      stringParams['codUf'] = codUf.toString();
    }

    if (codProcesso != null) {
      stringParams['codProcesso'] = codProcesso.toString();
    }
    if (codigoProcesso != null) {
      stringParams['codigoProcesso'] = codigoProcesso;
    }
    if (situacao != null) {
      stringParams['situacao'] = situacao;
    }

    if (removeDisabledItems != null) {
      stringParams['removeDisabledItems'] = removeDisabledItems.toString();
    }

    return stringParams;
  }

  /* void addParam(String paramName, String paramValue) {
    if (paramName != null && paramName.isNotEmpty) {
      stringParams[paramName] = paramValue;
    }
  }

  void addParams(Map<String, String> params) {
    stringParams.addAll(params);
  }*/

  Filters copyWith({
    int? limit,
    int? offset,
    String? anoExercicio,
    int? codCgm,
    String? cpf,
    String? cnpj,
    int? codOrgao,
    int? codUnidade,
    int? codDepartamento,
    int? codSetor,
    int? codClassificacao,
    int? codAssunto,
    int? codModulo,
    int? idListaProcessos,
    String? anoExercicioListaProcessos,
    int? codAndamento,
    String? tipoListagemProcessos,
    String? notAnoExercicio,
    int? notCodProcesso,
    bool? isNotProcessosComApenso,
    bool? isOnlyProcessosComApenso,
    String? onlyProcessosFilhoDe,
    bool? isJoinOrgao,
    int? codUsuarioRecebeu,
    DateTime? inicio,
    DateTime? fim,
    String? confParametro,
    String? searchString,
    List<FilterSearchField>? searchInFields,
    String? orderBy,
    String? orderDir,
    List<Filter>? additionalFilters,
    List<String>? processos,
  }) {
    return Filters(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codCgm: codCgm ?? this.codCgm,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      codOrgao: codOrgao ?? this.codOrgao,
      codUnidade: codUnidade ?? this.codUnidade,
      codDepartamento: codDepartamento ?? this.codDepartamento,
      codSetor: codSetor ?? this.codSetor,
      codClassificacao: codClassificacao ?? this.codClassificacao,
      codAssunto: codAssunto ?? this.codAssunto,
      codModulo: codModulo ?? this.codModulo,
      idListaProcessos: idListaProcessos ?? this.idListaProcessos,
      anoExercicioListaProcessos:
          anoExercicioListaProcessos ?? this.anoExercicioListaProcessos,
      codAndamento: codAndamento ?? this.codAndamento,
      tipoListagemProcessos:
          tipoListagemProcessos ?? this.tipoListagemProcessos,
      notAnoExercicio: notAnoExercicio ?? this.notAnoExercicio,
      notCodProcesso: notCodProcesso ?? this.notCodProcesso,
      isNotProcessosComApenso:
          isNotProcessosComApenso ?? this.isNotProcessosComApenso,
      isOnlyProcessosComApenso:
          isOnlyProcessosComApenso ?? this.isOnlyProcessosComApenso,
      onlyProcessosFilhoDe: onlyProcessosFilhoDe ?? this.onlyProcessosFilhoDe,
      isJoinOrgao: isJoinOrgao ?? this.isJoinOrgao,
      isJoinClassificacao: isJoinClassificacao ?? this.isJoinClassificacao,
      codUsuarioRecebeu: codUsuarioRecebeu ?? this.codUsuarioRecebeu,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      confParametro: confParametro ?? this.confParametro,
      searchString: searchString ?? this.searchString,
      // searchInFields: searchInFields ?? this.searchInFields,
      orderBy: orderBy ?? this.orderBy,
      orderDir: orderDir ?? this.orderDir,
      // additionalFilters: additionalFilters ?? this.additionalFilters,
      // processos: processos ?? this.processos,
    );
  }
}
