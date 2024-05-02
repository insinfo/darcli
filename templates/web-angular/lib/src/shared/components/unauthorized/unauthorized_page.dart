

import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'unauthorized-comp',
  templateUrl: 'unauthorized_page.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [],
)
class UnauthorizedPage {
  final Location _location;

  UnauthorizedPage(this._location);

  void back() {
    _location.back();
  }
}
