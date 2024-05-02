import 'package:sibem_core/core.dart';

class StatusEncaminhamento {
  final String value;

  const StatusEncaminhamento(this.value);

  /// bg-purple
  static const StatusEncaminhamento encaminhado =
      StatusEncaminhamento('Encaminhado');

  /// bg-success
  static const StatusEncaminhamento efetivado =
      StatusEncaminhamento('Efetivado');

  /// bg-danger
  static const StatusEncaminhamento naoCompareceu =
      StatusEncaminhamento('Não Compareceu');

  /// bg-warning
  static const StatusEncaminhamento naoSelecionado =
      StatusEncaminhamento('Não Selecionado');

  static StatusEncaminhamento fromString(String val) {
    switch (val) {
      case 'Encaminhado':
        return StatusEncaminhamento.encaminhado;
      case 'Efetivado':
        return StatusEncaminhamento.efetivado;
      case 'Não Compareceu':
        return StatusEncaminhamento.naoCompareceu;
      case 'Não Selecionado':
        return StatusEncaminhamento.naoSelecionado;
      default:
        throw Exception('Status Encaminhamento desconhecido');
    }
  }

  static const List<String> listar = [
    'Encaminhado',
    'Efetivado',
    'Não Compareceu',
    'Não Selecionado'
  ];
}

//const listaStatusEncaminhamentoSibem = StatusEncaminhamento.listar;

