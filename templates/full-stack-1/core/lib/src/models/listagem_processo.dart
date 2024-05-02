import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:new_sali_core/new_sali_core.dart';

class ProcessoCodigo {
  final int numero;
  final String ano;

  ProcessoCodigo({required this.numero, required this.ano});
}

/// representa uma lista de processo encaminhado
class ListagemProcesso implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_listagem_processos';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// chave primaria
  int id;
  String? processos;
  DateTime? data;

  List<ProcessoCodigo> get processosList {
    final results = <ProcessoCodigo>[];
    if (processos != null && processos!.contains(',')) {
      final procs = processos!.split(',');
      for (final p in procs) {
        final ano = p.substring(p.length - 4);
        final numero = int.tryParse(p.substring(0, p.length - 4));
        if (numero != null) {
          results.add(ProcessoCodigo(ano: ano, numero: numero));
        }
      }
    } else if (processos != null && processos!.isNotEmpty) {
      final ano = processos!.substring(processos!.length - 4);
      final numero =
          int.tryParse(processos!.substring(0, processos!.length - 4));
      if (numero != null) {
        results.add(ProcessoCodigo(ano: ano, numero: numero));
      }
    }
    return results;
  }

  String get dataFormatada {
    return data != null ? DateFormat('dd/MM/yyyy HH:mm').format(data!) : '';
  }

  /// [tipo] 1 para relatorio de consulta de processo e 2 para guia de encaminhamento
  String? tipo;

  String get tipoFormatado {
    if (tipo == null) {
      return 'desconhecido';
    }
    return tipo == '1' ? 'Listagem Comum' : 'Listagem de Encaminhamento';
  }

  /// Orgão do usuario logado
  int? codOrgao;
  int? codUnidade;
  int? codDepartamento;
  int? codSetor;

  /// CGM usuario logado
  int? numcgm;
  int? codOrgaoDest;
  int? codUnidadeDest;
  int? codDepartamentoDest;
  int? codSetorDest;

  /// chave secundaria
  String anoExercicio;

  ListagemProcesso({
    required this.id,
    this.processos,
    this.data,
    this.tipo,
    this.codOrgao,
    this.codUnidade,
    this.codDepartamento,
    this.codSetor,
    this.numcgm,
    this.codOrgaoDest,
    this.codUnidadeDest,
    this.codDepartamentoDest,
    this.codSetorDest,
    required this.anoExercicio,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'processos': processos,
      'data': data?.toIso8601String(),
      'tipo': tipo,
      'cod_orgao': codOrgao,
      'cod_unidade': codUnidade,
      'cod_departamento': codDepartamento,
      'cod_setor': codSetor,
      'numcgm': numcgm,
      'cod_orgao_dest': codOrgaoDest,
      'cod_unidade_dest': codUnidadeDest,
      'cod_departamento_dest': codDepartamentoDest,
      'cod_setor_dest': codSetorDest,
      'ano_exercicio': anoExercicio,
    };

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap();
  }

  factory ListagemProcesso.fromMap(Map<String, dynamic> map) {
    return ListagemProcesso(
      id: map['id'] as int,
      processos: map['processos'] != null ? map['processos'] as String : null,
      data: map['data'] != null
          ? DateTime.tryParse(map['data'].toString())
          : null,
      tipo: map['tipo'] != null ? map['tipo'] as String : null,
      codOrgao: map['cod_orgao'] != null ? map['cod_orgao'] as int : null,
      codUnidade: map['cod_unidade'] != null ? map['cod_unidade'] as int : null,
      codDepartamento: map['cod_departamento'] != null
          ? map['cod_departamento'] as int
          : null,
      codSetor: map['cod_setor'] != null ? map['cod_setor'] as int : null,
      numcgm: map['numcgm'] != null ? map['numcgm'] as int : null,
      codOrgaoDest:
          map['cod_orgao_dest'] != null ? map['cod_orgao_dest'] as int : null,
      codUnidadeDest: map['cod_unidade_dest'] != null
          ? map['cod_unidade_dest'] as int
          : null,
      codDepartamentoDest: map['cod_departamento_dest'] != null
          ? map['cod_departamento_dest'] as int
          : null,
      codSetorDest:
          map['cod_setor_dest'] != null ? map['cod_setor_dest'] as int : null,
      anoExercicio: map['ano_exercicio'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ListagemProcesso.fromJson(String source) =>
      ListagemProcesso.fromMap(json.decode(source) as Map<String, dynamic>);
}
