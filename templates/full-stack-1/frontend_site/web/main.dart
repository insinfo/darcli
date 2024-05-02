import 'package:ngdart/angular.dart';


import 'main.template.dart' as self;
import 'package:new_sali_frontend_site/src/modules/app/app_component.template.dart'
    as ng;

import 'package:intl/intl.dart'; //for date format
import 'package:intl/date_symbol_data_local.dart'; //for date locale

@GenerateInjector([
  routerProvidersHash,
 
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  // set pt_BR globalmente
  initializeDateFormatting('pt_BR')
      .then((value) => Intl.defaultLocale = 'pt_BR');

  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
