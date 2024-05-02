import 'package:sibem_frontend/sibem_frontend.dart';

export 'route_paths.dart';

import 'package:sibem_frontend/src/modules/home/pages/home_page.template.dart'
    as home_template;

import 'package:sibem_frontend/src/shared/components/session_expired_page/session_expired_page.template.dart'
    as session_expired_page_template;

import 'package:sibem_frontend/src/modules/cargo/pages/lista_cargo/lista_cargo_page.template.dart'
    as lista_cargo_template;
import 'package:sibem_frontend/src/modules/cargo/pages/form_cargo/form_cargo_page.template.dart'
    as form_cargo_template;

import 'package:sibem_frontend/src/modules/curso/pages/lista_curso/lista_curso_page.template.dart'
    as lista_curso_template;
import 'package:sibem_frontend/src/modules/curso/pages/form_curso/form_curso_page.template.dart'
    as form_curso_template;

import 'package:sibem_frontend/src/modules/vaga/pages/lista_vaga/lista_vaga_page.template.dart'
    as lista_vaga_template;
import 'package:sibem_frontend/src/modules/vaga/pages/form_vaga/form_vaga_page.template.dart'
    as form_vaga_template;

import 'package:sibem_frontend/src/modules/candidato/pages/lista_candidato/lista_candidato_page.template.dart'
    as lista_candidato_template;
import 'package:sibem_frontend/src/modules/candidato/pages/form_candidato/form_candidato_page.template.dart'
    as form_candidato_template;

import 'package:sibem_frontend/src/modules/candidato/pages/lista_candidato_web/lista_candidato_web_page.template.dart'
    as lista_candidato_web_template;

import 'package:sibem_frontend/src/modules/tipo_conhecimento/pages/lista_tipo_conhecimento/lista_tipo_conhecimento_page.template.dart'
    as lista_tipo_conhecimento_template;

import 'package:sibem_frontend/src/modules/tipo_conhecimento/pages/form_tipo_conhecimento/form_tipo_conhecimento_page.template.dart'
    as form_tipo_conhecimento_template;

import 'package:sibem_frontend/src/modules/conhecimento_extra/pages/lista_conhecimento_extra/lista_conhecimento_extra_page.template.dart'
    as lista_conhecimento_extra_template;

import 'package:sibem_frontend/src/modules/conhecimento_extra/pages/form_conhecimento_extra/form_conhecimento_extra_page.template.dart'
    as form_conhecimento_extra_template;

import 'package:sibem_frontend/src/modules/escolaridade/pages/lista_escolaridade/lista_escolaridade_page.template.dart'
    as lista_escolaridade_template;
import 'package:sibem_frontend/src/modules/escolaridade/pages/form_escolaridade/form_escolaridade_page.template.dart'
    as form_escolaridade_page_template;

import 'package:sibem_frontend/src/modules/divisao_cnae/pages/lista_divisao_cnae/lista_divisao_cnae_page.template.dart'
    as lista_divisao_cnae_template;
import 'package:sibem_frontend/src/modules/divisao_cnae/pages/form_divisao_cnae/form_divisao_cnae_page.template.dart'
    as form_divisao_cnae_template;

import 'package:sibem_frontend/src/modules/tipo_deficiencia/pages/lista_tipo_deficiencia/lista_tipo_deficiencia_page.template.dart'
    as lista_tipo_deficiencia_template;
import 'package:sibem_frontend/src/modules/tipo_deficiencia/pages/form_tipo_deficiencia/form_tipo_deficiencia_page.template.dart'
    as form_tipo_deficiencia_template;

import 'package:sibem_frontend/src/modules/empregador/pages/lista_empregador/lista_empregador_page.template.dart'
    as lista_empregador_template;
import 'package:sibem_frontend/src/modules/empregador/pages/form_empregador/form_empregador_page.template.dart'
    as form_empregador_template;
import 'package:sibem_frontend/src/modules/empregador/pages/lista_empregador_web/lista_empregador_web_page.template.dart'
    as lista_empregador_web_template;

import 'package:sibem_frontend/src/modules/encaminhamento/pages/lista_encaminhamento/lista_encaminhamento_page.template.dart'
    as lista_encaminhamento_template;
import 'package:sibem_frontend/src/modules/encaminhamento/pages/form_encaminhamento/form_encaminhamento_page.template.dart'
    as form_encaminhamento_template;

import 'package:sibem_frontend/src/modules/relatorio/pages/relatorio_page/relatorio_page.template.dart'
    as relatorio_template;
import 'package:sibem_frontend/src/modules/estatistica/pages/estatistica_page/estatistica_page.template.dart'
    as estatistica_template;

import 'package:sibem_frontend/src/modules/auditoria/pages/lista_auditoria/lista_auditoria_page.template.dart'
    as lista_auditoria_template;

