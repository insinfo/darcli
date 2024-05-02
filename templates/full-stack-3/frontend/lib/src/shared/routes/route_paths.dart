import 'package:sibem_frontend/sibem_frontend.dart';

class RoutePaths {
  static final home = RoutePath(path: '/');
  static final sessionExpired = RoutePath(path: 'sessao-expirou');
  static final listaCargo = RoutePath(path: 'cargos');
  static final formCargo = RoutePath(path: 'cargos/:id');
  static final listaCurso = RoutePath(path: 'cursos');
  static final formCurso = RoutePath(path: 'cursos/:id');

  static final listaTipoConhecimento = RoutePath(path: 'tipos-conhecimento');
  static final formTipoConhecimento = RoutePath(path: 'tipos-conhecimento/:id');

  static final listaConhecimentoExtra = RoutePath(path: 'conhecimentos-extra');
  static final formConhecimentoExtra =
      RoutePath(path: 'conhecimentos-extra/:id');

  static final listaEscolaridade = RoutePath(path: 'escolaridades');
  static final formEscolaridade = RoutePath(path: 'escolaridades/:id');

  static final listaDivisaoCnae = RoutePath(path: 'divisoes-cnae');
  static final formDivisaoCnae = RoutePath(path: 'divisoes-cnae/:id');

  static final formTipoDeficiencia = RoutePath(path: 'tipos-deficiencia/:id');
  static final listaTipoDeficiencia = RoutePath(path: 'tipos-deficiencia');

  static final listaEmpregador = RoutePath(path: '/empregadores');
  static final formEmpregador = RoutePath(path: '/empregadores/:id');
  static final listaEmpregadorWeb = RoutePath(path: '/empregadores-web');

  static final listaVaga = RoutePath(path: 'vagas');
  static final formVaga = RoutePath(path: 'vagas/:id');

  static final listaCandidato = RoutePath(path: 'candidatos');
  static final formCandidato = RoutePath(path: 'candidatos/:id');
  static final listaCandidatoWeb = RoutePath(path: 'candidatos-web');

  static final listaEncaminhamento = RoutePath(path: 'encaminhamentos');
  static final formEncaminhamento = RoutePath(path: 'encaminhamentos/:id');

  static final relatorio = RoutePath(path: 'relatorios');
  static final estatistica = RoutePath(path: 'estatisticas');

  static final listaAuditoria = RoutePath(path: 'auditorias');



  static int? getId(Map<String, String> parameters) {
    final id = parameters['id'];
    return id == null ? null : int.tryParse(id);
  }

  static dynamic areaTransferencia;
}

String? getParam(Map<String, String> parameters, String paramName) {
  return parameters[paramName];
}
