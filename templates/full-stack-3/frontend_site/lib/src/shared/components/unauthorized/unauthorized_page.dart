import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'unauthorized-comp',
  templateUrl: 'unauthorized_page.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [RoutePaths],
)
class UnauthorizedPage {
  final Location _location;

  UnauthorizedPage(this._location);

  void back() {
    _location.back();
  }
}
