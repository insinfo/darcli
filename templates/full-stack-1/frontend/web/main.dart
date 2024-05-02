import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/modules/protocolo/services/processo_favorito_service.dart';

import 'main.template.dart' as self;
import 'package:new_sali_frontend/src/modules/app/app_component.template.dart'
    as ng;

import 'package:intl/intl.dart'; //for date format
import 'package:intl/date_symbol_data_local.dart'; //for date locale

@GenerateInjector([
  routerProvidersHash,
  ClassProvider(RestConfig),
  ClassProvider(AuthService),
  ClassProvider(RouterGuard),
  ExistingProvider(RouterHook, RouterGuard),
  ClassProvider(MenuService), 
  ClassProvider(NotificationComponentService),
  //
  ClassProvider(AdministracaoService),
 
  ClassProvider(EstatisticaService),
  ClassProvider(AcaoService),
  ClassProvider(ModuloService), 
  ClassProvider(FuncionalidadeService),  
  ClassProvider(UsuarioService),
  ClassProvider(PermissaoService), 
  ClassProvider(ProcessoFavoritoService),
  ClassProvider(AcaoFavoritaService), 
  ClassProvider(StatusBarService),
 
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  // set pt_BR globalmente
  initializeDateFormatting('pt_BR')
      .then((value) => Intl.defaultLocale = 'pt_BR');

  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
