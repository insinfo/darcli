import 'package:sibem_core/core.dart';

class CandidatoWeb implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'candidatos_web';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// nome da coluna na tabela do banco de dados
  static const String validadoCol = 'validado';

  int id;
  DateTime dataCadastro;
  String nome;
  String cpf;
  String rg;
  String orgaoEmissor;

  DateTime? dataEmissao;
  DateTime dataNascimento;

  DateTime? get dataNascimentoField {
    return dataNascimento.year == 1700 ? null : dataNascimento;
  }

  set dataNascimentoField(DateTime? val) {
    if (val != null) {
      dataNascimento = val;
    }
  }

  int? idUfOrgaoEmissor;

  /// varchar 10
  String sexoBiologico;
  String? identidadeGenero;
  DateTime? dataInicialResidenciaRO;
  DateTime dataInicialResidenciaAtual;

  DateTime? get dataInicialResidenciaAtualField {
    return dataInicialResidenciaAtual.year == 1700
        ? null
        : dataInicialResidenciaAtual;
  }

  set dataInicialResidenciaAtualField(DateTime? val) {
    if (val != null) {
      dataInicialResidenciaAtual = val;
    }
  }

  String? cep;
  String? tipoEndereco;
  int idUf;
  int? idMunicipio;
  String? bairro;
  String? tipoLogradouro;
  String logradouro;
  String? numeroEndereco;
  String? complementoEndereco;

  String emailPrincipal;
  String tipoTelefone;
  String telefone;
  int idEscolaridade;
  String estadoCivil;
  String rendaFamiliar;
  int nrDependentes;
  String? nrCertificadoReservista;
  String? pis;
  String? nrTituloEleitor;
  int? zonaTituloEleitor;
  String? nrCarteiraProfissional;
  String? nrSerieCarteiraProfissional;
  String? referenciaPessoal;
  String? categoriaHabilitacao;

  int? idCargo1;
  int? idCargo2;
  int? idCargo3;

  bool? experienciaCargo1;
  bool? experienciaCargo2;
  bool? experienciaCargo3;

  int? tempoExperienciaFormal1;
  int? tempoExperienciaInformal1;
  int? tempoExperienciaMei1;

  int? tempoExperienciaFormal2;
  int? tempoExperienciaInformal2;
  int? tempoExperienciaMei2;

  int? tempoExperienciaFormal3;
  int? tempoExperienciaInformal3;
  int? tempoExperienciaMei3;

  bool validado;
  DateTime? dataValidacao;
  int? usuarioRespValidacao;

  bool deficiente;
  String? cid;
  int? idTipoDeficiencia;
  //
  bool? fumante;
  int? idConhecimentoExtra1;
  int? idConhecimentoExtra2;
  int? idConhecimentoExtra3;
  int? idConhecimentoExtra4;
  String? conhecimentoExtraNivel1;
  String? conhecimentoExtraNivel2;
  String? conhecimentoExtraNivel3;
  String? conhecimentoExtraNivel4;

  int? idCurso1;
  int? idCurso2;
  int? idCurso3;
  int? idCurso4;
  int? idCurso5;
  int? idCurso6;
  DateTime? dataConclusaoCurso1;
  DateTime? dataConclusaoCurso2;
  DateTime? dataConclusaoCurso3;
  DateTime? dataConclusaoCurso4;
  DateTime? dataConclusaoCurso5;
  DateTime? dataConclusaoCurso6;

  /// propriedade anexada
  String? nomeCargo1;
  String? nomeCargo2;
  String? nomeCargo3;
  String? nomeRespValidacao;
  String? nomeCurso1;
  String? nomeCurso2;
  String? nomeCurso3;
  String? nomeCurso4;
  String? nomeCurso5;
  String? nomeCurso6;

  String? nomeConhecimentoExtra1;
  String? nomeConhecimentoExtra2;
  String? nomeConhecimentoExtra3;
  String? nomeConhecimentoExtra4;
  //

  CandidatoWeb({
    this.id = -1,
    required this.dataCadastro,
    required this.nome,
    required this.cpf,
    required this.rg,
    this.orgaoEmissor = '',
    required this.dataNascimento,
    this.idUfOrgaoEmissor,
    required this.sexoBiologico,
    this.identidadeGenero,
    this.dataInicialResidenciaRO,
    required this.dataInicialResidenciaAtual,
    this.cep,
    this.tipoEndereco,
    required this.idUf,
    this.idMunicipio,
    this.bairro,
    this.tipoLogradouro,
    required this.logradouro,
    this.numeroEndereco,
    this.complementoEndereco,
    required this.emailPrincipal,
    required this.tipoTelefone,
    required this.telefone,
    required this.idEscolaridade,
    required this.estadoCivil,
    required this.rendaFamiliar,
    required this.nrDependentes,
    this.nrCertificadoReservista,
    this.pis,
    this.nrTituloEleitor,
    this.zonaTituloEleitor,
    this.nrCarteiraProfissional,
    this.nrSerieCarteiraProfissional,
    this.referenciaPessoal,
    this.categoriaHabilitacao,
    this.idCargo1,
    this.idCargo2,
    this.idCargo3,
    this.experienciaCargo1,
    this.experienciaCargo2,
    this.experienciaCargo3,
    this.validado = false,
    this.dataValidacao,
    this.usuarioRespValidacao,
    this.deficiente = false,
    this.cid,
    this.idTipoDeficiencia,
    this.dataEmissao,
    //
    this.nomeCargo1,
    this.nomeCargo2,
    this.nomeCargo3,
    this.nomeRespValidacao,
    //
    this.fumante,
    this.idConhecimentoExtra1,
    this.idConhecimentoExtra2,
    this.idConhecimentoExtra3,
    this.idConhecimentoExtra4,
    this.conhecimentoExtraNivel1,
    this.conhecimentoExtraNivel2,
    this.conhecimentoExtraNivel3,
    this.conhecimentoExtraNivel4,
    this.idCurso1,
    this.idCurso2,
    this.idCurso3,
    this.idCurso4,
    this.idCurso5,
    this.idCurso6,
    this.dataConclusaoCurso1,
    this.dataConclusaoCurso2,
    this.dataConclusaoCurso3,
    this.dataConclusaoCurso4,
    this.dataConclusaoCurso5,
    this.dataConclusaoCurso6,
    //
    this.tempoExperienciaFormal1,
    this.tempoExperienciaInformal1,
    this.tempoExperienciaMei1,
    this.tempoExperienciaFormal2,
    this.tempoExperienciaInformal2,
    this.tempoExperienciaMei2,
    this.tempoExperienciaFormal3,
    this.tempoExperienciaInformal3,
    this.tempoExperienciaMei3,
  });

  factory CandidatoWeb.invalid() {
    return CandidatoWeb(
        validado: false,
        dataCadastro: DateTime.now(),
        nome: '',
        cpf: '',
        rg: '',
        dataNascimento: DateTime(1700),
        orgaoEmissor: '',
        sexoBiologico: '',
        dataInicialResidenciaAtual: DateTime(1700),
        emailPrincipal: '',
        tipoTelefone: '',
        telefone: '',
        idEscolaridade: -1,
        estadoCivil: '',
        rendaFamiliar: '',
        nrDependentes: 0,
        idUf: -1,
        nrCarteiraProfissional: '',
        nrSerieCarteiraProfissional: '',
        categoriaHabilitacao: '',
        logradouro: '',
        tipoEndereco: 'Residencial');
  }

  Map<String, dynamic> toInsertMap() {
    dataCadastro = DateTime.now();
    return toMap()
      ..remove('id')
      ..remove('nomeRespValidacao')
      ..remove('nomeCargo3')
      ..remove('nomeCargo2')
      ..remove('nomeCargo1');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('dataCadastro')
      ..remove('nomeRespValidacao')
      ..remove('nomeCargo3')
      ..remove('nomeCargo2')
      ..remove('nomeCargo1');
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'dataCadastro': dataCadastro.toIso8601String(),
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'orgaoEmissor': orgaoEmissor,
      'dataEmissao': dataEmissao?.toIso8601String(),
      'dataNascimento': dataNascimento.toIso8601String(),
      'idUfOrgaoEmissor': idUfOrgaoEmissor,
      'sexoBiologico': sexoBiologico,
      'identidadeGenero': identidadeGenero,
      'dataInicialResidenciaRO': dataInicialResidenciaRO?.toIso8601String(),
      'dataInicialResidenciaAtual':
          dataInicialResidenciaAtual.toIso8601String(),
      'cep': cep,
      'tipoEndereco': tipoEndereco,
      'idUf': idUf,
      'idMunicipio': idMunicipio,
      'bairro': bairro,
      'tipoLogradouro': tipoLogradouro,
      'logradouro': logradouro,
      'numeroEndereco': numeroEndereco,
      'complementoEndereco': complementoEndereco,
      'emailPrincipal': emailPrincipal,
      'tipoTelefone': tipoTelefone,
      'telefone': telefone,
      'idEscolaridade': idEscolaridade,
      'estadoCivil': estadoCivil,
      'rendaFamiliar': rendaFamiliar,
      'nrDependentes': nrDependentes,
      'nrCertificadoReservista': nrCertificadoReservista,
      'pis': pis,
      'nrTituloEleitor': nrTituloEleitor,
      'zonaTituloEleitor': zonaTituloEleitor,
      'nrCarteiraProfissional': nrCarteiraProfissional,
      'nrSerieCarteiraProfissional': nrSerieCarteiraProfissional,
      'referenciaPessoal': referenciaPessoal,
      'categoriaHabilitacao': categoriaHabilitacao,
      'idCargo1': idCargo1,
      'idCargo2': idCargo2,
      'idCargo3': idCargo3,
      'experienciaCargo1': experienciaCargo1,
      'experienciaCargo2': experienciaCargo2,
      'experienciaCargo3': experienciaCargo3,
      'validado': validado,
      'dataValidacao': dataValidacao?.toIso8601String(),
      'usuarioRespValidacao': usuarioRespValidacao,
      'deficiente': deficiente,
      'cid': cid,
      'idTipoDeficiencia': idTipoDeficiencia,
      'fumante': fumante,
      'idConhecimentoExtra1': idConhecimentoExtra1,
      'idConhecimentoExtra2': idConhecimentoExtra2,
      'idConhecimentoExtra3': idConhecimentoExtra3,
      'idConhecimentoExtra4': idConhecimentoExtra4,
      'conhecimentoExtraNivel1': conhecimentoExtraNivel1,
      'conhecimentoExtraNivel2': conhecimentoExtraNivel2,
      'conhecimentoExtraNivel3': conhecimentoExtraNivel3,
      'conhecimentoExtraNivel4': conhecimentoExtraNivel4,
      'idCurso1': idCurso1,
      'idCurso2': idCurso2,
      'idCurso3': idCurso3,
      'idCurso4': idCurso4,
      'idCurso5': idCurso5,
      'idCurso6': idCurso6,
      'dataConclusaoCurso1': dataConclusaoCurso1?.toIso8601String(),
      'dataConclusaoCurso2': dataConclusaoCurso2?.toIso8601String(),
      'dataConclusaoCurso3': dataConclusaoCurso3?.toIso8601String(),
      'dataConclusaoCurso4': dataConclusaoCurso4?.toIso8601String(),
      'dataConclusaoCurso5': dataConclusaoCurso5?.toIso8601String(),
      'dataConclusaoCurso6': dataConclusaoCurso6?.toIso8601String(),
      'tempoExperienciaFormal1': tempoExperienciaFormal1,
      'tempoExperienciaInformal1': tempoExperienciaInformal1,
      'tempoExperienciaMei1': tempoExperienciaMei1,
      'tempoExperienciaFormal2': tempoExperienciaFormal2,
      'tempoExperienciaInformal2': tempoExperienciaInformal2,
      'tempoExperienciaMei2': tempoExperienciaMei2,
      'tempoExperienciaFormal3': tempoExperienciaFormal3,
      'tempoExperienciaInformal3': tempoExperienciaInformal3,
      'tempoExperienciaMei3': tempoExperienciaMei3,
    };
    if (map.containsKey('dataCadastro')) {
      map['dataCadastro'] = dataCadastro.toIso8601String();
    }
    if (map.containsKey('nomeRespValidacao')) {
      map['nomeRespValidacao'] = nomeRespValidacao;
    }
    if (map.containsKey('nomeCargo3')) {
      map['nomeCargo3'] = nomeCargo3;
    }
    if (map.containsKey('nomeCargo2')) {
      map['nomeCargo2'] = nomeCargo2;
    }
    if (map.containsKey('nomeCargo1')) {
      map['nomeCargo1'] = nomeCargo1;
    }
    return map;
  }

  factory CandidatoWeb.fromMap(Map<String, dynamic> map) {
    final cand = CandidatoWeb(
      id: map['id'],
      dataCadastro: map['dataCadastro'] is DateTime
          ? map['dataCadastro']
          : DateTime.parse(map['dataCadastro'].toString()),
      nome: map['nome'],
      cpf: map['cpf'],
      rg: map['rg'],
      orgaoEmissor: map['orgaoEmissor'],
      dataNascimento: map['dataNascimento'] is DateTime
          ? map['dataNascimento']
          : DateTime.parse(map['dataNascimento'].toString()),
      idUfOrgaoEmissor: map['idUfOrgaoEmissor'],
      sexoBiologico: map['sexoBiologico'],
      identidadeGenero: map['identidadeGenero'],
      dataInicialResidenciaRO: map['dataInicialResidenciaRO'] is DateTime
          ? map['dataInicialResidenciaRO']
          : DateTime.tryParse(map['dataInicialResidenciaRO'].toString()),
      dataInicialResidenciaAtual: map['dataInicialResidenciaAtual'] is DateTime
          ? map['dataInicialResidenciaAtual']
          : DateTime.parse(map['dataInicialResidenciaAtual'].toString()),
      cep: map['cep'],
      tipoEndereco: map['tipoEndereco'],
      idUf: map['idUf'],
      idMunicipio: map['idMunicipio'],
      bairro: map['bairro'],
      tipoLogradouro: map['tipoLogradouro'],
      logradouro: map['logradouro'],
      numeroEndereco: map['numeroEndereco'],
      complementoEndereco: map['complementoEndereco'],
      emailPrincipal: map['emailPrincipal'],
      tipoTelefone: map['tipoTelefone'],
      telefone: map['telefone'],
      idEscolaridade: map['idEscolaridade'],
      estadoCivil: map['estadoCivil'],
      rendaFamiliar: map['rendaFamiliar'],
      nrDependentes: map['nrDependentes'],
      nrCertificadoReservista: map['nrCertificadoReservista'],
      pis: map['pis'],
      nrTituloEleitor: map['nrTituloEleitor'],
      zonaTituloEleitor: map['zonaTituloEleitor'],
      nrCarteiraProfissional: map['nrCarteiraProfissional'],
      nrSerieCarteiraProfissional: map['nrSerieCarteiraProfissional'],
      referenciaPessoal: map['referenciaPessoal'],
      categoriaHabilitacao: map['categoriaHabilitacao'],
      idCargo1: map['idCargo1'],
      idCargo2: map['idCargo2'],
      idCargo3: map['idCargo3'],
      experienciaCargo1: map['experienciaCargo1'],
      experienciaCargo2: map['experienciaCargo2'],
      experienciaCargo3: map['experienciaCargo3'],
      validado: map['validado'],
      dataValidacao: map['dataValidacao'] != null
          ? DateTime.tryParse(map['dataValidacao'].toString())
          : null,
      usuarioRespValidacao: map['usuarioRespValidacao'],
      fumante: map['fumante'],
      idConhecimentoExtra1: map['idConhecimentoExtra1'],
      idConhecimentoExtra2: map['idConhecimentoExtra2'],
      idConhecimentoExtra3: map['idConhecimentoExtra3'],
      idConhecimentoExtra4: map['idConhecimentoExtra4'],
      conhecimentoExtraNivel1: map['conhecimentoExtraNivel1'],
      conhecimentoExtraNivel2: map['conhecimentoExtraNivel2'],
      conhecimentoExtraNivel3: map['conhecimentoExtraNivel3'],
      conhecimentoExtraNivel4: map['conhecimentoExtraNivel4'],

      idCurso1: map['idCurso1'],
      idCurso2: map['idCurso2'],
      idCurso3: map['idCurso3'],
      idCurso4: map['idCurso4'],
      idCurso5: map['idCurso5'],
      idCurso6: map['idCurso6'],

      dataConclusaoCurso1: map['dataConclusaoCurso1'] is DateTime
          ? map['dataConclusaoCurso1']
          : DateTime.tryParse(map['dataConclusaoCurso1'].toString()),

      dataConclusaoCurso2: map['dataConclusaoCurso2'] is DateTime
          ? map['dataConclusaoCurso2']
          : DateTime.tryParse(map['dataConclusaoCurso2'].toString()),

      dataConclusaoCurso3: map['dataConclusaoCurso3'] is DateTime
          ? map['dataConclusaoCurso3']
          : DateTime.tryParse(map['dataConclusaoCurso3'].toString()),

      dataConclusaoCurso4: map['dataConclusaoCurso4'] is DateTime
          ? map['dataConclusaoCurso4']
          : DateTime.tryParse(map['dataConclusaoCurso4'].toString()),

      dataConclusaoCurso5: map['dataConclusaoCurso5'] is DateTime
          ? map['dataConclusaoCurso5']
          : DateTime.tryParse(map['dataConclusaoCurso5'].toString()),

      dataConclusaoCurso6: map['dataConclusaoCurso6'] is DateTime
          ? map['dataConclusaoCurso6']
          : DateTime.tryParse(map['dataConclusaoCurso6'].toString()),
      //
      tempoExperienciaFormal1: map['tempoExperienciaFormal1'],
      tempoExperienciaInformal1: map['tempoExperienciaInformal1'],

      tempoExperienciaMei1: map['tempoExperienciaMei1'],
      tempoExperienciaFormal2: map['tempoExperienciaFormal2'],

      tempoExperienciaInformal2: map['tempoExperienciaInformal2'],
      tempoExperienciaMei2: map['tempoExperienciaMei2'],

      tempoExperienciaFormal3: map['tempoExperienciaFormal3'],
      tempoExperienciaInformal3: map['tempoExperienciaInformal3'],

      tempoExperienciaMei3: map['tempoExperienciaMei3'],
    );
    if (map.containsKey('deficiente')) {
      cand.deficiente = map['deficiente'];
    }
    if (map.containsKey('cid')) {
      cand.cid = map['cid'];
    }
    if (map.containsKey('idTipoDeficiencia')) {
      cand.idTipoDeficiencia = map['idTipoDeficiencia'];
    }
    if (map.containsKey('dataEmissao')) {
      cand.dataEmissao = map['dataEmissao'] != null
          ? DateTime.tryParse(map['dataEmissao'].toString())
          : null;
    }
    if (map.containsKey('nomeCargo1')) {
      cand.nomeCargo1 = map['nomeCargo1'];
    }
    if (map.containsKey('nomeCargo2')) {
      cand.nomeCargo2 = map['nomeCargo2'];
    }
    if (map.containsKey('nomeCargo3')) {
      cand.nomeCargo3 = map['nomeCargo3'];
    }
    if (map.containsKey('nomeRespValidacao')) {
      cand.nomeRespValidacao = map['nomeRespValidacao'];
    }

    return cand;
  }

  @override
  bool operator ==(covariant CandidatoWeb other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
