import 'package:sibem_core/core.dart';

class PessoaFisica extends Pessoa {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'pessoas_fisicas';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idPessoaFqCol = '$tableName.$idPessoaCol';
  static const String idPessoaCol = 'idPessoa';
  static const String cpfCol = 'cpf';

  /// obrigatorio
  int idPessoa;

  /// obrigatorio
  String cpf;

  String? rg;
  String? orgaoEmissor;
  int? idUfOrgaoEmissor;

  /// obrigatorio
  DateTime dataNascimento;

  /// obrigatorio
  String sexo;

  String? estadoCivil;
  String? pis;
  DateTime? dataEmissao;
  int? idPaisNacionalidade;
  int? naturalidadeMunicipio;
  String? grupoSanguineo;
  String? fatorRH;
  String? profissao;
  String? nomePai;
  String? nomeMae;
  String? naturalidadeUF;

  /// Propriedade anexada
  ComplementoPessoaFisica? complementoPessoaFisica;

  PessoaFisica({
    this.idPessoa = -1,
    required this.cpf,
    this.rg,
    this.orgaoEmissor,
    this.idUfOrgaoEmissor,
    required this.dataNascimento,
    required this.sexo,
    this.estadoCivil,
    this.pis,
    this.dataEmissao,
    this.idPaisNacionalidade,
    this.naturalidadeMunicipio,
    this.grupoSanguineo,
    this.fatorRH,
    this.profissao,
    this.nomePai,
    this.nomeMae,
    this.naturalidadeUF,
    this.complementoPessoaFisica,
    //pessoa
    required String nome,
    String? emailPrincipal,
    String? emailAdicional,
    String tipo = 'fisica',
    required DateTime dataInclusao,
    DateTime? dataAlteracao,
    String? imagem,
  }) : super(
          id: idPessoa,
          nome: nome,
          dataInclusao: dataInclusao,
          emailPrincipal: emailPrincipal,
          emailAdicional: emailAdicional,
          tipo: tipo,
          dataAlteracao: dataAlteracao,
          imagem: imagem,
        );

  factory PessoaFisica.invalid() {
    return PessoaFisica(
      cpf: '',
      dataNascimento: DateTime.now(),
      sexo: 'Masculino',
      nome: '',
      dataInclusao: DateTime.now(),
    );
  }

  factory PessoaFisica.fromMap(Map<String, dynamic> map) {
    final pf = PessoaFisica(
      idPessoa: map['idPessoa'],
      cpf: map['cpf'],
      rg: map['rg'],
      orgaoEmissor: map['orgaoEmissor'],
      idUfOrgaoEmissor: map['idUfOrgaoEmissor'],
      dataNascimento: map['dataNascimento'] is String
          ? DateTime.parse(map['dataNascimento'])
          : map['dataNascimento'],
      sexo: map['sexo'],
      estadoCivil: map['estadoCivil'],
      pis: map['pis'],
      dataEmissao: map['dataEmissao'] is String
          ? DateTime.tryParse(map['dataEmissao'])
          : map['dataEmissao'],
      idPaisNacionalidade: map['idPaisNacionalidade'],
      naturalidadeMunicipio: map['naturalidadeMunicipio'],
      grupoSanguineo: map['grupoSanguineo'],
      fatorRH: map['fatorRH'],
      profissao: map['profissao'],
      nomePai: map['nomePai'],
      nomeMae: map['nomeMae'],
      naturalidadeUF: map['naturalidadeUF'],

      //pessoa
      nome: map['nome'],
      emailPrincipal: map['emailPrincipal'],
      emailAdicional: map['emailAdicional'],
      tipo: map['tipo'],
      dataInclusao: map['dataInclusao'] is DateTime
          ? map['dataInclusao']
          : DateTime.parse(map['dataInclusao']),
    );

    if (map['complementoPessoaFisica'] != null) {
      pf.complementoPessoaFisica =
          ComplementoPessoaFisica.fromMap(map['complementoPessoaFisica']);
    }

    if (map.containsKey('telefones')) {
      pf.telefones = <Telefone>[];
      map['telefones'].forEach((telefone) {
        pf.telefones.add(Telefone.fromMap(telefone));
      });
    }

    if (map.containsKey('enderecos')) {
      pf.enderecos = <Endereco>[];
      map['enderecos'].forEach((end) {
        pf.enderecos.add(Endereco.fromMap(end));
      });
    }

    if (map.containsKey('pessoaOrigem')) {
      pf.pessoaOrigem = PessoaOrigem.fromMap(map['pessoaOrigem']);
    }

    return pf;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idPessoa': idPessoa,
      'cpf': cpf,
      'rg': rg,
      'orgaoEmissor': orgaoEmissor,
      'idUfOrgaoEmissor': idUfOrgaoEmissor,
      'idPaisNacionalidade': idPaisNacionalidade,
      'sexo': sexo,
      'naturalidadeMunicipio': naturalidadeMunicipio,
      'grupoSanguineo': grupoSanguineo,
      'fatorRH': fatorRH,
      'profissao': profissao,
      'estadoCivil': estadoCivil,
      'pis': pis,
      'nomePai': nomePai,
      'nomeMae': nomeMae,
      'naturalidadeUF': naturalidadeUF,
      'dataNascimento': dataNascimento.toIso8601String(),
    };
    if (dataEmissao != null) {
      map['dataEmissao'] = dataEmissao!.toIso8601String();
    }

    map.addAll(super.toMap());

    if (complementoPessoaFisica != null) {
      map['complementoPessoaFisica'] = complementoPessoaFisica!.toMap();
    }
    return map;
  }

  Map<String, dynamic> toInsert() {
    final toRemove = [
      'id',
      'nome',
      'emailPrincipal',
      'emailAdicional',
      'tipo',
      'dataInclusao',
      'dataAlteracao',
      'imagem',
      'enderecos',
      'telefones',
      'complementoPessoaFisica',
      'pessoaOrigem'
    ];
    final map = toMap()..removeWhere((key, value) => toRemove.contains(key));
    return map;
  }

  Map<String, dynamic> toUpdate() {
    return toInsert()
      ..remove('idPessoa')
      ..remove('cpf');
  }

  Map<String, dynamic> toInsertPessoa() {
    final map = Pessoa.fromMap(toMap()).toInsertMap();
    return map;
  }

  Map<String, dynamic> toUpdatePessoa() {
    return Pessoa.fromMap(toMap()).toUpdateMap();
  }

  @override
  String toString() {
    return 'PessoaFisica(idPessoa: $idPessoa, cpf: $cpf, rg: $rg, orgaoEmissor: $orgaoEmissor, idUfOrgaoEmissor: $idUfOrgaoEmissor, dataNascimento: $dataNascimento, sexo: $sexo, estadoCivil: $estadoCivil, pis: $pis, dataEmissao: $dataEmissao, idPaisNacionalidade: $idPaisNacionalidade, naturalidadeMunicipio: $naturalidadeMunicipio, grupoSanguineo: $grupoSanguineo, fatorRH: $fatorRH, profissao: $profissao, nomePai: $nomePai, nomeMae: $nomeMae, naturalidadeUF: $naturalidadeUF)';
  }

  @override
  bool operator ==(covariant PessoaFisica other) {
    if (identical(this, other)) return true;
    return other.idPessoa == idPessoa;
  }

  @override
  int get hashCode {
    return idPessoa.hashCode;
  }
}
