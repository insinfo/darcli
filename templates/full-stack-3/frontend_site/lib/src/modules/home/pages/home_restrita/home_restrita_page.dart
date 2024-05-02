import 'dart:async';
import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'home-restrita-page',
  templateUrl: 'home_restrita_page.html',
  styleUrls: ['home_restrita_page.css'],
  directives: [
    coreDirectives,
    routerDirectives,
    NavbarComponent,
  ],
  exports: [Routes, RoutePaths],
  providers: [],
)
class HomeRestritaPage implements OnInit, OnDestroy, CanActivate, OnDeactivate {
  LoginStatus loginStatus = LoginStatus.checking;

  final AuthService authService;
  // ignore: unused_field
  final Router _router;

  HomeRestritaPage(this.authService, this._router);

  @override
  Future<bool> canActivate(RouterState? current, RouterState next) async {
    return true;
  }

  @override
  void ngOnInit() async {}

  @override
  void ngOnDestroy() async {}

  @override
  void onDeactivate(RouterState current, RouterState next) {}
}
