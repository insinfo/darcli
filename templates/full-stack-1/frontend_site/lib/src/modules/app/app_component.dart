import 'package:new_sali_frontend_site/src/shared/routes/my_routes.dart';
import 'package:new_sali_frontend_site/src/shared/routes/route_paths.dart';
import 'package:ngdart/angular.dart';


@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    routerDirectives,
    coreDirectives,
  ],
  exports: [
    MyRoutes,
    RoutePaths,
  ],
)
class AppComponent {}
