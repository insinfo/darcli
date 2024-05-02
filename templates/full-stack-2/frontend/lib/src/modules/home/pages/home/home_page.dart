import 'package:esic_frontend/src/shared/route_paths.dart';
import 'package:esic_frontend/src/shared/routes.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
    selector: 'home-page',
    //styleUrls: ['app_component.css'],
    templateUrl: 'home_page.html',
    directives: [
      coreDirectives,
      routerDirectives,
    ],
    exports: [
      Routes,
      RoutePaths,
    ])
class HomePage {
  HomePage();
}
