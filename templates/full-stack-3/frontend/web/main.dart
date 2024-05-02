import 'package:sibem_frontend/sibem_frontend.dart';

import 'package:sibem_frontend/src/modules/app/app_component.template.dart'
    as ng;

import 'main.template.dart' as self;

@GenerateInjector([
  routerProvidersHash, // You can use routerProviders in production

  ClassProvider(RestConfig),
  ClassProvider(AuthService),
  //ClassProvider(RouterGuard),
  //ExistingProvider(RouterHook, RouterGuard),
  ClassProvider(NotificationComponentService),
  ClassProvider(CargoService),
  ClassProvider(CursoService),
  ClassProvider(TipoConhecimentoService),
  ClassProvider(ConhecimentoExtraService),
  ClassProvider(EscolaridadeService),
  ClassProvider(DivisaoCnaeService),
  ClassProvider(TipoDeficienciaService),
  ClassProvider(EmpregadorService),
  ClassProvider(UfService),
  ClassProvider(MunicipioService),
  ClassProvider(VagaService),
  ClassProvider(CandidatoService),
  ClassProvider(EncaminhamentoService),
  ClassProvider(RelatorioService),
  ClassProvider(EstatisticaService),
  ClassProvider(EmpregadorWebServiceWeb),
  ClassProvider(CandidatoWebService),
  ClassProvider(AuditoriaService),
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
