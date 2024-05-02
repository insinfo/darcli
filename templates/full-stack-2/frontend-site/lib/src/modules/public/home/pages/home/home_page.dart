import 'package:esic_frontend_site/src/shared/components/footer/footer_component.dart';
import 'package:esic_frontend_site/src/shared/components/header/header.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/routes.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'home-page',
  templateUrl: 'home_page.html',
  styleUrls: ['home_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    routerDirectives,
    HeaderComponent,
    FooterComponent,
  ],
  providers: [],
  exports: [
    RoutePaths,
    PublicRoutes,
  ],
)
class HomePage {}
