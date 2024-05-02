import 'package:intl/intl.dart';
import 'package:sibem_core/core.dart';

class Vaga implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'vagas';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String idEmpregadorFqCol = '$tableName.$idEmpregadorCol';
  static const String idEmpregadorCol = 'idEmpregador';

  static const String aceitaFumanteCol = 'aceitaFumante';

  /// nome da coluna responsavel por bloquear uma vaga para ela não ser listada e não receber encaminhamentos
  static const String bloqueioEncaminhamentoCol = 'bloqueioEncaminhamento';

  /// nome da coluna que armazena a quandidade de encaminhamentos
  static const String quantidadeEncaminhadaCol = 'quantidadeEncaminhada';

  static const String numeroVagasCol = 'numeroVagas';

  /// nome da coluna que armazena o Nº Maximo de Encaminhamentos
  static const String numeroEncaminhamentosCol = 'numeroEncaminhamentos';
  static const String validadoFqCol = '$schemaName.$validadoCol';
  static const String validadoCol = 'validado';

  int id;
  int idEmpregador;
  int idCargo;

  DateTime dataAbertura;

  String get dataAberturaFormatada {
    return DateFormat('dd/MM/yyyy').format(dataAbertura);
  }

  String? get dataEncerramentoFormatada {
    return dataEncerramento != null
        ? DateFormat('dd/MM/yyyy').format(dataEncerramento!)
        : null;
  }

  DateTime? dataEncerramento;
  int numeroVagas;
  bool vagaPcd;

  String salario;

  int idEscolaridade;
  String? sexoBiologico;
  String? identidadeGenero;
  bool escala;
  String turno;
  int? cargaHorariaSemanal;
  String? descricaoCargaHoraria;

  /// Nº Maximo de Encaminhamentos
  int? numeroEncaminhamentos;

  bool exigeExperiencia;

  /// Aceita Experiência Informal:
  bool? experienciaInformal;

  /// Aceita tempo de Experiencia Como Micro Empreendedor Individual
  bool? aceitaExperienciaMei;

  int? tempoMinimoExperiencia;
  int? tempoMaximoExperiencia;

  bool areaPetroleoGas;
  bool offShore;
  String tipoVaga;
  int idadeMinima;
  int? idadeMaxima;
  bool? aceitaFumante;
  bool confidencialidadeEmpresa;

  /// Email | WhatsApp | Presencial
  String formaEncaminhamento;
  String complementoFormaEncaminhamento;
  String? contatoEncaminhamento;
  String? observacao;
  bool bloqueioEncaminhamento;
  int idUsuarioResponsavel;

  /// Total encaminhados
  int quantidadeEncaminhada;

  /// Usuário responsável pela alteração
  String? usuarioResponsavelNome;

  BloqueioEncaminhamento? bloqueioEncaminhamentoInstance;

  /// Cursos Exigidos
  List<Curso> cursos = [];
  List<ConhecimentoExtra> conhecimentosExtras = [];
  List<Beneficio> beneficios = [];

  bool isSelected = false;

  /// Campo da tabela Empregador
  String? empregadorContato;
  // Campo da tabela Empregador
  String? empregadorNome;
  // Campo da tabela Cargo
  String? cargoNome;

  Cargo? _cargo;
  Empregador? _empregador;
  Escolaridade? _escolaridade;

  /// propriedade anexada da tabela escolaridade
  int? ordemGraduacao;

  /// propriedade anexada Campo do schema pmro_padrao da tabela Escolaridades
  String? grauEscolaridade;

  /// se veio da WEB
  bool? isFromWeb;

  ///
  bool validado;

  Vaga(
      {this.id = -1,
      required this.idEmpregador,
      required this.idCargo,
      required this.dataAbertura,
      this.dataEncerramento,
      required this.numeroVagas,
      required this.vagaPcd,
      required this.salario,
      required this.idEscolaridade,
      this.sexoBiologico,
      this.identidadeGenero,
      required this.escala,
      required this.turno,
      this.cargaHorariaSemanal,
      this.descricaoCargaHoraria,
      this.numeroEncaminhamentos,
      required this.exigeExperiencia,
      this.experienciaInformal,
      this.aceitaExperienciaMei,
      this.tempoMinimoExperiencia,
      this.tempoMaximoExperiencia,
      required this.areaPetroleoGas,
      required this.offShore,
      required this.tipoVaga,
      required this.idadeMinima,
      this.idadeMaxima,
      this.aceitaFumante,
      required this.confidencialidadeEmpresa,
      required this.formaEncaminhamento,
      required this.complementoFormaEncaminhamento,
      this.contatoEncaminhamento,
      this.observacao,
      required this.bloqueioEncaminhamento,
      required this.idUsuarioResponsavel,
      this.empregadorContato, // Campo da tabela Empregador
      this.cargoNome, // Campo da tabela Cargo
      this.quantidadeEncaminhada = 0,
      this.isFromWeb,
      required this.validado});

  factory Vaga.invalid() {
    return Vaga(
      idEmpregador: -1,
      idCargo: -1,
      dataAbertura: DateTime.now(),
      numeroVagas: 1,
      vagaPcd: false,
      salario: '',
      idEscolaridade: -1,
      escala: false,
      turno: '',
      exigeExperiencia: false,
      areaPetroleoGas: false,
      offShore: false,
      tipoVaga: 'Normal',
      idadeMinima: 18,
      //idadeMaxima: ,
      confidencialidadeEmpresa: false,
      formaEncaminhamento: 'Email',
      complementoFormaEncaminhamento: '',
      bloqueioEncaminhamento: false,
      idUsuarioResponsavel: -1, sexoBiologico: 'Ambos',
      validado: false,
    );
  }

  factory Vaga.fromMap(Map<String, dynamic> map) {
    //print('Vaga.fromMap $map');
    final va = Vaga(
      id: map['id'],
      idEmpregador: map['idEmpregador'],
      idCargo: map['idCargo'],
      dataAbertura: DateTime.parse(map['dataAbertura'].toString()),
      dataEncerramento: DateTime.tryParse(map['dataEncerramento'].toString()),
      numeroVagas: map['numeroVagas'],
      vagaPcd: map['vagaPcd'],
      salario: map['salario'],
      idEscolaridade: map['idEscolaridade'],
      sexoBiologico: map['sexoBiologico'],
      identidadeGenero: map['identidadeGenero'],
      escala: map['escala'],
      turno: map['turno'],
      cargaHorariaSemanal: map['cargaHorariaSemanal'],
      descricaoCargaHoraria: map['descricaoCargaHoraria'],
      numeroEncaminhamentos: map['numeroEncaminhamentos'],
      exigeExperiencia: map['exigeExperiencia'],
      experienciaInformal: map['experienciaInformal'],
      aceitaExperienciaMei: map['aceitaExperienciaMei'],
      tempoMinimoExperiencia: map['tempoMinimoExperiencia'],
      tempoMaximoExperiencia: map['tempoMaximoExperiencia'],
      areaPetroleoGas: map['areaPetroleoGas'],
      offShore: map['offShore'],
      tipoVaga: map['tipoVaga'],
      idadeMinima: map['idadeMinima'],
      idadeMaxima: map['idadeMaxima'],
      aceitaFumante: map[aceitaFumanteCol],
      confidencialidadeEmpresa: map['confidencialidadeEmpresa'],
      formaEncaminhamento: map['formaEncaminhamento'],
      complementoFormaEncaminhamento: map['complementoFormaEncaminhamento'],
      contatoEncaminhamento: map['contatoEncaminhamento'],
      observacao: map['observacao'],
      bloqueioEncaminhamento: map['bloqueioEncaminhamento'],
      idUsuarioResponsavel: map['idUsuarioResponsavel'],
      validado: map['validado'],
    );

    if (map['beneficios'] != null) {
      if (map['beneficios'] is List<Beneficio>) {
        va.beneficios = map['beneficios'];
      } else {
        va.beneficios = (map['beneficios'] as List)
            .map((e) => Beneficio.fromMap(e))
            .toList();
      }
    }
    if (map['cursos'] != null) {
      if (map['cursos'] is List<Curso>) {
        va.cursos = map['cursos'];
      } else {
        va.cursos =
            (map['cursos'] as List).map((e) => Curso.fromMap(e)).toList();
      }
    }

    if (map['conhecimentosExtras'] != null) {
      if (map['conhecimentosExtras'] is List<ConhecimentoExtra>) {
        va.conhecimentosExtras = map['conhecimentosExtras'];
      } else if (map['conhecimentosExtras'] is List) {
        va.conhecimentosExtras = (map['conhecimentosExtras'] as List)
            .map((e) => ConhecimentoExtra.fromMap(e))
            .toList();
      }
    }

    if (map['empregadorContato'] != null) {
      va.empregadorContato =
          map['empregadorContato']; // Campo da tabela Empregador
    }

    if (map['empregadorNome'] != null) {
      va.empregadorNome = map['empregadorNome']; // Campo da tabela Empregador
    }

    if (map['cargoNome'] != null) {
      va.cargoNome = map['cargoNome']; // Campo da tabela Cargo
    }

    if (map['grauEscolaridade'] != null) {
      va.grauEscolaridade = map['grauEscolaridade'];
    }

    if (map['cargo'] != null) {
      va.cargo = Cargo.fromMap(map['cargo']);
    }

    if (map['empregador'] != null) {
      va.empregador = Empregador.fromMap(map['empregador']);
    }

    if (map['escolaridade'] != null) {
      va.escolaridade = Escolaridade.fromMap(map['escolaridade']);
    }

    if (map['bloqueioEncaminhamentoInstance'] != null) {
      va.bloqueioEncaminhamentoInstance =
          BloqueioEncaminhamento.fromMap(map['bloqueioEncaminhamentoInstance']);
    }

    if (map['quantidadeEncaminhada'] != null) {
      va.quantidadeEncaminhada = map['quantidadeEncaminhada'];
    }

    if (map['usuarioResponsavelNome'] != null) {
      va.usuarioResponsavelNome = map['usuarioResponsavelNome'];
    }
    if (map['ordemGraduacao'] != null) {
      va.ordemGraduacao = map['ordemGraduacao'];
    }
    if (map['isFromWeb'] != null) {
      va.isFromWeb = map['isFromWeb'];
    }

    return va;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('empregadorContato')
      ..remove('empregadorNome')
      ..remove('cargoNome')
      ..remove('grauEscolaridade')
      ..remove('cargo')
      ..remove('empregador')
      ..remove('escolaridade')
      ..remove('cursos')
      ..remove('conhecimentosExtras')
      ..remove('beneficios')
      ..remove('bloqueioEncaminhamentoInstance')
      ..remove('quantidadeEncaminhada')
      ..remove('usuarioResponsavelNome')
      ..remove('ordemGraduacao');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cursos')
      ..remove('conhecimentosExtras')
      ..remove('beneficios')
      ..remove('empregadorContato')
      ..remove('empregadorNome')
      ..remove('cargoNome')
      ..remove('grauEscolaridade')
      ..remove('cargo')
      ..remove('empregador')
      ..remove('escolaridade')
      ..remove('bloqueioEncaminhamentoInstance')
      ..remove('quantidadeEncaminhada')
      ..remove('usuarioResponsavelNome')
      ..remove('ordemGraduacao');
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'idEmpregador': idEmpregador,
      'idCargo': idCargo,
      'dataAbertura': dataAbertura.toIso8601String(),
      'dataEncerramento': dataEncerramento?.toIso8601String(),
      'numeroVagas': numeroVagas,
      'vagaPcd': vagaPcd,
      'salario': salario,
      'idEscolaridade': idEscolaridade,
      'sexoBiologico': sexoBiologico,
      'identidadeGenero': identidadeGenero,
      'escala': escala,
      'turno': turno,
      'cargaHorariaSemanal': cargaHorariaSemanal,
      'descricaoCargaHoraria': descricaoCargaHoraria,
      'numeroEncaminhamentos': numeroEncaminhamentos,
      'exigeExperiencia': exigeExperiencia,
      'experienciaInformal': experienciaInformal,
      'aceitaExperienciaMei': aceitaExperienciaMei,
      'tempoMinimoExperiencia': tempoMinimoExperiencia,
      'tempoMaximoExperiencia': tempoMaximoExperiencia,
      'areaPetroleoGas': areaPetroleoGas,
      'offShore': offShore,
      'tipoVaga': tipoVaga,
      'idadeMinima': idadeMinima,
      'idadeMaxima': idadeMaxima,
      aceitaFumanteCol: aceitaFumante,
      'confidencialidadeEmpresa': confidencialidadeEmpresa,
      'formaEncaminhamento': formaEncaminhamento,
      'complementoFormaEncaminhamento': complementoFormaEncaminhamento,
      'contatoEncaminhamento': contatoEncaminhamento,
      'observacao': observacao,
      'bloqueioEncaminhamento': bloqueioEncaminhamento,
      'idUsuarioResponsavel': idUsuarioResponsavel,
      'quantidadeEncaminhada': quantidadeEncaminhada,
      'validado': validado,
    };

    if (empregadorContato != null) {
      map['empregadorContato'] = empregadorContato;
    }

    if (empregadorNome != null) {
      map['empregadorNome'] = empregadorNome;
    }

    if (cargoNome != null) {
      map['cargoNome'] = cargoNome;
    }

    if (grauEscolaridade != null) {
      map['grauEscolaridade'] = grauEscolaridade;
    }

    if (cargo != null) {
      map['cargo'] = cargo!.toMap();
    }

    if (empregador != null) {
      map['empregador'] = empregador!.toMap();
    }

    if (escolaridade != null) {
      map['escolaridade'] = escolaridade!.toMap();
    }

    if (cursos.isNotEmpty) {
      map['cursos'] = cursos.map((e) => e.toMap()).toList();
    }

    if (conhecimentosExtras.isNotEmpty) {
      map['conhecimentosExtras'] =
          conhecimentosExtras.map((e) => e.toMap()).toList();
    }

    if (beneficios.isNotEmpty) {
      map['beneficios'] = beneficios.map((e) => e.toMap()).toList();
    }

    if (bloqueioEncaminhamentoInstance != null) {
      map['bloqueioEncaminhamentoInstance'] =
          bloqueioEncaminhamentoInstance!.toMap();
    }

    if (usuarioResponsavelNome != null) {
      map['usuarioResponsavelNome'] = usuarioResponsavelNome;
    }

    if (ordemGraduacao != null) {
      map['ordemGraduacao'] = ordemGraduacao;
    }
    if (isFromWeb != null) {
      map['isFromWeb'] = isFromWeb;
    }

    return map;
  }

  Cargo? get cargo {
    return _cargo;
  }

  set cargo(Cargo? cargo) {
    idCargo = cargo != null ? cargo.id : idCargo;
    _cargo = cargo;
  }

  Empregador? get empregador {
    return _empregador;
  }

  set empregador(Empregador? empregador) {
    idEmpregador = empregador != null ? empregador.idPessoa : idCargo;
    _empregador = empregador;
  }

  Escolaridade? get escolaridade {
    return _escolaridade;
  }

  set escolaridade(Escolaridade? escolaridade) {
    idEscolaridade = escolaridade != null ? escolaridade.id : idCargo;
    _escolaridade = escolaridade;
  }

  /// Encerrou a vaga
  bool get isEncerrou {
    if (dataEncerramento != null) {
      final now = DateTime.now();
      if (now.isAfter(dataEncerramento!)) {
        return true;
      }
    }
    return false;
  }
}
