import 'package:esic_frontend_site/src/modules/public/home/pages/home/home_page.dart';

import 'package:ngdart/angular.dart';

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [
      coreDirectives,
      HomePage,
    ],
    exports: [])
class AppComponent {}
