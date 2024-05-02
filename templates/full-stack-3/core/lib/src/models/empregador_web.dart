import 'package:sibem_core/core.dart';

class EmpregadorStatusValidacao {
  final String value;

  const EmpregadorStatusValidacao(this.value);

  static const EmpregadorStatusValidacao pendente =
      EmpregadorStatusValidacao('pendente');

  static const EmpregadorStatusValidacao validado =
      EmpregadorStatusValidacao('validado');

  static const EmpregadorStatusValidacao cancelado =
      EmpregadorStatusValidacao('cancelado');

  static EmpregadorStatusValidacao fromString(String val) {
    switch (val) {
      case 'cancelado':
        return EmpregadorStatusValidacao.cancelado;
      case 'validado':
        return EmpregadorStatusValidacao.validado;
      case 'pendente':
        return EmpregadorStatusValidacao.pendente;
      default:
        throw Exception('EmpregadorStatusValidacao desconhecido');
    }
  }

  static const List<String> listar = ['cancelado', 'validado', 'pendente'];
}

class EmpregadorWeb implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'empregadores_web';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String statusValidacaoFqCol = '$tableName.$statusValidacaoCol';
  static const String usuarioRespValidacaoFqCol =
      '$tableName.$usuarioRespValidacaoCol';

  /// nome da coluna statusValidacao na tabela empregadores_web do banco de dados
  static const String statusValidacaoCol = 'statusValidacao';
  static const String idCol = 'id';
  static const String idCnaeCol = 'idCnae';
  static const String usuarioRespValidacaoCol = 'usuarioRespValidacao';

  int id;

  /// tipoPessoa
  String tipo;

  bool get isPessoaFisica {
    return tipo == 'fisica';
  }

  bool get isPessoaJuridica {
    return tipo == 'juridica';
  }

  String cpfOrCnpj;
  String nome;
  int idCnae;
  String? nomeFantasia;
  String? inscricaoEstadual;
  String emailPrincipal;
  String? contato;
  String? observacao;
  String tipoTelefone;
  String telefone;
  String? cep;
  String tipoEndereco;
  int idUf;
  int idMunicipio;
  String tipoLogradouro;
  String logradouro;
  String numeroEndereco;
  String bairro;
  String? complementoEndereco;
  String? rg;
  DateTime? dataEmissao;
  String? orgaoEmissor;
  int? idUfOrgaoEmissor;
  String? sexo;
  String? estadoCivil;
  DateTime? dataNascimento;
  String? pis;

  DateTime dataCadastro;

  /// cancelado, validado, pendente
  EmpregadorStatusValidacao? statusValidacao;
  String? observacaoValidacao;

  DateTime? dataValidacao;
  int? usuarioRespValidacao;

  /// propriedade anexada
  String? nomeCnae;

  /// propriedade anexada
  String? nomeRespValidacao;

  EmpregadorWeb({
    required this.id,
    required this.tipo,
    required this.cpfOrCnpj,
    required this.nome,
    required this.idCnae,
    this.nomeFantasia,
    this.inscricaoEstadual,
    required this.emailPrincipal,
    this.contato,
    this.observacao,
    required this.tipoTelefone,
    required this.telefone,
    this.cep,
    required this.tipoEndereco,
    required this.idUf,
    required this.idMunicipio,
    required this.tipoLogradouro,
    required this.logradouro,
    required this.numeroEndereco,
    required this.bairro,
    this.complementoEndereco,
    this.rg,
    this.dataEmissao,
    this.orgaoEmissor,
    this.idUfOrgaoEmissor,
    this.sexo,
    this.estadoCivil,
    this.dataNascimento,
    this.pis,
    required this.dataCadastro,
    this.statusValidacao = EmpregadorStatusValidacao.pendente,
    this.observacaoValidacao,
    this.dataValidacao,
    this.usuarioRespValidacao,
  });

  factory EmpregadorWeb.invalidJuridica() {
    return EmpregadorWeb(
        id: -1,
        tipo: 'juridica',
        cpfOrCnpj: '',
        nome: '',
        idCnae: -1,
        emailPrincipal: '',
        tipoTelefone: '',
        telefone: '',
        tipoEndereco: '',
        idUf: -1,
        idMunicipio: -1,
        tipoLogradouro: '',
        logradouro: '',
        numeroEndereco: '',
        bairro: '',
        dataCadastro: DateTime.now());
  }

  factory EmpregadorWeb.invalidFisica() {
    return EmpregadorWeb(
        id: -1,
        tipo: 'fisica',
        cpfOrCnpj: '',
        nome: '',
        idCnae: -1,
        emailPrincipal: '',
        tipoTelefone: '',
        telefone: '',
        tipoEndereco: '',
        idUf: -1,
        idMunicipio: -1,
        tipoLogradouro: '',
        logradouro: '',
        numeroEndereco: '',
        bairro: '',
        dataCadastro: DateTime.now());
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'tipo': tipo,
      'cpfOrCnpj': cpfOrCnpj,
      'nome': nome,
      'idCnae': idCnae,
      'nomeFantasia': nomeFantasia,
      'inscricaoEstadual': inscricaoEstadual,
      'emailPrincipal': emailPrincipal,
      'contato': contato,
      'observacao': observacao,
      'tipoTelefone': tipoTelefone,
      'telefone': telefone,
      'cep': cep,
      'tipoEndereco': tipoEndereco,
      'idUf': idUf,
      'idMunicipio': idMunicipio,
      'tipoLogradouro': tipoLogradouro,
      'logradouro': logradouro,
      'numeroEndereco': numeroEndereco,
      'bairro': bairro,
      'complementoEndereco': complementoEndereco,
      'rg': rg,
      'dataEmissao': dataEmissao?.toIso8601String(),
      'orgaoEmissor': orgaoEmissor,
      'idUfOrgaoEmissor': idUfOrgaoEmissor,
      'sexo': sexo,
      'estadoCivil': estadoCivil,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'pis': pis,
      'dataCadastro': dataCadastro.toIso8601String(),
      'dataValidacao': dataValidacao?.toIso8601String(),
      'usuarioRespValidacao': usuarioRespValidacao,
      'nomeRespValidacao': nomeRespValidacao,
    };
    if (nomeCnae != null) {
      map['nomeCnae'] = nomeCnae;
    }
    if (statusValidacao != null) {
      map['statusValidacao'] = statusValidacao!.value;
    }
    if (observacaoValidacao != null) {
      map['observacaoValidacao'] = observacaoValidacao;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    cpfOrCnpj = cpfOrCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    dataCadastro = DateTime.now();
    return toMap()
      ..remove('id')
      ..remove('nomeCnae')
      ..remove('nomeRespValidacao');
  }

  Map<String, dynamic> toUpdateMap() {
    cpfOrCnpj = cpfOrCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    return toMap()
      ..remove('id')
      ..remove('dataCadastro')
      ..remove('nomeCnae')
      ..remove('nomeRespValidacao');
  }

  factory EmpregadorWeb.fromMap(Map<String, dynamic> map) {
    final empr = EmpregadorWeb(
      id: map['id'],
      tipo: map['tipo'],
      cpfOrCnpj: map['cpfOrCnpj'],
      nome: map['nome'] as String,
      idCnae: map['idCnae'] as int,
      nomeFantasia:
          map['nomeFantasia'] != null ? map['nomeFantasia'] as String : null,
      inscricaoEstadual: map['inscricaoEstadual'] != null
          ? map['inscricaoEstadual'] as String
          : null,
      emailPrincipal: map['emailPrincipal'] as String,
      contato: map['contato'] != null ? map['contato'] as String : null,
      observacao:
          map['observacao'] != null ? map['observacao'] as String : null,
      tipoTelefone: map['tipoTelefone'] as String,
      telefone: map['telefone'] as String,
      cep: map['cep'] != null ? map['cep'] as String : null,
      tipoEndereco: map['tipoEndereco'] as String,
      idUf: map['idUf'] as int,
      idMunicipio: map['idMunicipio'] as int,
      tipoLogradouro: map['tipoLogradouro'] as String,
      logradouro: map['logradouro'] as String,
      numeroEndereco: map['numeroEndereco'] as String,
      bairro: map['bairro'] as String,
      complementoEndereco: map['complementoEndereco'] != null
          ? map['complementoEndereco'] as String
          : null,
      rg: map['rg'] != null ? map['rg'] as String : null,
      dataEmissao: map['dataEmissao'] != null
          ? DateTime.tryParse(map['dataEmissao'])
          : null,
      orgaoEmissor:
          map['orgaoEmissor'] != null ? map['orgaoEmissor'] as String : null,
      idUfOrgaoEmissor: map['idUfOrgaoEmissor'] != null
          ? map['idUfOrgaoEmissor'] as int
          : null,
      sexo: map['sexo'] != null ? map['sexo'] as String : null,
      estadoCivil:
          map['estadoCivil'] != null ? map['estadoCivil'] as String : null,
      dataNascimento: map['dataNascimento'] != null
          ? DateTime.tryParse(map['dataNascimento'])
          : null,
      pis: map['pis'] != null ? map['pis'] as String : null,
      dataCadastro: DateTime.parse(map['dataCadastro'].toString()),
      dataValidacao: DateTime.tryParse(map['dataValidacao'].toString()),
      usuarioRespValidacao: map['usuarioRespValidacao'],
    );

    if (map['statusValidacao'] != null) {
      empr.statusValidacao =
          EmpregadorStatusValidacao.fromString(map['statusValidacao']);
    }
    if (map['observacaoValidacao'] != null) {
      empr.observacaoValidacao = map['observacaoValidacao'];
    }
    if (map['nomeCnae'] != null) {
      empr.nomeCnae = map['nomeCnae'];
    }
    if (map['nomeRespValidacao'] != null) {
      empr.nomeRespValidacao = map['nomeRespValidacao'];
    }

    return empr;
  }

  @override
  bool operator ==(covariant EmpregadorWeb other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
