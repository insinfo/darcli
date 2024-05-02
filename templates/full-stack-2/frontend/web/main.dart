import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';
import 'package:esic_frontend/src/shared/services/auth_service.dart';
import 'package:esic_frontend/src/shared/rest_config.dart';
import 'main.template.dart' as self;

import 'package:esic_frontend/src/modules/app/pages/app_component.template.dart'
    as ng;

@GenerateInjector([
  routerProvidersHash, // You can use routerProviders in production
  ClassProvider(RestConfig),
  ClassProvider(AuthService)
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
