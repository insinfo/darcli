import 'package:sibem_core/core.dart';

class Endereco implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'enderecos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  String? cep;
  int idPais;
  int? idBairro;
  String logradouro;

  /// Se verdadeiro indica que o endereco foi validado na base dos correios
  bool validacao;
  int? idMunicipio;
  int? idUf;

  /// Se verdadeiro indica que o endereco esta correto mesmo sendo divergente do encontrado nas bases do correios
  bool? divergente;

  /// 'Rua','Avenida','Alameda','Beco','Estrada','Praça','Quadra','Rodovia','Travessa','Largo'
  String? tipoLogradouro;

  //Campos da tabela pessoa_endereço
  int? idPessoa;
  int? idEndereco;
  String? tipo;
  String? numero;
  String? complemento;
  String? nomeMunicipio;
  String? nomeBairro;
  String? nomeUf;

  Endereco({
    this.id = -1,
    this.cep,
    required this.idPais,
    this.idBairro,
    required this.logradouro,
    required this.validacao,
    this.idMunicipio,
    this.idUf,
    this.divergente,
    this.tipoLogradouro,
    //Campos da tabela pessoa_endereço
    this.idPessoa,
    this.idEndereco,
    this.tipo,
    this.numero,
    this.complemento,
    this.nomeMunicipio,
    this.nomeBairro,
    this.nomeUf,
  });

  factory Endereco.invalid() {
    return Endereco(
      //33 BRASIL
      idPais: 33,
      //20 RIO DE JANEIRO
      idUf: 20,
      //3242 city
      idMunicipio: 3242,
      logradouro: '',
      validacao: false,
      tipoLogradouro: 'Avenida',
      tipo: 'Comercial',
    );
  }

  factory Endereco.fromMap(Map<String, dynamic> map) {
    final end = Endereco(
        id: map['id'],
        cep: map['cep'],
        idPais: map['idPais'],
        idUf: map['idUf'],
        idBairro: map['idBairro'],
        logradouro: map['logradouro'],
        validacao: map['validacao'],
        idMunicipio: map['idMunicipio'],
        divergente: map['divergente'],
        tipoLogradouro: map['tipoLogradouro']);

    if (map.containsKey('idPessoa')) {
      end.idPessoa = map['idPessoa'];
    }

    if (map.containsKey('idEndereco')) {
      end.idEndereco = map['idEndereco'];
    }

    if (map.containsKey('tipo')) {
      end.tipo = map['tipo'];
    }

    if (map.containsKey('complemento')) {
      end.complemento = map['complemento'];
    }

    if (map.containsKey('numero')) {
      end.numero = map['numero'];
    }

    if (map.containsKey('nomeMunicipio')) {
      end.nomeMunicipio = map['nomeMunicipio'];
    }

    if (map.containsKey('nomeBairro')) {
      end.nomeBairro = map['nomeBairro'];
    }
    return end;
  }

  factory Endereco.fromCep(Map<String, dynamic> map) {
    final end = Endereco(
        id: map['id'],
        idPais: map['idPais'],
        validacao: map['validacao'],
        tipoLogradouro: map['tipoLogradouro'],
        logradouro: map['logradouro'],
        nomeBairro: map['bairro'],
        nomeMunicipio: map['municipio'],
        nomeUf: map['uf'],
        cep: map['cep'],
        idBairro: map['idBairro'],
        idMunicipio: map['idMunicipio'],
        idUf: map['idUf']);

    if (map.containsKey('idPessoa')) {
      end.idPessoa = map['idPessoa'];
    }

    if (map.containsKey('idEndereco')) {
      end.idEndereco = map['idEndereco'];
    }
    if (map.containsKey('tipo')) {
      end.tipo = map['tipo'];
    }
    if (map.containsKey('numero')) {
      end.numero = map['numero'];
    }
    if (map.containsKey('complemento')) {
      end.complemento = map['complemento'];
    }

    return end;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'cep': cep,
      'idPais': idPais,
      'idBairro': idBairro,
      'logradouro': logradouro,
      'validacao': validacao,
      'idMunicipio': idMunicipio,
      'idUf': idUf,
      'divergente': divergente,
      'tipoLogradouro': tipoLogradouro,
      'numero': numero,
      'idEndereco': idEndereco,
      'tipo': tipo,
    };
    if (idPessoa != null) {
      map['idPessoa'] = idPessoa;
    }

    if (complemento != null) {
      map['complemento'] = complemento;
    }
    if (nomeMunicipio != null) {
      map['nomeMunicipio'] = nomeMunicipio;
    }
    if (nomeBairro != null) {
      map['nomeBairro'] = nomeBairro;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return <String, dynamic>{
      'cep': cep,
      'idPais': idPais,
      'idBairro': idBairro,
      'logradouro': logradouro,
      'validacao': validacao,
      'idMunicipio': idMunicipio,
      'idUf': idUf,
      'divergente': divergente,
      'tipoLogradouro': tipoLogradouro
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return toInsertMap()..remove('id');
  }

  Map<String, dynamic> toInsertPessoaEndereco() {
    return <String, dynamic>{
      'idPessoa': idPessoa,
      'idEndereco': idEndereco,
      'tipo': tipo,
      'numero': numero,
      'complemento': complemento,
    };
  }

  @override
  String toString() {
    return 'Endereco(cep: $cep, idPais: $idPais, idBairro: $idBairro, logradouro: $logradouro, validacao: $validacao, idMunicipio: $idMunicipio, idUf: $idUf, divergente: $divergente, tipoLogradouro: $tipoLogradouro)';
  }
}
