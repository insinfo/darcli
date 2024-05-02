import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';

import 'package:esic_frontend_site/src/modules/app/pages/app_component.template.dart'
    as ng;

import 'package:esic_frontend_site/src/shared/rest_config.dart';

import 'main.template.dart' as self;

@GenerateInjector([
  routerProvidersHash, // You can use routerProviders in production
  ClassProvider(RestConfig),
  ClassProvider(AuthService),
  //ClassProvider(CadastroPageService),
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
