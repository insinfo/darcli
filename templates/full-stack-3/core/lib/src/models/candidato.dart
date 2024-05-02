import 'package:sibem_core/core.dart';

/// enum
class CandidatoStatus {
  static const valido = CandidatoStatus('válido');
  static const vencido = CandidatoStatus('vencido');
  final String value;
  const CandidatoStatus(this.value);

  static CandidatoStatus? fromString(String value) {
    switch (value) {
      case 'válido':
        return valido;
      case 'vencido':
        return vencido;
      default:
        return null;
    }
  }
}

class Candidato extends PessoaFisica implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'candidatos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// fully qualified idPessoa column name
  static const String idPessoaFqCol = '$tableName.$idPessoaCol';
  static const String idPessoaCol = 'idPessoaFisica';
  static const String fumanteFqCol = '$tableName.$fumanteCol';
  static const String fumanteCol = 'fumante';
  static const String idCandidatoFqCol = '$tableName.$idCandidatoCol';
  static const String idCandidatoCol = 'idCandidato';

  int idCandidato;

  /// Obrigatorio
  int idPessoaFisica;
  DateTime dataCadastroCandidato;
  DateTime? dataInicialResidenciaRO;

  /// quando que começou a morar onde reside atualmente
  /// Obrigatorio
  DateTime dataInicialResidenciaAtual;

  /// Obrigatorio
  String rendaFamiliar;

  String? referenciaPessoal;
  String? infoComplementar;
  String? identidadeGenero;
  DateTime? dataAlteracaoCandidato;

  /// id pessoa que fez alteração
  int? usuarioRespAlteracao;

  /// candidatos_conhecimentos_extras | nivelConhecimento
  List<ConhecimentoExtra> conhecimentosExtras = [];

  /// candidatos_cursos | dataConclusao
  List<Curso> cursos = [];

  /// cargos_desejados | bool experiencia
  List<Cargo> cargosDesejados = [];

  bool? experiencia;
  String? nomeResponsavel;

  /// escolaridades.ordemGraduacao
  int? ordemGraduacao;

  ///  para saber se este candidato vem da web
  bool? isFromWeb;

  bool? fumante;

  /// usado para saber se o cadastro do candidato ja venceu
  /// 'válido' | 'vencido'
  String? status;

  int get idade => DateTime.now().year - this.dataNascimento.year;

  Candidato(
      {this.idCandidato = -1,
      required this.idPessoaFisica,
      required this.dataCadastroCandidato,
      this.dataInicialResidenciaRO,
      required this.dataInicialResidenciaAtual,
      required this.rendaFamiliar,
      this.referenciaPessoal,
      this.infoComplementar,
      this.identidadeGenero,
      this.dataAlteracaoCandidato,
      this.usuarioRespAlteracao,
      //pessoa fisica
      required String cpf,
      String? rg,
      String? orgaoEmissor,
      int? idUfOrgaoEmissor,
      required DateTime dataNascimento,
      required String sexo,
      String? estadoCivil,
      String? pis,
      DateTime? dataEmissao,
      int? idPaisNacionalidade,
      int? naturalidadeMunicipio,
      String? grupoSanguineo,
      String? fatorRH,
      String? profissao,
      String? nomePai,
      String? nomeMae,
      String? naturalidadeUF,
      // para saber se este candidato vem da web
      this.isFromWeb,
      this.fumante,
      //pessoa
      required String nome,
      String? emailPrincipal,
      String? emailAdicional,
      required String tipo,
      required DateTime dataInclusao,
      DateTime? dataAlteracao,
      String? imagem,
      //
      this.status})
      : super(
          idPessoa: idPessoaFisica,
          cpf: cpf,
          rg: rg,
          orgaoEmissor: orgaoEmissor,
          idUfOrgaoEmissor: idUfOrgaoEmissor,
          dataNascimento: dataNascimento,
          sexo: sexo,
          estadoCivil: estadoCivil,
          pis: pis,
          dataEmissao: dataEmissao,
          idPaisNacionalidade: idPaisNacionalidade,
          naturalidadeMunicipio: naturalidadeMunicipio,
          grupoSanguineo: grupoSanguineo,
          fatorRH: fatorRH,
          profissao: profissao,
          nomePai: nomePai,
          nomeMae: nomeMae,
          naturalidadeUF: naturalidadeUF,
          //pessoa
          nome: nome,
          dataInclusao: dataInclusao,
          emailPrincipal: emailPrincipal,
          emailAdicional: emailAdicional,
          tipo: tipo,
          dataAlteracao: dataAlteracao,
          imagem: imagem,
        );

  factory Candidato.invalid() {
    final cand = Candidato(
      idCandidato: -1,
      idPessoaFisica: -1,
      dataCadastroCandidato: DateTime.now(),
      dataInicialResidenciaAtual: DateTime(1700),
      rendaFamiliar: '',
      dataAlteracaoCandidato: null,
      cpf: '',
      dataNascimento: DateTime(1700),
      sexo: '',
      nome: '',
      tipo: 'fisica',
      dataInclusao: DateTime.now(),
      //fumante: false,
    );
    cand.complementoPessoaFisica = ComplementoPessoaFisica(idPessoa: -1);
    cand.telefones = [Telefone.invalid()..tipo = 'WhatsApp'];
    cand.enderecos = [Endereco.invalid()..tipo = 'Residencial'];
    return cand;
  }

  factory Candidato.fromMap(Map<String, dynamic> map) {
    final ca = Candidato(
      idCandidato: map['idCandidato'] as int,
      idPessoaFisica: map['idPessoaFisica'] as int,
      dataCadastroCandidato: map['dataCadastroCandidato'] is DateTime
          ? map['dataCadastroCandidato']
          : DateTime.parse(map['dataCadastroCandidato'].toString()),
      dataInicialResidenciaRO: map['dataInicialResidenciaRO'] is DateTime
          ? map['dataInicialResidenciaRO']
          : DateTime.tryParse(map['dataInicialResidenciaRO'].toString()),
      dataInicialResidenciaAtual: map['dataInicialResidenciaAtual'] is DateTime
          ? map['dataInicialResidenciaAtual']
          : DateTime.parse(map['dataInicialResidenciaAtual']),
      rendaFamiliar: map['rendaFamiliar'],
      referenciaPessoal: map['referenciaPessoal'],
      infoComplementar: map['infoComplementar'],
      identidadeGenero: map['identidadeGenero'],
      dataAlteracaoCandidato: map['dataAlteracaoCandidato'] is DateTime
          ? map['dataAlteracaoCandidato']
          : DateTime.tryParse(map['dataAlteracaoCandidato'].toString()),
      usuarioRespAlteracao: map['usuarioRespAlteracao'],
      // pessoa fsica
      cpf: map['cpf'],
      rg: map['rg'],
      orgaoEmissor: map['orgaoEmissor'],
      idUfOrgaoEmissor: map['idUfOrgaoEmissor'],
      dataNascimento: map['dataNascimento'] is DateTime
          ? map['dataNascimento']
          : DateTime.parse(map['dataNascimento'].toString()),
      sexo: map['sexo'],
      estadoCivil: map['estadoCivil'],
      pis: map['pis'],
      dataEmissao: map['dataEmissao'] != null
          ? DateTime.tryParse(map['dataEmissao'].toString())
          : null,
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
      ca.complementoPessoaFisica =
          ComplementoPessoaFisica.fromMap(map['complementoPessoaFisica']);
    }

    if (map.containsKey('telefones')) {
      ca.telefones = <Telefone>[];
      map['telefones'].forEach((telefone) {
        ca.telefones.add(Telefone.fromMap(telefone));
      });
    }

    if (map.containsKey('enderecos')) {
      ca.enderecos = <Endereco>[];
      map['enderecos'].forEach((end) {
        ca.enderecos.add(Endereco.fromMap(end));
      });
    }

    if (map.containsKey('pessoaOrigem')) {
      ca.pessoaOrigem = PessoaOrigem.fromMap(map['pessoaOrigem']);
    }

    if (map['conhecimentosExtras'] is List) {
      ca.conhecimentosExtras = (map['conhecimentosExtras'] as List)
          .map((x) => ConhecimentoExtra.fromMap(x))
          .toList();
    }

    if (map['cursos'] is List) {
      ca.cursos = (map['cursos'] as List).map((x) => Curso.fromMap(x)).toList();
    }
    if (map['cargosDesejados'] is List) {
      ca.cargosDesejados = (map['cargosDesejados'] as List)
          .map((x) => Cargo.fromMap(x))
          .toList();
    }

    if (map['experiencia'] != null) {
      ca.experiencia = map['experiencia'];
    }
    if (map['nomeResponsavel'] != null) {
      ca.nomeResponsavel = map['nomeResponsavel'];
    }
    if (map['ordemGraduacao'] != null) {
      ca.ordemGraduacao = map['ordemGraduacao'];
    }
    if (map['isFromWeb'] != null) {
      ca.isFromWeb = map['isFromWeb'];
    }
    if (map['fumante'] != null) {
      ca.fumante = map['fumante'];
    }
    if (map['status'] != null) {
      ca.status = map['status'];
    }

    return ca;
  }

  // Retorna um mapa com os dados de pessoa física
  PessoaFisica getPessoaFisica() {
    final pf = PessoaFisica.fromMap(super.toMap());
    pf.enderecos = enderecos;
    pf.telefones = telefones;
    pf.complementoPessoaFisica = complementoPessoaFisica;
    pf.pessoaOrigem = pessoaOrigem;
    return pf;
  }

  Map<String, dynamic> toInsertCandidatoMap() {
    dataCadastroCandidato = DateTime.now();
    final map = <String, dynamic>{
      'idPessoaFisica': idPessoaFisica,
      'rendaFamiliar': rendaFamiliar,
      'referenciaPessoal': referenciaPessoal,
      'infoComplementar': infoComplementar,
      'identidadeGenero': identidadeGenero,
      'usuarioRespAlteracao': usuarioRespAlteracao,
    };

    map['dataCadastroCandidato'] = dataCadastroCandidato.toIso8601String();

    if (dataInicialResidenciaRO != null) {
      map['dataInicialResidenciaRO'] =
          dataInicialResidenciaRO?.toIso8601String();
    }
    if (isFromWeb != null) {
      map['isFromWeb'] = isFromWeb;
    }
    if (fumante != null) {
      map['fumante'] = fumante;
    }

    map['dataInicialResidenciaAtual'] =
        dataInicialResidenciaAtual.toIso8601String();

    if (dataAlteracaoCandidato != null) {
      map['dataAlteracaoCandidato'] = dataAlteracaoCandidato?.toIso8601String();
    }
    return map;
  }

  Map<String, dynamic> toUpdateCandidatoMap() {
    return toInsertCandidatoMap()
      ..remove('idCandidato')
      ..remove('idPessoaFisica')
      ..remove('dataCadastro')
      ..remove('dataCadastroCandidato')
      ..remove('cargosDesejados')
      ..remove('cursos')
      ..remove('conhecimentosExtras')
      ..remove('ordemGraduacao')
      ..remove('status');
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idCandidato': idCandidato,
      'idPessoaFisica': idPessoaFisica,
      'dataCadastroCandidato': dataCadastroCandidato.toIso8601String(),
      'dataInicialResidenciaRO': dataInicialResidenciaRO?.toIso8601String(),
      'dataInicialResidenciaAtual':
          dataInicialResidenciaAtual.toIso8601String(),
      'rendaFamiliar': rendaFamiliar,
      'referenciaPessoal': referenciaPessoal,
      'infoComplementar': infoComplementar,
      'identidadeGenero': identidadeGenero,
      'dataAlteracaoCandidato': dataAlteracaoCandidato?.toIso8601String(),
      'usuarioRespAlteracao': usuarioRespAlteracao,
    };

    map.addAll(super.toMap());

    if (conhecimentosExtras.isNotEmpty) {
      map['conhecimentosExtras'] =
          conhecimentosExtras.map((x) => x.toMap()).toList();
    }
    if (cursos.isNotEmpty) {
      map['cursos'] = cursos.map((x) => x.toMap()).toList();
    }

    if (cargosDesejados.isNotEmpty) {
      map['cargosDesejados'] = cargosDesejados.map((x) => x.toMap()).toList();
    }
    if (experiencia != null) {
      map['experiencia'] = experiencia;
    }
    if (experiencia != null) {
      map['nomeResponsavel'] = nomeResponsavel;
    }
    if (ordemGraduacao != null) {
      map['ordemGraduacao'] = ordemGraduacao;
    }
    if (isFromWeb != null) {
      map['isFromWeb'] = isFromWeb;
    }
    if (fumante != null) {
      map['fumante'] = fumante;
    }
    if (status != null) {
      map['status'] = status;
    }

    return map;
  }
}