class Routes {
  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_template.HomePageNgFactory,
  );

  static final sessionExpired = RouteDefinition(
    routePath: RoutePaths.sessionExpired,
    component: session_expired_page_template.SessionExpiredPageNgFactory,
  );

  static final listaCargo = RouteDefinition(
    routePath: RoutePaths.listaCargo,
    component: lista_cargo_template.ListaCargoPageNgFactory,
  );
  static final formCargo = RouteDefinition(
    routePath: RoutePaths.formCargo,
    component: form_cargo_template.FormCargoPageNgFactory,
  );

  static final listaCurso = RouteDefinition(
    routePath: RoutePaths.listaCurso,
    component: lista_curso_template.ListaCursoPageNgFactory,
  );
  static final formCurso = RouteDefinition(
    routePath: RoutePaths.formCurso,
    component: form_curso_template.FormCursoPageNgFactory,
  );

  static final listaVaga = RouteDefinition(
    routePath: RoutePaths.listaVaga,
    component: lista_vaga_template.ListaVagaPageNgFactory,
  );
  static final formVaga = RouteDefinition(
    routePath: RoutePaths.formVaga,
    component: form_vaga_template.FormVagaPageNgFactory,
  );

  static final listaCandidato = RouteDefinition(
    routePath: RoutePaths.listaCandidato,
    component: lista_candidato_template.ListaCandidatoPageNgFactory,
  );
  static final formCandidato = RouteDefinition(
    routePath: RoutePaths.formCandidato,
    component: form_candidato_template.FormCandidatoPageNgFactory,
  );

  static final listaCandidatoWeb = RouteDefinition(
    routePath: RoutePaths.listaCandidatoWeb,
    component: lista_candidato_web_template.ListaCandidatoWebPageNgFactory,
  );

  static final listaTipoConhecimento = RouteDefinition(
    routePath: RoutePaths.listaTipoConhecimento,
    component:
        lista_tipo_conhecimento_template.ListaTipoConhecimentoPageNgFactory,
  );
  static final formTipoConhecimento = RouteDefinition(
    routePath: RoutePaths.formTipoConhecimento,
    component:
        form_tipo_conhecimento_template.FormTipoConhecimentoPageNgFactory,
  );

  static final listaConhecimentoExtra = RouteDefinition(
    routePath: RoutePaths.listaConhecimentoExtra,
    component:
        lista_conhecimento_extra_template.ListaConhecimentoExtraPageNgFactory,
  );
  static final formConhecimentoExtra = RouteDefinition(
    routePath: RoutePaths.formConhecimentoExtra,
    component:
        form_conhecimento_extra_template.FormConhecimentoExtraPageNgFactory,
  );

  static final listaEscolaridade = RouteDefinition(
    routePath: RoutePaths.listaEscolaridade,
    component: lista_escolaridade_template.ListaEscolaridadePageNgFactory,
  );
  static final formEscolaridade = RouteDefinition(
    routePath: RoutePaths.formEscolaridade,
    component: form_escolaridade_page_template.FormEscolaridadePageNgFactory,
  );

  static final listaDivisaoCnae = RouteDefinition(
    routePath: RoutePaths.listaDivisaoCnae,
    component: lista_divisao_cnae_template.ListaDivisaoCnaePageNgFactory,
  );
  static final formDivisaoCnae = RouteDefinition(
    routePath: RoutePaths.formDivisaoCnae,
    component: form_divisao_cnae_template.FormDivisaoCnaePageNgFactory,
  );

  static final listaTipoDeficiencia = RouteDefinition(
    routePath: RoutePaths.listaTipoDeficiencia,
    component:
        lista_tipo_deficiencia_template.ListaTipoDeficienciaPageNgFactory,
  );
  static final formTipoDeficiencia = RouteDefinition(
    routePath: RoutePaths.formTipoDeficiencia,
    component: form_tipo_deficiencia_template.FromTipoDeficienciaPageNgFactory,
  );

  static final listaEmpregador = RouteDefinition(
    routePath: RoutePaths.listaEmpregador,
    component: lista_empregador_template.ListaEmpregadorPageNgFactory,
  );
  static final formEmpregador = RouteDefinition(
    routePath: RoutePaths.formEmpregador,
    component: form_empregador_template.FormEmpregadorPageNgFactory,
  );
  static final listaEmpregadorWeb = RouteDefinition(
    routePath: RoutePaths.listaEmpregadorWeb,
    component: lista_empregador_web_template.ListaEmpregadorWebPageNgFactory,
  );

  static final listaEncaminhamento = RouteDefinition(
    routePath: RoutePaths.listaEncaminhamento,
    component: lista_encaminhamento_template.ListaEncaminhamentoPageNgFactory,
  );
  static final formEncaminhamento = RouteDefinition(
    routePath: RoutePaths.formEncaminhamento,
    component: form_encaminhamento_template.FormEncaminhamentoPageNgFactory,
  );

  static final relatorio = RouteDefinition(
    routePath: RoutePaths.relatorio,
    component: relatorio_template.RelatorioPageNgFactory,
  );
  static final estatistica = RouteDefinition(
    routePath: RoutePaths.estatistica,
    component: estatistica_template.EstatisticaPageNgFactory,
  );

  static final listaAuditoria = RouteDefinition(
    routePath: RoutePaths.listaAuditoria,
    component: lista_auditoria_template.ListaAuditoriaPageNgFactory,
  );

  static final allPrivate = <RouteDefinition>[
    home,
    sessionExpired,
    listaCargo,
    formCargo,
    listaCurso,
    formCurso,
    listaTipoConhecimento,
    formTipoConhecimento,
    listaConhecimentoExtra,
    formConhecimentoExtra,
    listaEscolaridade,
    formEscolaridade,
    listaDivisaoCnae,
    formDivisaoCnae,
    listaTipoDeficiencia,
    formTipoDeficiencia,
    listaEmpregador,
    listaEmpregadorWeb,
    formEmpregador,
    listaVaga,
    formVaga,
    listaCandidato,
    formCandidato,
    listaCandidatoWeb,
    listaEncaminhamento,
    formEncaminhamento,
    relatorio,
    estatistica,
    listaAuditoria,
  ];
}
