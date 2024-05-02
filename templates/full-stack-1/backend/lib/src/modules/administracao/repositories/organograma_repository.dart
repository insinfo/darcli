import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class OrganogramaRepository {
  final Connection db;

  OrganogramaRepository(this.db);

  // Future<List<Organograma>> getHierarquia() async {
  //   final result = <Organograma>[];
  //   final orgaos = await OrgaoRepository(db).getAllOrgao();
  //   final unidades = await UnidadeRepository(db).getAllUnidade();
  //   final departamentos = await DepartamentoRepository(db).getAllDepartamento();
  //   final setores = await SetorRepository(db).getAllSetor();

  //   for (final orgao in orgaos) {
  //     result.add(
  //       Organograma(
  //           type: 'Orgao',
  //           label: orgao.nomOrgao + ' - ' + orgao.anoExercicio,
  //           anoExercicio: orgao.anoExercicio,
  //           codOrgao: orgao.codOrgao,
  //           isDisabled: orgao.nomOrgao.trim().toLowerCase().startsWith('x'),
  //           level: 0,
  //           children: _getUnidadesOf(orgao, unidades, departamentos, setores)),
  //     );
  //   }

  //   return result;
  // }

  /// retorna uma arvore de organogramas 
  Future<DataFrame<Map<String, dynamic>>> getHierarquiaAsMap(
      Filters filtros) async {
    final dados = <Map<String, dynamic>>[];

    final orgaos = await OrgaoRepository(db)
        .getAllOrgao(removeDisabled: filtros.removeDisabledItems ?? false);
    final unidades = await UnidadeRepository(db)
        .getAllUnidade(removeDisabled: filtros.removeDisabledItems ?? false);
    final departamentos = await DepartamentoRepository(db).getAllDepartamento(
        removeDisabled: filtros.removeDisabledItems ?? false);
    final setores = await SetorRepository(db)
        .getAllSetor(removeDisabled: filtros.removeDisabledItems ?? false);

    for (final orgao in orgaos) {
      dados.add(
        Organograma(
                type: 'Orgão',
                // label: orgao.nomOrgao + ' - ' + orgao.anoExercicio,
                label: orgao.nomOrgao,
                anoExercicio: orgao.anoExercicio,
                codOrgao: orgao.codOrgao,
                isDisabled: orgao.nomOrgao.trim().toLowerCase().startsWith('x'),
                // nomOrgao: orgao.nomOrgao,
                // nomUnidade: unidade.nomUnidade,
                // nomDepartamento: dep.nomDepartamento,
                // nomSetor: setor.nomSetor,
                level: 0,
                children:
                    _getUnidadesOf(orgao, unidades, departamentos, setores))
            .toMap(),
      );
    }

    final totalRecords = dados.length;

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  List<Organograma> _getUnidadesOf(Orgao orgao, List<Unidade> unidades,
      List<Departamento> departamentos, List<Setor> setores) {
    return unidades
        .where((uni) =>
            uni.codOrgao == orgao.codOrgao &&
            uni.anoExercicio == orgao.anoExercicio)
        .map((unidade) {
      return Organograma(
          type: 'Unidade',
          label: unidade.nomUnidade,
          anoExercicio: orgao.anoExercicio,
          codOrgao: orgao.codOrgao,
          codUnidade: unidade.codUnidade,
          isDisabled: unidade.nomUnidade.trim().toLowerCase().startsWith('x'),
          nomOrgao: orgao.nomOrgao,
          // nomUnidade: unidade.nomUnidade,
          // nomDepartamento: dep.nomDepartamento,
          // nomSetor: setor.nomSetor,
          level: 1,
          children: _getDepartamentoOf(orgao, unidade, departamentos, setores));
    }).toList();
  }

  List<Organograma> _getDepartamentoOf(Orgao orgao, Unidade unidade,
      List<Departamento> departamentos, List<Setor> setores) {
    return departamentos
        .where((dep) =>
            dep.codOrgao == unidade.codOrgao &&
            dep.anoExercicio == unidade.anoExercicio &&
            dep.codUnidade == unidade.codUnidade)
        .map((dep) {
      return Organograma(
          type: 'Departamento',
          label: dep.nomDepartamento,
          anoExercicio: dep.anoExercicio,
          codOrgao: dep.codOrgao,
          codUnidade: dep.codUnidade,
          codDepartamento: dep.codDepartamento,
          isDisabled: dep.nomDepartamento.trim().toLowerCase().startsWith('x'),
          nomOrgao: orgao.nomOrgao,
          nomUnidade: unidade.nomUnidade,
          // nomDepartamento: dep.nomDepartamento,
          // nomSetor: setor.nomSetor,
          level: 2,
          children: _getSetoresOf(orgao, unidade, dep, setores));
    }).toList();
  }

  List<Organograma> _getSetoresOf(
      Orgao orgao, Unidade unidade, Departamento depart, List<Setor> setores) {
    return setores
        .where((setor) =>
            setor.codOrgao == depart.codOrgao &&
            setor.anoExercicio == depart.anoExercicio &&
            setor.codUnidade == depart.codUnidade &&
            setor.codDepartamento == depart.codDepartamento)
        .map((setor) {
      return Organograma(
          type: 'Setor',
          //label: setor.nomSetor + ' - ' + setor.id.toString(),
          label: setor.nomSetor,
          anoExercicio: setor.anoExercicio,
          codOrgao: setor.codOrgao,
          codUnidade: setor.codUnidade,
          codDepartamento: setor.codDepartamento,
          codSetor: setor.codSetor,
          idSetor: setor.id,
          isDisabled: setor.situacao ==
              '0', //setor.nomSetor.trim().toLowerCase().startsWith('x'),
          usuarioResponsavelSetor: setor.usuarioResponsavel,
          nomOrgao: orgao.nomOrgao,
          nomUnidade: unidade.nomUnidade,
          nomDepartamento: depart.nomDepartamento,
          // nomSetor: setor.nomSetor,
          level: 3,
          children: []);
    }).toList();
  }
}
