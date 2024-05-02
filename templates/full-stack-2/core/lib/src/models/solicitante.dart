import 'package:esic_core/esic_core.dart';

class Solicitante implements SerializeBase {
  /// idsolicitante
  int id;

  String nome;

  /// [F]isica - [J]uridica
  String tipoPessoa;

  bool get isFisica => tipoPessoa == 'F';

  String cpfCnpj;

  String email;
  int? idTipoTelefone;
  String? dddTelefone;
  String? telefone;
  String logradouro;

  /// numero do endereço
  String numero;

  String? complemento;
  String bairro;
  String cep;
  String cidade;
  String uf;
  String? profissao;
  int? idEscolaridade;
  int? idFaixaEtaria;
  DateTime dataCadastro;

  /// Se o cadastro foi confirmado. 1-sim; 0-nao
  int confirmado;

  /// Se o cadastro foi confirmado. 1-sim; 0-nao
  bool get isConfirmado => confirmado == 1;

  DateTime? dataConfirmacao;

  /// Senha criptografada md5 cadastrado pelo usuario
  String chave = '';

  FaixaEtaria? _faixaEtaria;

  FaixaEtaria? get faixaEtaria => _faixaEtaria;

  set faixaEtaria(FaixaEtaria? f) {
    _faixaEtaria = f;
    idFaixaEtaria = f?.id;
  }

  Escolaridade? _escolaridade;

  Escolaridade? get escolaridade => _escolaridade;

  set escolaridade(Escolaridade? e) {
    _escolaridade = e;
    idEscolaridade = e?.id;
  }

  TipoTelefone? _tipoTelefone;

  TipoTelefone? get tipoTelefone => _tipoTelefone;

  set tipoTelefone(TipoTelefone? t) {
    _tipoTelefone = t;
    idTipoTelefone = t?.id;
  }

  Estado? _estado;

  Estado? get estado => _estado;

  set estado(Estado? es) {
    _estado = es;
    if (es != null) {
      uf = es.sigla;
    }
  }

  Solicitante({
    this.id = -1,
    required this.nome,
    this.tipoPessoa = 'F',
    required this.cpfCnpj,
    required this.email,
    this.idTipoTelefone,
    this.dddTelefone,
    this.telefone,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cep,
    required this.cidade,
    required this.uf,
    this.profissao,
    this.idEscolaridade,
    this.idFaixaEtaria,
    required this.dataCadastro,
    this.confirmado = 0,
    this.dataConfirmacao,
    this.chave = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'idsolicitante': id,
      'nome': nome,
      'tipopessoa': tipoPessoa,
      'cpfcnpj': cpfCnpj,
      'email': email,
      'idtipotelefone': idTipoTelefone,
      'dddtelefone': dddTelefone,
      'telefone': telefone,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'uf': uf,
      'profissao': profissao,
      'idescolaridade': idEscolaridade,
      'idfaixaetaria': idFaixaEtaria,
      'datacadastro': dataCadastro.toString(),
      'confirmado': confirmado,
    };

    if (chave.isNotEmpty) {
      map['chave'] = chave;
    }

    if (dataConfirmacao != null) {
      map['dataConfirmacao'] = dataConfirmacao?.toString();
    }

    return map;
  }

  Map<String, dynamic> toDbInsert() {
    dataCadastro = DateTime.now();
    return toMap()..remove('idsolicitante');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap()
      ..remove('idsolicitante')
      ..remove('datacadastro')
      ..remove('chave');
  }

  factory Solicitante.fromMap(Map<String, dynamic> map) {
    var sol = Solicitante(
      id: map['idsolicitante']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      tipoPessoa: map['tipopessoa'] ?? '',
      cpfCnpj: map['cpfcnpj'] ?? '',
      email: map['email'],
      idTipoTelefone: map['idtipotelefone']?.toInt(),
      dddTelefone: map['dddtelefone'],
      telefone: map['telefone'],
      logradouro: map['logradouro'] ?? '',
      numero: map['numero'] ?? '',
      complemento: map['complemento'] ?? '',
      bairro: map['bairro'] ?? '',
      cep: map['cep'] ?? '',
      cidade: map['cidade'] ?? '',
      uf: map['uf'] ?? '',
      profissao: map['profissao'],
      idEscolaridade: map['idescolaridade']?.toInt(),
      idFaixaEtaria: map['idfaixaetaria']?.toInt(),
      dataCadastro: DateTime.parse(map['datacadastro'].toString()),
      confirmado: map['confirmado']?.toInt() ?? 0,
      dataConfirmacao: map['dataconfirmacao'] != null
          ? DateTime.tryParse(map['dataconfirmacao'].toString())
          : null,
      chave: map['chave'],
    );
    if (map['escolaridade'] is Map) {
      sol.escolaridade = Escolaridade.fromMap(map['escolaridade']);
    }
    if (map['estado'] is Map) {
      sol.estado = Estado.fromMap(map['estado']);
    }
    if (map['tipoTelefone'] is Map) {
      sol.tipoTelefone = TipoTelefone.fromMap(map['tipoTelefone']);
    }
    if (map['faixaEtaria'] is Map) {
      sol.faixaEtaria = FaixaEtaria.fromMap(map['faixaEtaria']);
    }

    return sol;
  }
}
