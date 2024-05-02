import 'package:sibem_core/core.dart';

class PessoaJuridica extends Pessoa {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'pessoas_juridicas';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idPessoaCol = 'idPessoa';
  static const String cnpjCol = 'cnpj';

  int idPessoa; //! Obrigatorio
  String cnpj; //! Obrigatorio
  String nomeFantasia; //! Obrigatorio
  String? inscricaoEstadual;

  factory PessoaJuridica.invalid() {
    return PessoaJuridica(
      cnpj: '',
      nomeFantasia: '',
      nome: '',
      dataInclusao: DateTime.now(),
    );
  }
  PessoaJuridica({
    this.idPessoa = -1,
    required this.cnpj,
    required this.nomeFantasia,
    this.inscricaoEstadual,
    //pessoa
    required String nome,
    String? emailPrincipal,
    String? emailAdicional,
    String tipo = 'juridica',
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

  factory PessoaJuridica.fromMap(Map<String, dynamic> map) {
    final pj = PessoaJuridica(
      idPessoa: map['idPessoa'],
      cnpj: map['cnpj'],
      nomeFantasia: map['nomeFantasia'],
      inscricaoEstadual: map['inscricaoEstadual'],
      //pessoa
      nome: map['nome'],
      emailPrincipal: map['emailPrincipal'],
      emailAdicional: map['emailAdicional'],
      tipo: map['tipo'],
      dataInclusao: map['dataInclusao'] is DateTime
          ? map['dataInclusao']
          : DateTime.parse(map['dataInclusao']),
    );

    if (map.containsKey('telefones')) {
      pj.telefones = <Telefone>[];
      map['telefones'].forEach((telefone) {
        pj.telefones.add(Telefone.fromMap(telefone));
      });
    }

    if (map.containsKey('enderecos')) {
      pj.enderecos = <Endereco>[];
      map['enderecos'].forEach((end) {
        pj.enderecos.add(Endereco.fromMap(end));
      });
    }

    if (map.containsKey('pessoaOrigem')) {
      pj.pessoaOrigem = PessoaOrigem.fromMap(map['pessoaOrigem']);
    }

    return pj;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idPessoa': idPessoa,
      'cnpj': cnpj,
      'nomeFantasia': nomeFantasia,
      'inscricaoEstadual': inscricaoEstadual
    };
    map.addAll(super.toMap());
    return map;
  }

  Map<String, dynamic> toInsertMap() {
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
      'telefones'
    ];
    final map = toMap()
      ..remove('pessoaOrigem')
      ..removeWhere((key, value) => toRemove.contains(key));
    return map;
  }

  Map<String, dynamic> toUpdate() {
    return toInsertMap()
      ..remove('idPessoa')
      ..remove('cnpj');
  }

  Map<String, dynamic> toInsertPessoa() {
    var map = Pessoa.fromMap(toMap()).toInsertMap();
    return map;
  }

  Map<String, dynamic> toUpdatePessoa() {
    return Pessoa.fromMap(toMap()).toUpdateMap();
  }
}










/**
 * HELP
 * ====
 * super --> Chama o construtor da classe pai, que é Pessoa, que é uma classe abstrata e não pode ser instanciada, apenas herdada. 
 * super.fromMap(map) --> Método que recebe um mapa como parâmetro e retorna um objeto do tipo Pessoa.
 * map.addAll(super.toMap()) --> Método que recebe um mapa como parâmetro e retorna um mapa com os dados da classe Pessoa.
 * Map<String, dynamic> --> Tipo do mapa que será retornado, ou seja, o tipo de dados que será armazenado no mapa.
 * 
 */