class Encaminhamento implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'encaminhamentos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';
  static const String idColFq = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String idVagaColFq = '$tableName.$idVagaCol';
  static const String idVagaCol = 'idVaga';

  static const String idCandidatoColFq = '$tableName.$idCandidatoCol';
  static const String idCandidatoCol = 'idCandidato';

  static const String statusColFq = '$tableName.$statusCol';
  static const String statusCol = 'status';

  int id;
  int idVaga;
  int idCandidato;

  /// data do Encaminhamento
  DateTime data;

  /// data alteração do status
  DateTime? dataAlteracao;

  /// usuario responsavel pela alteração do status
  int? idUsuarioAlteracao;

  /// Status de Encaminhamento:  encaminhado | efetivo | naoCompareceu | naoSelecionado
  String status;

  /// usuario responsavel pela encaminhamento
  int idUsuario;
  String? observacao;

  int? quantidadeEncaminhada;
  int? numeroEncaminhamentos;
  String? usuarioResponsavelNome;

  DateTime? dataAberturaVaga;

  Vaga? _vaga;

  Vaga? get vaga {
    return _vaga;
  }

  set vaga(Vaga? v) {
    _vaga = v;
    if (v != null) {
      idVaga = v.id;
      nomeVaga = '${v.cargoNome} - ${v.empregadorNome}';
    }
  }

  Candidato? _candidato;

  Candidato? get candidato {
    return _candidato;
  }

  set candidato(Candidato? ca) {
    _candidato = ca;
    if (ca != null) {
      idCandidato = ca.idCandidato;
      nomeCandidato = ca.nome;
    }
  }

  Empregador? empregador;

  /// Campo da tabela Vaga
  String? nomeCargo;
  String? nomeCandidato;
  String? nomeVaga;
  String? nomeEmpregador;

  bool isSelected = false;

  Encaminhamento({
    this.id = -1,
    required this.idVaga,
    required this.idCandidato,
    required this.data,
    required this.status,
    required this.idUsuario,
    this.observacao,
    this.isSelected = false,
    this.dataAlteracao,
    this.idUsuarioAlteracao,
  });

  factory Encaminhamento.invalid() {
    //  Status de Encaminhamento:  encaminhado | efetivo | naoCompareceu | naoSelecionado
    return Encaminhamento(
      idVaga: -1,
      idCandidato: -1,
      data: DateTime.now(),
      status: 'Encaminhado',
      idUsuario: -1,
      observacao: '',
    );
  }

  factory Encaminhamento.fromMap(Map<String, dynamic> map) {
    final enc = Encaminhamento(
      id: map['id'],
      idVaga: map['idVaga'],
      idCandidato: map['idCandidato'],
      data: map['data'] is DateTime
          ? map['data']
          : DateTime.parse(map['data'].toString()),
      status: map['status'],
      idUsuario: map['idUsuario'],
      observacao: map['observacao'],
      idUsuarioAlteracao: map['idUsuarioAlteracao'],
    );

    if (map['dataAlteracao'] != null) {
      enc.dataAlteracao = map['dataAlteracao'] is DateTime
          ? map['dataAlteracao']
          : DateTime.tryParse(map['dataAlteracao'].toString());
    }

    if (map['nomeCargo'] != null) {
      enc.nomeCargo = map['nomeCargo'];
    }

    if (map['nomeCandidato'] != null) {
      enc.nomeCandidato = map['nomeCandidato'];
    }

    if (map['candidato'] != null) {
      enc.candidato = Candidato.fromMap(map['candidato']);
    }

    if (map['vaga'] != null) {
      enc.vaga = Vaga.fromMap(map['vaga']);
    }

    if (map['empregador'] != null) {
      enc.empregador = Empregador.fromMap(map['empregador']);
    }

    if (map['quantidadeEncaminhada'] != null) {
      enc.quantidadeEncaminhada = map['quantidadeEncaminhada'];
    }

    if (map['numeroEncaminhamentos'] != null) {
      enc.numeroEncaminhamentos = map['numeroEncaminhamentos'];
    }

    if (map['usuarioResponsavelNome'] is String) {
      enc.usuarioResponsavelNome = map['usuarioResponsavelNome'];
    }
    if (map['nomeEmpregador'] is String) {
      enc.nomeEmpregador = map['nomeEmpregador'];
    }
    if (map['dataAberturaVaga'] != null) {
      enc.dataAberturaVaga = DateTime.parse(map['dataAberturaVaga'].toString());
    }

    return enc;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'idVaga': idVaga,
      'idCandidato': idCandidato,
      'data': data.toIso8601String(),
      'status': status,
      'idUsuario': idUsuario,
      'observacao': observacao,
    };
    if (dataAlteracao != null) {
      map['dataAlteracao'] = dataAlteracao!.toIso8601String();
    }
    if (idUsuarioAlteracao != null) {
      map['idUsuarioAlteracao'] = idUsuarioAlteracao;
    }

    if (nomeCargo != null) {
      map['nomeCargo'] = nomeCargo;
    }

    if (nomeCandidato != null) {
      map['nomeCandidato'] = nomeCandidato;
    }

    if (candidato != null) {
      map['candidato'] = candidato!.toMap();
    }

    if (vaga != null) {
      map['vaga'] = vaga!.toMap();
    }

    if (empregador != null) {
      map['empregador'] = empregador!.toMap();
    }

    if (quantidadeEncaminhada != null) {
      map['quantidadeEncaminhada'] = quantidadeEncaminhada;
    }

    if (numeroEncaminhamentos != null) {
      map['numeroEncaminhamentos'] = numeroEncaminhamentos;
    }

    if (usuarioResponsavelNome != null) {
      map['usuarioResponsavelNome'] = usuarioResponsavelNome;
    }
    if (nomeEmpregador != null) {
      map['nomeEmpregador'] = nomeEmpregador;
    }
    if (dataAberturaVaga != null) {
      map['dataAberturaVaga'] = dataAberturaVaga!.toIso8601String();
    }

    return map;
  }

  Map<String, dynamic> toInsert() {
    return toMap()
      ..remove('id')
      ..remove('nomeCargo')
      ..remove('nomeCandidato')
      ..remove('candidato')
      ..remove('vaga')
      ..remove('empregador')
      ..remove('quantidadeEncaminhada')
      ..remove('numeroEncaminhamentos')
      ..remove('usuarioResponsavelNome')
      ..remove('nomeEmpregador')
      ..remove('dataAberturaVaga');
  }

  Map<String, dynamic> toUpdate() {
    return toMap()
      ..remove('id')
      ..remove('data')
      ..remove('nomeCargo')
      ..remove('nomeCandidato')
      ..remove('candidato')
      ..remove('vaga')
      ..remove('empregador')
      ..remove('quantidadeEncaminhada')
      ..remove('numeroEncaminhamentos')
      ..remove('usuarioResponsavelNome')
      ..remove('nomeEmpregador')
      ..remove('dataAberturaVaga');
  }
}
