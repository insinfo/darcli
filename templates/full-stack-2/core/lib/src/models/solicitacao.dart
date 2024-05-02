import 'package:esic_core/esic_core.dart';
import 'package:intl/intl.dart';

class Solicitacao implements SerializeBase {
  int id;
  int idsolicitante;
  int numProtocolo;
  int anoProtocolo;

  /// Identifica o tipo de solicitação
  int idTipoSolicitacao;

  /// identifica a solicitação original quando a solicitação for de recurso (tiposolicitao ser P ou S)
  int? idSolicitacaoOrigem;

  /// A - aberto; T - em tramitacao; N - negado; R - respondido;
  String situacao;

  /// [E]mail - [F]ax - [C]orreio
  String formaRetorno;

  DateTime dataSolicitacao;
  String textoSolicitacao;

  /// data de recebimento da solicitação
  DateTime? dataRecebimentoSolicitacao;

  /// dados da sessao de recebimento da solicitação
  int? idUsuarioRecebimento;

  /// data prevista para a solicitação ser respondida
  DateTime dataPrevisaoResposta;

  /// Indica se a data prevista para resposta foi prorrogada
  DateTime? dataProrrogacao;

  String? motivoProrrogacao;

  /// dados da sessao da prorrogação
  int? idUsuarioProrrogacao;

  /// data da resposta da solicitação
  DateTime? dataResposta;

  String resposta;
  int? idUsuarioResposta;

  /// Identifica o SIC direcionado pelo solicitante no momento do cadastro da solicitação
  int? idSecretariaSelecionada;

  /// Identificador da secretaria que respondeu a requisição
  int? idSecretariaResposta;

  //----------------------------- EXTRAS -----------------------------
  TipoSolicitacao? _tipoSolicitacao; // = TipoSolicitacao.inicial();

  TipoSolicitacao? get tipoSolicitacao {
    return _tipoSolicitacao;
  }

  set tipoSolicitacao(TipoSolicitacao? ti) {
    if (ti != null) {
      idTipoSolicitacao = ti.id;
    }
    _tipoSolicitacao = ti;
  }

  Usuario? _usuarioResposta;

  Usuario? get usuarioResposta {
    return _usuarioResposta;
  }

  set usuarioResposta(Usuario? user) {
    idUsuarioResposta = user?.id;
    _usuarioResposta = user;
  }

  String secretariaOrigemNome = '';
  String secretariaDestinoNome = '';
  String solicitanteNome = '';

  String usuarioRecebimentoNome = '';
  String usuarioProrrogacaoNome = '';
  String usuarioRespostaNome = '';

  /// prazo restante em dias
  int prazoRestante = 0;
  String instancia = '';

  List<Anexo> anexos = <Anexo>[];

