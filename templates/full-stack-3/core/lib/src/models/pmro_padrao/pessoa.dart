import 'package:sibem_core/core.dart';

class Pessoa extends SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'pessoas';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// fully qualified id column name
  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  /// fully qualified nome column name
  static const String nomeFqCol = '$tableName.$nomeCol';
  static const String nomeCol = 'nome';
  static const String emailPrincipalCol = 'emailPrincipal';
  static const String emailAdicionalCol = 'emailAdicional';
  static const String tipoCol = 'tipo';
  static const String dataInclusaoCol = 'dataInclusao';

  /// Obrigatorio
  int id;

  /// id do cadastro no sali
  int? cgm;

  /// Obrigatorio Nome em caso de  Pessoa Fisica ou Razao Social de pessoa juridica
  String nome;

  String? emailPrincipal;
  String? emailAdicional;

  /// tipoPessoa Obrigatorio
  String tipo;

  /// Obrigatorio
  DateTime dataInclusao;

  /// Anulavél
  DateTime? dataAlteracao;

  /// url de foto da pessoa
  String? imagem;

  /// Propriedades anexadas
  int? idOrganograma;
  List<Endereco> enderecos = [];
  List<Telefone> telefones = [];
  PessoaOrigem? pessoaOrigem;

  Pessoa({
    this.id = -1,
    required this.nome,
    this.emailPrincipal,
    this.emailAdicional,
    required this.tipo,
    required this.dataInclusao,
    this.dataAlteracao,
    this.imagem,
  });

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    final pe = Pessoa(
      id: map['id'],
      nome: map['nome'],
      emailPrincipal: map['emailPrincipal'],
      emailAdicional: map['emailAdicional'],
      tipo: map['tipo'],
      dataInclusao: map['dataInclusao'] is DateTime
          ? map['dataInclusao']
          : DateTime.parse(map['dataInclusao']),
    );

    if (map['dataAlteracao'] is DateTime) {
      pe.dataAlteracao = map['dataAlteracao'];
    } else if (map['dataAlteracao'] is String) {
      pe.dataAlteracao = DateTime.tryParse(map['dataAlteracao']);
    }

    pe.imagem = map['imagem'];

    if (map.containsKey('telefones')) {
      pe.telefones = <Telefone>[];
      map['telefones'].forEach((telefone) {
        pe.telefones.add(Telefone.fromMap(telefone));
      });
    }

    if (map.containsKey('enderecos')) {
      pe.enderecos = <Endereco>[];
      map['enderecos'].forEach((end) {
        pe.enderecos.add(Endereco.fromMap(end));
      });
    }

    if (map.containsKey('pessoaOrigem')) {
      pe.pessoaOrigem = PessoaOrigem.fromMap(map['pessoaOrigem']);
    }
    return pe;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'emailPrincipal': emailPrincipal,
      'tipo': tipo,
      'dataInclusao': dataInclusao.toIso8601String(),
      'dataAlteracao': dataAlteracao?.toIso8601String(),
    };
    if (emailAdicional != null) {
      map['emailAdicional'] = emailAdicional;
    }

    if (imagem != null) {
      map['imagem'] = imagem;
    }

    if (telefones.isNotEmpty) {
      map['telefones'] = telefones.map((e) => e.toMap()).toList();
    }

    if (enderecos.isNotEmpty) {
      map['enderecos'] = enderecos.map((e) => e.toMap()).toList();
    }

    if (pessoaOrigem != null) {
      map['pessoaOrigem'] = pessoaOrigem!.toMap();
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    dataInclusao = DateTime.now();
    return toMap()
      ..remove('id')
      ..remove('dataAlteracao')
      ..remove('telefones')
      ..remove('enderecos')
      ..remove('pessoaOrigem');
  }

  Map<String, dynamic> toUpdateMap() {
    dataAlteracao = DateTime.now();
    return toMap()
      ..remove('id')
      ..remove('dataInclusao')
      ..remove('telefones')
      ..remove('enderecos')
      ..remove('pessoaOrigem')
      ..remove('tipo');
  }

  set tipoAsString(String tipo) {
    if (PessoaTipo.fisica.toString().contains(tipo)) {
      this.tipo = PessoaTipo.fisica.toString();
    } else {
      this.tipo = PessoaTipo.juridica.toString();
    }
  }

  set dataInicioAsString(value) {
    if (value is DateTime) {
      dataInclusao = value;
    } else if (value is String) {
      dataInclusao = DateTime.parse(value);
    }
  }

  String get dataAlteracaoAsString {
    final dt = dataAlteracao != null
        ? dataAlteracao!.toIso8601String().substring(0, 10)
        : '';
    return dt;
  }

  set dataAlteracaoAsString(value) {
    if (value is DateTime) {
      dataAlteracao = value;
    } else if (value is String) {
      dataAlteracao = DateTime.tryParse(value);
    }
  }
}
