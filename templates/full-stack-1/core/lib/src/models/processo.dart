// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:intl/intl.dart';

import 'package:new_sali_core/new_sali_core.dart';

class DesarquivarProcessoItem {
  int codProcesso;
  String anoExercicio;

  int codSituacao = 3;

  static List<DesarquivarProcessoItem> fromListMap(List<dynamic> mapList) {
    return mapList
        .map((e) => DesarquivarProcessoItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  DesarquivarProcessoItem({
    required this.codProcesso,
    required this.anoExercicio,
    this.codSituacao = 3,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'cod_situacao': codSituacao,
    };
  }

  factory DesarquivarProcessoItem.fromMap(Map<String, dynamic> map) {
    return DesarquivarProcessoItem(
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codSituacao: map['cod_situacao'] as int,
    );
  }
}

class ArquivarProcessoItem {
  int codProcesso;
  String anoExercicio;
  int codHistorico;
  String textoComplementar;
  int codSituacao = 9;

  static List<ArquivarProcessoItem> fromListMap(List<dynamic> mapList) {
    return mapList
        .map((e) => ArquivarProcessoItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  ArquivarProcessoItem({
    required this.codProcesso,
    required this.anoExercicio,
    required this.codHistorico,
    required this.textoComplementar,
    this.codSituacao = 9,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'cod_historico': codHistorico,
      'texto_complementar': textoComplementar,
      'cod_situacao': codSituacao,
    };
  }

  factory ArquivarProcessoItem.fromMap(Map<String, dynamic> map) {
    return ArquivarProcessoItem(
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codHistorico: map['cod_historico'] as int,
      textoComplementar: map['texto_complementar'] as String,
      codSituacao: map['cod_situacao'] as int,
    );
  }
}

class ApensarProcessoItem implements BaseModel {
  int codProcessoPai;
  String exercicioPai;
  int codProcessoFilho;
  String exercicioFilho;
  //DateTime timestamp_apensamento;

  static List<ApensarProcessoItem> fromListMap(List<dynamic> mapList) {
    return mapList
        .map((e) => ApensarProcessoItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  ApensarProcessoItem({
    required this.codProcessoPai,
    required this.exercicioPai,
    required this.codProcessoFilho,
    required this.exercicioFilho,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_processo_pai': codProcessoPai,
      'exercicio_pai': exercicioPai,
      'cod_processo_filho': codProcessoFilho,
      'exercicio_filho': exercicioFilho,
    };
  }

  factory ApensarProcessoItem.fromMap(Map<String, dynamic> map) {
    return ApensarProcessoItem(
      codProcessoPai: map['cod_processo_pai'] as int,
      exercicioPai: map['exercicio_pai'] as String,
      codProcessoFilho: map['cod_processo_filho'] as int,
      exercicioFilho: map['exercicio_filho'] as String,
    );
  }
}

class CancelarEncaminhamentoItem implements BaseModel {
  final int codProcesso;
  final int codUltimoAndamento;
  final String anoExercicio;

  static List<CancelarEncaminhamentoItem> fromListMap(List<dynamic> mapList) {
    return mapList
        .map((e) =>
            CancelarEncaminhamentoItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  CancelarEncaminhamentoItem({
    required this.codProcesso,
    required this.codUltimoAndamento,
    required this.anoExercicio,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'codProcesso': codProcesso,
      'codUltimoAndamento': codUltimoAndamento,
      'anoExercicio': anoExercicio,
    };
  }

  factory CancelarEncaminhamentoItem.fromMap(Map<String, dynamic> map) {
    return CancelarEncaminhamentoItem(
      codProcesso: map['codProcesso'] as int,
      codUltimoAndamento: map['codUltimoAndamento'] as int,
      anoExercicio: map['anoExercicio'] as String,
    );
  }
}

/// DTO para enviar para o Backend com os dados para colocar um processo com status Recebido
class ReceberProcessoItem implements BaseModel {
  final int codUltimoAndamento;
  final int codProcesso;
  final String anoExercicio;

  static List<ReceberProcessoItem> fromListMap(List<dynamic> mapList) {
    return mapList
        .map((e) => ReceberProcessoItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  ReceberProcessoItem(
      this.codUltimoAndamento, this.codProcesso, this.anoExercicio);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'codUltimoAndamento': codUltimoAndamento,
      'codProcesso': codProcesso,
      'anoExercicio': anoExercicio,
    };
  }

  factory ReceberProcessoItem.fromMap(Map<String, dynamic> map) {
    return ReceberProcessoItem(
      map['codUltimoAndamento'] as int,
      map['codProcesso'] as int,
      map['anoExercicio'],
    );
  }
}

/// DTO para enviar para o Backend com os dados para encaminhar um processo
class EncaminharProcessoItem implements BaseModel {
  int codProcesso;
  String anoExercicio;
  int codOrgao;
  int codUnidade;
  int codDepartamento;
  int codSetor;
  String anoExercicioSetor;

  static List<EncaminharProcessoItem> fromListMap(List<dynamic> mapList) {
    return mapList
        .map((e) => EncaminharProcessoItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  EncaminharProcessoItem({
    required this.codProcesso,
    required this.anoExercicio,
    required this.codOrgao,
    required this.codUnidade,
    required this.codDepartamento,
    required this.codSetor,
    required this.anoExercicioSetor,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'cod_orgao': codOrgao,
      'cod_unidade': codUnidade,
      'cod_departamento': codDepartamento,
      'cod_setor': codSetor,
      'ano_exercicio_setor': anoExercicioSetor,
    };
  }

  factory EncaminharProcessoItem.fromMap(Map<String, dynamic> map) {
    return EncaminharProcessoItem(
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codOrgao: map['cod_orgao'] as int,
      codUnidade: map['cod_unidade'] as int,
      codDepartamento: map['cod_departamento'] as int,
      codSetor: map['cod_setor'] as int,
      anoExercicioSetor: map['ano_exercicio_setor'] as String,
    );
  }
}

/// processo do Modulo Protocolo do Sali/Siamweb
class Processo implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_processo';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// chave primaria
  int codProcesso;
  // chave primaria
  String anoExercicio;

  int get anoExercicioAsInt => int.tryParse(anoExercicio) ?? -1;

  set anoExercicioAsInt(int val) => anoExercicio = val.toString();

  int codClassificacao;
  int codAssunto;

  /// CGM do interessado
  int numCgm;

  /// CGM do usuario que criou o processo
  int codUsuario;

  /// padrao 2 > "Em andamento, a receber"
  ///  1	No Protocolo
  /// 2	Em andamento, a receber
  /// 3	Em andamento, recebido
  /// 4	Anexado
  /// 5	Arquivado temporario
  /// 9	Arquivado definitivo
  /// 10	Em pagamento
  /// 11	Arquivado ferias
  int codSituacao;

  String codSituacaoAsLabel(int codS) {
    switch (codS) {
      case 1:
        return 'No Protocolo';
      case 2:
        return 'Em andamento, a receber';
      case 3:
        return 'Em andamento, recebido';
      case 4:
        return 'Anexado';
      case 5:
        return 'Arquivado temporario';
      case 9:
        return 'Arquivado definitivo';
      case 10:
        return 'Em pagamento';
      case 11:
        return 'Arquivado férias';
      default:
        return 'Situação desconhecida';
    }
  }

  String get situacaoLabel {
    return codSituacaoAsLabel(codSituacao);
  }

  /// data inclusao
  DateTime timestamp;

  String get dataInclusaoFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  String observacoes;
  bool confidencial;
  String resumoAssunto;

  /// propriedade anexada
  List<Andamento> andamentos = <Andamento>[];

  /// propriedade anexada
  int? cgmInteressado;

  /// propriedade anexada
  String? nomeInteressado;

  /// CPF / CNPJ
  String? documentoInteressado;

  String? tipoInteressado;

  /// propriedade anexada
  String? codigoProcesso;

  /// propriedade anexada
  String? nomClassificacao;

  /// propriedade anexada
  String? nomAssunto;

  /// propriedade anexada
  String? nomSituacao;

  /// propriedade anexada username de quem cadastrou o porcesso
  String? usuarioQueIncluiu;

  /// nome da pessoa que incluiu o processo
  String? nomeUsuarioQueIncluiu;

  DateTime? dataApensamento;

  String get dataApensamentoFormatada {
    return dataApensamento == null
        ? ''
        : DateFormat('dd/MM/yyyy HH:mm').format(dataApensamento!);
  }

  /// propriedade anexada
  DateTime? dataDesapensamento;

  String get dataDesapensamentoFormatada {
    return dataDesapensamento == null
        ? ''
        : DateFormat('dd/MM/yyyy HH:mm').format(dataDesapensamento!);
  }

  /// propriedade anexada
  bool? temDespacho;

  /// propriedade anexada
  int? codUltimoAndamento;

  /// sw_ultimo_andamento.timestamp AS data_ultimo_andamentodata_ultimo_andamento
  DateTime? dataUltimoAndamento;

  String get dataUltimoAndamentoFormatada {
    if (dataUltimoAndamento == null) {
      return '';
    }   
    final fm = DateFormat('dd/MM/yyyy HH:mm');
    final formatada = fm.format(dataUltimoAndamento!);
    return formatada;
  }

  /// propriedade anexada Atributos de processo
  List<AtributoProtocolo> atributosProtocolo = <AtributoProtocolo>[];

  /// nome do orgao de ultimo andamento
  String? nomOrgao;
  int? codOrgao;

  /// nome da unidade de ultimo andamento
  String? nomUnidade;
  int? codUnidade;

  /// nome da departamento de ultimo andamento
  String? nomDepartamento;
  int? codDepartamento;

  /// nome da setor de ultimo andamento
  String? nomSetor;
  int? codSetor;
  String? anoExercicioSetor;

  /// propriedade anexada  favoritos.id AS favorito_id
  int? favoritoId;
  bool get isFavoritado => favoritoId != null;

  /// propriedade anexada
  DateTime? timestampArquivamento;

  String get dataArquivamentoFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  String? textoComplementar;

  /// lista processos em apensos
  List<Processo> apensos = [];
  bool? temApenso;

  /// lista arquivos anexados a este processo
  List<ProcessoAnexo> anexos = [];

  /// setor que criou o processo
  int? idSetor;
  String? nomeSetorOrigem;

  String? nomeCgmApensamento;
  String? nomeCgmDesapensamento;
  int? numCgmApensamento;
  int? numCgmDesapensamento;

  Processo({
    required this.codProcesso,
    required this.anoExercicio,
    required this.codClassificacao,
    required this.codAssunto,
    required this.numCgm,
    required this.codUsuario,
    required this.codSituacao,
    required this.timestamp,
    required this.observacoes,
    required this.confidencial,
    required this.resumoAssunto,
  });

  /// cria um novo processo com dados invalidos
  factory Processo.invalido() {
    return Processo(
      anoExercicio: '',
      codAssunto: -1,
      codClassificacao: -1,
      codProcesso: -1,
      codSituacao: -1,
      codUsuario: -1,
      confidencial: false,
      numCgm: -1,
      observacoes: '',
      resumoAssunto: '',
      timestamp: DateTime.now(),
    );
  }

  Processo copyWith({
    int? codProcesso,
    String? anoExercicio,
    int? codClassificacao,
    int? codAssunto,
    int? numCgm,
    int? codUsuario,
    int? codSituacao,
    DateTime? timestamp,
    String? observacoes,
    bool? confidencial,
    String? resumoAssunto,
  }) {
    return Processo(
      codProcesso: codProcesso ?? this.codProcesso,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codClassificacao: codClassificacao ?? this.codClassificacao,
      codAssunto: codAssunto ?? this.codAssunto,
      numCgm: numCgm ?? this.numCgm,
      codUsuario: codUsuario ?? this.codUsuario,
      codSituacao: codSituacao ?? this.codSituacao,
      timestamp: timestamp ?? this.timestamp,
      observacoes: observacoes ?? this.observacoes,
      confidencial: confidencial ?? this.confidencial,
      resumoAssunto: resumoAssunto ?? this.resumoAssunto,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'cod_classificacao': codClassificacao,
      'cod_assunto': codAssunto,
      'numcgm': numCgm,
      'cod_usuario': codUsuario,
      'cod_situacao': codSituacao,
      'timestamp': timestamp.toIso8601String(),
      'observacoes': observacoes,
      'confidencial': confidencial,
      'resumo_assunto': resumoAssunto,
      'id_setor': idSetor,
    };

    // propriedades anexadas
    if (andamentos.isNotEmpty) {
      map['andamentos'] = andamentos.map((a) => a.toMap()).toList();
    }

    if (atributosProtocolo.isNotEmpty) {
      map['atributosProtocolo'] =
          atributosProtocolo.map((a) => a.toMap()).toList();
    }

    if (cgmInteressado != null) {
      map['cgm_interessado'] = cgmInteressado;
    }

    if (nomeInteressado != null) {
      map['nome_interessado'] = nomeInteressado;
    }
    if (codigoProcesso != null) {
      map['codigo_processo'] = codigoProcesso;
    }
    if (nomClassificacao != null) {
      map['nom_classificacao'] = nomClassificacao;
    }
    if (nomAssunto != null) {
      map['nom_assunto'] = nomAssunto;
    }
    if (nomSituacao != null) {
      map['nom_situacao'] = nomSituacao;
    }
    // map['data_inclusao']=data_inclusao;
    if (usuarioQueIncluiu != null) {
      map['usuario_que_incluiu'] = usuarioQueIncluiu;
    }
    if (nomeUsuarioQueIncluiu != null) {
      map['nome_usuario_que_incluiu'] = nomeUsuarioQueIncluiu;
    }
    if (temDespacho != null) {
      map['tem_despacho'] = temDespacho;
    }

    if (dataApensamento != null) {
      map['data_apensamento'] = dataApensamento!.toIso8601String();
    }

    if (dataDesapensamento != null) {
      map['data_desapensamento'] = dataDesapensamento!.toIso8601String();
    }

    if (codUltimoAndamento != null) {
      map['cod_ultimo_andamento'] = codUltimoAndamento;
    }

    if (dataUltimoAndamento != null) {
      map['data_ultimo_andamento'] = dataUltimoAndamento!.toIso8601String();
    }

    if (documentoInteressado != null) {
      map['doc_interessado'] = documentoInteressado;
    }
    if (tipoInteressado != null) {
      map['tipo_interessado'] = tipoInteressado;
    }
    if (nomOrgao != null) {
      map['nom_orgao'] = nomOrgao;
    }
    if (nomUnidade != null) {
      map['nom_unidade'] = nomUnidade;
    }
    if (nomDepartamento != null) {
      map['nom_departamento'] = nomDepartamento;
    }
    if (nomSetor != null) {
      map['nom_setor'] = nomSetor;
    }

    if (codOrgao != null) {
      map['cod_orgao'] = codOrgao;
    }
    if (codUnidade != null) {
      map['cod_unidade'] = codUnidade;
    }
    if (codDepartamento != null) {
      map['cod_departamento'] = codDepartamento;
    }
    if (codSetor != null) {
      map['cod_setor'] = codSetor;
    }
    if (anoExercicioSetor != null) {
      map['ano_exercicio_setor'] = anoExercicioSetor;
    }
    if (favoritoId != null) {
      map['favorito_id'] = favoritoId;
    }
    if (timestampArquivamento != null) {
      map['timestamp_arquivamento'] = timestampArquivamento!.toIso8601String();
    }
    if (textoComplementar != null) {
      map['texto_complementar'] = textoComplementar;
    }

    if (apensos.isNotEmpty == true) {
      map['apensos'] = apensos.map((e) => e.toMap()).toList();
    }
    if (temApenso != null) {
      map['tem_apenso'] = temApenso;
    }

    if (nomeSetorOrigem != null) {
      map['nome_setor_origem'] = nomeSetorOrigem;
    }
    if (nomeCgmApensamento != null) {
      map['nome_cgm_apensamento'] = nomeCgmApensamento;
    }
    if (nomeCgmDesapensamento != null) {
      map['nome_cgm_desapensamento'] = nomeCgmDesapensamento;
    }
    if (numCgmApensamento != null) {
      map['num_cgm_apensamento'] = numCgmApensamento;
    }
    if (numCgmDesapensamento != null) {
      map['num_cgm_desapensamento'] = numCgmDesapensamento;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('andamentos')
      ..remove('atributosProtocolo')
      ..remove('cgm_interessado')
      ..remove('nome_interessado')
      ..remove('codigo_processo')
      ..remove('nom_classificacao')
      ..remove('nom_assunto')
      ..remove('nom_situacao')
      ..remove('usuario_que_incluiu')
      ..remove('data_apensamento')
      ..remove('data_desapensamento')
      ..remove('tem_despacho')
      ..remove('cod_ultimo_andamento')
      ..remove('data_ultimo_andamento')
      ..remove('nome_usuario_que_incluiu')
      ..remove('doc_interessado')
      ..remove('tipo_interessado')
      ..remove('nom_orgao')
      ..remove('nom_unidade')
      ..remove('nom_departamento')
      ..remove('nom_setor')
      ..remove('cod_orgao')
      ..remove('cod_unidade')
      ..remove('cod_departamento')
      ..remove('cod_setor')
      ..remove('ano_exercicio_setor')
      ..remove('favorito_id')
      ..remove('timestamp_arquivamento')
      ..remove('texto_complementar')
      ..remove('apensos')
      ..remove('tem_apenso')
      ..remove('anexos')
      ..remove('nome_setor_origem')
      ..remove('nome_cgm_apensamento')
      ..remove('nome_cgm_desapensamento')
      ..remove('num_cgm_apensamento')
      ..remove('num_cgm_desapensamento');
  }

  factory Processo.fromMap(Map<String, dynamic> map) {
    final proc = Processo(
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codClassificacao: map['cod_classificacao'] as int,
      codAssunto: map['cod_assunto'] as int,
      numCgm: map['numcgm'] as int,
      codUsuario: map['cod_usuario'] as int,
      codSituacao: map['cod_situacao'] as int,
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.parse(map['timestamp'].toString()),
      observacoes: map['observacoes'] as String,
      confidencial: map['confidencial'] as bool,
      resumoAssunto: map['resumo_assunto'] as String,
    );

    // propriedades anexadas
    if (map.containsKey('andamentos') &&
        map['andamentos'] is List &&
        map['andamentos'].isNotEmpty) {
      proc.andamentos = (map['andamentos'] as List)
          .map((m) => Andamento.fromMap(m as Map<String, dynamic>))
          .toList();
    }
    if (map.containsKey('atributosProtocolo') &&
        map['atributosProtocolo'] is List &&
        map['atributosProtocolo'].isNotEmpty) {
      proc.atributosProtocolo = (map['atributosProtocolo'] as List)
          .map((m) => AtributoProtocolo.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    if (map.containsKey('apensos') &&
        map['apensos'] is List &&
        map['apensos'].isNotEmpty) {
      proc.apensos = (map['apensos'] as List)
          .map((m) => Processo.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    if (map.containsKey('data_apensamento')) {
      proc.dataApensamento =
          DateTime.tryParse(map['data_apensamento'].toString());
    }
    if (map.containsKey('data_desapensamento')) {
      proc.dataDesapensamento =
          DateTime.tryParse(map['data_desapensamento'].toString());
    }

    if (map.containsKey('cgm_interessado')) {
      proc.cgmInteressado = map['cgm_interessado'];
    }
    if (map.containsKey('nome_interessado')) {
      proc.nomeInteressado = map['nome_interessado'];
    }
    if (map.containsKey('codigo_processo')) {
      proc.codigoProcesso = map['codigo_processo'];
    }
    if (map.containsKey('nom_classificacao')) {
      proc.nomClassificacao = map['nom_classificacao'];
    }
    if (map.containsKey('nom_assunto')) {
      proc.nomAssunto = map['nom_assunto'];
    }
    if (map.containsKey('nom_situacao')) {
      proc.nomSituacao = map['nom_situacao'];
    }
    // proc.data_inclusao= map['data_inclusao'];
    if (map.containsKey('usuario_que_incluiu')) {
      proc.usuarioQueIncluiu = map['usuario_que_incluiu'];
    }
    if (map.containsKey('nome_usuario_que_incluiu')) {
      proc.nomeUsuarioQueIncluiu = map['nome_usuario_que_incluiu'];
    }

    if (map.containsKey('tem_despacho')) {
      proc.temDespacho = map['tem_despacho'];
    }
    if (map.containsKey('cod_ultimo_andamento')) {
      proc.codUltimoAndamento = map['cod_ultimo_andamento'];
    }
    if (map.containsKey('data_ultimo_andamento')) {
      proc.dataUltimoAndamento =
          DateTime.tryParse(map['data_ultimo_andamento'].toString());
    }
    if (map.containsKey('doc_interessado')) {
      proc.documentoInteressado = map['doc_interessado'];
    }
    if (map.containsKey('tipo_interessado')) {
      proc.tipoInteressado = map['tipo_interessado'];
    }

    if (map.containsKey('nom_orgao')) {
      proc.nomOrgao = map['nom_orgao'];
    }
    if (map.containsKey('nom_unidade')) {
      proc.nomUnidade = map['nom_unidade'];
    }
    if (map.containsKey('nom_departamento')) {
      proc.nomDepartamento = map['nom_departamento'];
    }
    if (map.containsKey('nom_setor')) {
      proc.nomSetor = map['nom_setor'];
    }

    if (map.containsKey('cod_orgao')) {
      proc.codOrgao = map['cod_orgao'];
    }
    if (map.containsKey('cod_unidade')) {
      proc.codUnidade = map['cod_unidade'];
    }
    if (map.containsKey('cod_departamento')) {
      proc.codDepartamento = map['cod_departamento'];
    }
    if (map.containsKey('cod_setor')) {
      proc.codSetor = map['cod_setor'];
    }
    if (map.containsKey('ano_exercicio_setor')) {
      proc.anoExercicioSetor = map['ano_exercicio_setor'];
    }
    if (map.containsKey('favorito_id')) {
      proc.favoritoId = map['favorito_id'];
    }

    if (map.containsKey('tem_apenso')) {
      proc.temApenso = map['tem_apenso'];
    }

    if (map.containsKey('timestamp_arquivamento') &&
        map['timestamp_arquivamento'] != null) {
      proc.timestampArquivamento =
          DateTime.tryParse(map['timestamp_arquivamento'].toString());
    }
    if (map.containsKey('texto_complementar')) {
      proc.textoComplementar = map['texto_complementar'];
    }

    if (map.containsKey('id_setor')) {
      proc.idSetor = map['id_setor'];
    }

    if (map.containsKey('nome_setor_origem')) {
      proc.nomeSetorOrigem = map['nome_setor_origem'];
    }

    if (map.containsKey('nome_cgm_apensamento')) {
      proc.nomeCgmApensamento = map['nome_cgm_apensamento'];
    }
    if (map.containsKey('nome_cgm_desapensamento')) {
      proc.nomeCgmDesapensamento = map['nome_cgm_desapensamento'];
    }

    if (map.containsKey('num_cgm_apensamento')) {
      proc.numCgmApensamento = map['num_cgm_apensamento'];
    }
    if (map.containsKey('num_cgm_desapensamento')) {
      proc.numCgmDesapensamento = map['num_cgm_desapensamento'];
    }

    return proc;
  }

  @override
  String toString() {
    return 'Processo(cod_processo: $codProcesso, ano_exercicio: $anoExercicio, cod_classificacao: $codClassificacao, cod_assunto: $codAssunto, numcgm: $numCgm, cod_usuario: $codUsuario, cod_situacao: $codSituacao, timestamp: $timestamp, observacoes: $observacoes, confidencial: $confidencial, resumo_assunto: $resumoAssunto)';
  }

  @override
  bool operator ==(covariant Processo other) {
    if (identical(this, other)) return true;

    return other.codProcesso == codProcesso &&
        other.anoExercicio == anoExercicio;
  }

  @override
  int get hashCode {
    return codProcesso.hashCode ^ anoExercicio.hashCode;
  }

  String get dataHoraInclusaoFormatada {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);
  }

  String get numeroProcessoFormatado {
    return '${codProcesso}/${anoExercicio}';
  }
}