  Solicitacao({
    this.id = -1,
    required this.idsolicitante,
    required this.numProtocolo,
    required this.anoProtocolo,
    required this.idTipoSolicitacao,
    this.idSolicitacaoOrigem,
    required this.situacao,
    required this.formaRetorno,
    required this.dataSolicitacao,
    required this.textoSolicitacao,
    this.dataRecebimentoSolicitacao,
    this.idUsuarioRecebimento,
    required this.dataPrevisaoResposta,
    this.dataProrrogacao,
    this.motivoProrrogacao,
    this.idUsuarioProrrogacao,
    this.dataResposta,
    required this.resposta,
    this.idUsuarioResposta,
    this.idSecretariaSelecionada,
    this.idSecretariaResposta,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'idsolicitacao': id,
      'idsolicitante': idsolicitante,
      'numprotocolo': numProtocolo,
      'anoprotocolo': anoProtocolo,
      'idtiposolicitacao': idTipoSolicitacao,
      'idsolicitacaoorigem': idSolicitacaoOrigem,
      'situacao': situacao,
      'formaretorno': formaRetorno,
      'datasolicitacao': dataSolicitacao.toString(),
      'textosolicitacao': textoSolicitacao,
      'idusuariorecebimento': idUsuarioRecebimento,
      'dataprevisaoresposta': dataPrevisaoResposta.toString(),
      'motivoprorrogacao': motivoProrrogacao,
      'idusuarioprorrogacao': idUsuarioProrrogacao,
      'resposta': resposta,
      'idusuarioresposta': idUsuarioResposta,
      'idsecretariaselecionada': idSecretariaSelecionada,
      'idsecretariaresposta': idSecretariaResposta,
    };

    if (dataProrrogacao != null) {
      map['dataprorrogacao'] = dataProrrogacao.toString();
    }
    if (dataResposta != null) {
      map['dataresposta'] = dataResposta.toString();
    }
    if (dataRecebimentoSolicitacao != null) {
      map['datarecebimentosolicitacao'] = dataRecebimentoSolicitacao.toString();
    }

    map['solicitantenome'] = solicitanteNome;
    map['secretariaorigemnome'] = secretariaOrigemNome;
    map['secretariadestinonome'] = secretariaDestinoNome;
    map['prazorestante'] = prazoRestante;

    map['usuariorecebimentonome'] = usuarioRecebimentoNome;
    map['usuarioprorrogacaonome'] = usuarioProrrogacaoNome;
    map['usuariorespostanome'] = usuarioRespostaNome;

    if (anexos.isNotEmpty == true) {
      map['anexos'] = anexos.map((a) => a.toMap()).toList();
    }
    if (tipoSolicitacao != null) {
      map['tipoSolicitacao'] = tipoSolicitacao!.toMap();
    }

    if (usuarioResposta != null) {
      map['usuarioResposta'] = usuarioResposta!.toMap();
    }

    return map;
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()
      ..remove('idsolicitacao')
      ..remove('tipoSolicitacao')
      ..remove('usuarioResposta')
      ..remove('secretariaorigemnome')
      ..remove('secretariadestinonome')
      ..remove('prazorestante')
      ..remove('solicitantenome')
      ..remove('usuariorecebimentonome')
      ..remove('usuarioprorrogacaonome')
      ..remove('usuariorespostanome');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap()
      ..remove('idsolicitacao')
      ..remove('tipoSolicitacao')
      ..remove('usuarioResposta')
      ..remove('secretariaorigemnome')
      ..remove('secretariadestinonome')
      ..remove('prazorestante')
      ..remove('solicitantenome')
      ..remove('usuariorecebimentonome')
      ..remove('usuarioprorrogacaonome')
      ..remove('usuariorespostanome');
  }

  /// A - aberto; T - em tramitacao; N - negado; R - respondido;
  String get situacaoText {
    switch (situacao) {
      case 'A':
        return 'Aberto';
      case 'T':
        return 'Tramitação';
      case 'N':
        return 'Negado';
      case 'R':
        return 'Respondido';
      default:
        return '';
    }
  }

  set tipoSolicitacaoIdText(String? id) {
    if (id != null) {
      idTipoSolicitacao = int.parse(id);
    }
  }

  String? get tipoSolicitacaoIdText => idTipoSolicitacao.toString();

  set dataSolicitacaoText(String? text) {
    if (text != null) {
      dataSolicitacao = DateTime.parse(text);
    }
  }

  String? get dataSolicitacaoText {
    var dtf = DateFormat('yyyy-MM-dd');
    return dtf.format(dataSolicitacao);
  }

  String? get dataRespostaTextBr {
    if (dataResposta != null) {
      var dtf = DateFormat('dd/MM/yyyy');
      return dtf.format(dataResposta!);
    }
    return '';
  }

  String get dataSolicitacaoTextBr {
    var dtf = DateFormat('dd/MM/yyyy');
    return dtf.format(dataSolicitacao);
  }

  String get dataPrevisaoRespostaTextBr {
    var dtf = DateFormat('dd/MM/yyyy');
    return dtf.format(dataPrevisaoResposta);
  }

  String? get dataRecebimentoSolicitacaoTextBr {
    if (dataRecebimentoSolicitacao != null) {
      var dtf = DateFormat('dd/MM/yyyy');
      return dtf.format(dataRecebimentoSolicitacao!);
    }
    return '';
  }

