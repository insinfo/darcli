import 'package:sibem_core/core.dart';

/// pode ser pessoa fisica ou juridica
class Empregador extends Pessoa implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'empregadores';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idPessoaCol = 'idPessoa';

  ///  para saber se este Empregador vem da web
  bool? isFromWeb;

  int idPessoa;
  DateTime dataCadastroEmpregador;
  int idDivisaoCnae;
  String contato;
  String? observacao;
  bool ativo;

  DateTime? dataAlteracaoEmpregador;
  DivisaoCnae? _divisaoCnae;
  PessoaFisica? pessoaFisica;
  PessoaJuridica? pessoaJuridica;
  bool isSelected = false;

  /// propriedade anexada nome da tabela divisoes_cnae
  String? nomeCnae;

  /// propriedade anexada
  String? nomeRespValidacao;

  /// propriedade anexada da tabela empregadores_web
  String? observacaoValidacao;

  String? get cpfOrCnpj => pessoaFisica != null
      ? pessoaFisica!.cpf
      : pessoaJuridica != null
          ? pessoaJuridica!.cnpj
          : null;

  Empregador(
      {this.idPessoa = -1,
      required this.dataCadastroEmpregador,
      required this.contato,
      this.observacao,
      required this.idDivisaoCnae,
      required this.ativo,
      this.dataAlteracaoEmpregador,
      this.isSelected = false,
      //pessoa
      required String nome,
      String? emailPrincipal,
      String? emailAdicional,
      required String tipo,
      required DateTime dataInclusao,
      DateTime? dataAlteracao,
      String? imagem,
      //
      this.observacaoValidacao,
      //anexado
      this.nomeCnae,
      this.pessoaFisica,
      this.pessoaJuridica,
      //
      this.isFromWeb})
      : super(
          id: idPessoa,
          nome: nome,
          dataInclusao: dataInclusao,
          emailPrincipal: emailPrincipal,
          emailAdicional: emailAdicional,
          tipo: tipo,
          dataAlteracao: dataAlteracao,
          imagem: imagem,
        );

  bool get isPessoaFisica {
    return tipo == 'fisica';
  }

  bool get isPessoaJuridica {
    return tipo == 'juridica';
  }

  PessoaFisica toPessoaFisica() {
    if (isPessoaFisica == false) {
      throw Exception('O tipo de pessoa `$tipo` não é fisica');
    }

    if (pessoaFisica == null) {
      throw Exception('O campo `pessoaFisica` é nulo');
    }
    final pf = pessoaFisica!;
    pf.nome = nome;
    pf.idPessoa = idPessoa;
    pf.dataInclusao = dataInclusao;
    pf.emailPrincipal = emailPrincipal;
    pf.emailAdicional = emailAdicional;
    pf.tipo = tipo;
    pf.dataAlteracao = dataAlteracao;
    pf.imagem = imagem;
    return pf;
  }

  PessoaJuridica toPessoaJuridica() {
    if (isPessoaJuridica == false) {
      throw Exception('O tipo de pessoa `$tipo` não é juridica');
    }

    if (pessoaJuridica == null) {
      throw Exception('O campo `pessoaJuridica` é nulo');
    }
    final pj = pessoaJuridica!;
    pj.nome = nome;
    pj.idPessoa = idPessoa;
    pj.dataInclusao = dataInclusao;
    pj.emailPrincipal = emailPrincipal;
    pj.emailAdicional = emailAdicional;
    pj.tipo = tipo;
    pj.dataAlteracao = dataAlteracao;
    pj.imagem = imagem;

    return pj;
  }

  // Utilizado pelo DataTable no frontend
  static List<String> status = ['active', 'inactive', 'canceled', 'paused'];

  factory Empregador.invalidJuridica() {
    final emp = Empregador(
      dataCadastroEmpregador: DateTime.now(),
      contato: '',
      idDivisaoCnae: -1,
      ativo: true,
      tipo: 'juridica',
      nome: '',
      dataInclusao: DateTime.now(),
    );

    emp.pessoaJuridica = PessoaJuridica.invalid();
    emp.telefones = emp.pessoaJuridica!.telefones = [Telefone.invalid()];
    emp.enderecos = emp.pessoaJuridica!.enderecos = [Endereco.invalid()];

    return emp;
  }

  factory Empregador.invalidFisica() {
    final emp = Empregador(
      dataCadastroEmpregador: DateTime.now(),
      contato: '',
      idDivisaoCnae: -1,
      ativo: true,
      tipo: 'fisica',
      nome: '',
      dataInclusao: DateTime.now(),
    );

    emp.pessoaFisica = PessoaFisica.invalid();
    emp.telefones = emp.pessoaFisica!.telefones = [Telefone.invalid()];
    emp.enderecos = emp.pessoaFisica!.enderecos = [Endereco.invalid()];

    return emp;
  }

  factory Empregador.fromMap(Map<String, dynamic> map) {
    final emp = Empregador(
      idPessoa: map['idPessoa'],
      dataCadastroEmpregador: map['dataCadastroEmpregador'] is DateTime
          ? map['dataCadastroEmpregador']
          : DateTime.parse(map['dataCadastroEmpregador']),
      contato: map['contato'],
      observacao: map['observacao'],
      idDivisaoCnae: map['idDivisaoCnae'],
      ativo: map['ativo'],
      //pessoa
      nome: map['nome'],
      emailPrincipal: map['emailPrincipal'],
      emailAdicional: map['emailAdicional'],
      tipo: map['tipo'],
      dataInclusao: map['dataInclusao'] is DateTime
          ? map['dataInclusao']
          : DateTime.parse(map['dataInclusao']),
    );
    if (map.containsKey('dataAlteracaoEmpregador') &&
        map['dataAlteracaoEmpregador'] != null) {
      emp.dataAlteracaoEmpregador =
          DateTime.parse(map['dataAlteracaoEmpregador'].toString());
    }
    if (map.containsKey('nomeCnae') && map['nomeCnae'] != null) {
      emp.nomeCnae = map['nomeCnae'];
    }

    if (map.containsKey('telefones')) {
      emp.telefones = <Telefone>[];
      map['telefones'].forEach((telefone) {
        emp.telefones.add(Telefone.fromMap(telefone));
      });
    }

    if (map.containsKey('enderecos')) {
      emp.enderecos = <Endereco>[];
      map['enderecos'].forEach((end) {
        emp.enderecos.add(Endereco.fromMap(end));
      });
    }

    if (map.containsKey('pessoaOrigem')) {
      emp.pessoaOrigem = PessoaOrigem.fromMap(map['pessoaOrigem']);
    }

    if (map['pessoaFisica'] is PessoaFisica) {
      emp.pessoaFisica = map['pessoaFisica'];
    } else if (map['pessoaFisica'] is Map) {
      emp.pessoaFisica = PessoaFisica.fromMap(map['pessoaFisica']);
    }

    if (map['pessoaJuridica'] is PessoaJuridica) {
      emp.pessoaJuridica = map['pessoaJuridica'];
    } else if (map['pessoaJuridica'] is Map) {
      emp.pessoaJuridica = PessoaJuridica.fromMap(map['pessoaJuridica']);
    }

    if (map['isFromWeb'] != null) {
      emp.isFromWeb = map['isFromWeb'];
    }
    if (map['nomeRespValidacao'] != null) {
      emp.nomeRespValidacao = map['nomeRespValidacao'];
    }
    if (map['observacaoValidacao'] != null) {
      emp.observacaoValidacao = map['observacaoValidacao'];
    }

    return emp;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idPessoa': idPessoa,
      'dataCadastroEmpregador': dataCadastroEmpregador.toIso8601String(),
      'contato': contato,
      'idDivisaoCnae': idDivisaoCnae,
      'ativo': ativo,
    };

    map.addAll(super.toMap());

    if (observacao != null) {
      map['observacao'] = observacao;
    }
    if (nomeCnae != null) {
      map['nomeCnae'] = observacao;
    }

    if (dataAlteracaoEmpregador != null) {
      map['dataAlteracaoEmpregador'] =
          dataAlteracaoEmpregador!.toIso8601String();
    }
    if (pessoaFisica != null) {
      map['pessoaFisica'] = pessoaFisica!.toMap();
    }
    if (pessoaJuridica != null) {
      map['pessoaJuridica'] = pessoaJuridica!.toMap();
    }
    if (isFromWeb != null) {
      map['isFromWeb'] = isFromWeb;
    }
    if (nomeRespValidacao != null) {
      map['nomeRespValidacao'] = nomeRespValidacao;
    }
    if (observacaoValidacao != null) {
      map['observacaoValidacao'] = observacaoValidacao;
    }

    return map;
  }

  /// Usado apenas para inserção de dados no banco
  Map<String, dynamic> toInsertMap() {
    dataCadastroEmpregador = DateTime.now();
    final map = <String, dynamic>{
      'idPessoa': idPessoa,
      'dataCadastroEmpregador': dataCadastroEmpregador.toIso8601String(),
      'contato': contato,
      'idDivisaoCnae': idDivisaoCnae,
      'ativo': ativo,
    };
    if (observacao != null) {
      map['observacao'] = observacao;
    }
    if (dataAlteracaoEmpregador != null) {
      map['dataAlteracaoEmpregador'] = dataAlteracaoEmpregador;
    }
    if (isFromWeb != null) {
      map['isFromWeb'] = isFromWeb;
    }

    return map;
  }

  /// Usado apenas para alteração dos dados no banco
  Map<String, dynamic> toUpdateMap() {
    dataAlteracaoEmpregador = DateTime.now();
    return toInsertMap()
      ..remove('dataCadastroEmpregador')
      ..remove('nomeRespValidacao')
      ..remove('observacaoValidacao');
  }

  DivisaoCnae? get divisaoCnae {
    return _divisaoCnae;
  }

  set divisaoCnae(DivisaoCnae? divisaoCnae) {
    idDivisaoCnae = divisaoCnae != null ? divisaoCnae.id : idDivisaoCnae;
    _divisaoCnae = divisaoCnae;
  }
}
