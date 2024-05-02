import 'package:sibem_frontend_site/sibem_frontend_site.dart';

import 'package:sibem_frontend_site/src/modules/app/app_component.template.dart'
    as ng;

import 'package:sibem_frontend_site/src/shared/services/router_guard.dart';

import 'main.template.dart' as self;

@GenerateInjector([
  routerProvidersHash, // You can use routerProviders in production
  ClassProvider(RestConfig),
  ClassProvider(AuthService),
  ClassProvider(RouterGuard),
  ExistingProvider(RouterHook, RouterGuard),
  ClassProvider(NotificationComponentService),
  ClassProvider(UsuarioService),
  ClassProvider(VagaService),
  ClassProvider(UfService),
  ClassProvider(MunicipioService),
  ClassProvider(TipoDeficienciaService),
  ClassProvider(EscolaridadeService),
  ClassProvider(CargoService),
  ClassProvider(CandidatoWebService),
  ClassProvider(EmpregadorWebService),
  ClassProvider(DivisaoCnaeService),
  ClassProvider(CursoService),
  ClassProvider(ConhecimentoExtraService),
  ClassProvider(VagaBeneficioService),
  ClassProvider(CandidatoService),
  ClassProvider(EncaminhamentoService),
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