  String get foiProrrogadoText {
    return dataProrrogacao != null ? 'Sim' : 'Não';
  }

  bool get foiProrrogado {
    return dataProrrogacao != null;
  }

  bool get foiRespondido {
    return dataResposta != null;
  }

  /// [E]mail - [F]ax - [C]orreio
  String get formaRetornoText {
    switch (formaRetorno) {
      case 'E':
        return 'E-mail';
      case 'F':
        return 'Fax';
      case 'C':
        return 'Correio';
      default:
        return '';
    }
  }

  String get protocoloText {
    return '$numProtocolo/$anoProtocolo';
  }

  factory Solicitacao.fromMap(Map<String, dynamic> map) {
    var sol = Solicitacao(
      id: map['idsolicitacao']?.toInt() ?? 0,
      idsolicitante: map['idsolicitante'],
      numProtocolo: map['numprotocolo']?.toInt() ?? 0,
      anoProtocolo: map['anoprotocolo']?.toInt() ?? 0,
      idTipoSolicitacao: map['idtiposolicitacao']?.toInt() ?? 0,
      idSolicitacaoOrigem: map['idsolicitacaoorigem']?.toInt(),
      situacao: map['situacao'] ?? '',
      formaRetorno: map['formaretorno'] ?? '',
      dataSolicitacao: DateTime.parse(map['datasolicitacao']),
      textoSolicitacao: map['textosolicitacao'] ?? '',
      dataRecebimentoSolicitacao: map['datarecebimentosolicitacao'] != null
          ? DateTime.tryParse(map['datarecebimentosolicitacao'])
          : null,
      idUsuarioRecebimento: map['idusuariorecebimento']?.toInt(),
      dataPrevisaoResposta: DateTime.parse(map['dataprevisaoresposta']),
      dataProrrogacao: map['dataprorrogacao'] != null
          ? DateTime.tryParse(map['dataprorrogacao'])
          : null,
      motivoProrrogacao: map['motivoprorrogacao'],
      idUsuarioProrrogacao: map['idusuarioprorrogacao']?.toInt(),
      dataResposta: map['dataresposta'] != null
          ? DateTime.tryParse(map['dataresposta'])
          : null,
      resposta: map['resposta'] ?? '',
      idUsuarioResposta: map['idusuarioresposta']?.toInt(),
      idSecretariaSelecionada: map['idsecretariaselecionada']?.toInt(),
      idSecretariaResposta: map['idsecretariaresposta']?.toInt(),
    );
    //------------------------ EXTRAS ------------------------

    if (map['solicitantenome'] != null) {
      sol.solicitanteNome = map['solicitantenome'];
    }

    if (map['secretariaorigemnome'] != null) {
      sol.secretariaOrigemNome = map['secretariaorigemnome'];
    }
    if (map['secretariadestinonome'] != null) {
      sol.secretariaDestinoNome = map['secretariadestinonome'];
    }

    if (map['prazorestante'] != null) {
      sol.prazoRestante = map['prazorestante'];
    }

    if (map['usuariorecebimentonome'] != null) {
      sol.usuarioRecebimentoNome = map['usuariorecebimentonome'];
    }

    if (map['usuarioprorrogacaonome'] != null) {
      sol.usuarioProrrogacaoNome = map['usuarioprorrogacaonome'];
    }

    if (map['usuariorespostanome'] != null) {
      sol.usuarioRespostaNome = map['usuariorespostanome'];
    }

    if (map['anexos'] is List) {
      sol.anexos =
          (map['anexos'] as List).map((m) => Anexo.fromMap(m)).toList();
    }

    if (map['tipoSolicitacao'] is Map) {
      sol.tipoSolicitacao = TipoSolicitacao.fromMap(map['tipoSolicitacao']);
    }

    if (map['usuarioResposta'] is Map) {
      sol.usuarioResposta = Usuario.fromMap(map['usuarioResposta']);
    }

    return sol;
  }
}
