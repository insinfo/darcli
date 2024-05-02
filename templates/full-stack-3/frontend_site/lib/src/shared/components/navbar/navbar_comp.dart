import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'navbar-comp',
  templateUrl: 'navbar_comp.html',
  styleUrls: ['navbar_comp.css'],
  directives: [
    coreDirectives,
    formDirectives,
    routerDirectives,
  ],
  exports: [RoutePaths, LoginStatus],
)
class NavbarComponent implements OnInit {
  final AuthService authService;

  NavbarComponent(this.authService);

  @override
  void ngOnInit() {}

  /// esta logado ?
  bool get isLogged {
    return authService.loginStatus == LoginStatus.logged;
  }

  bool get isNotLogged {
    return authService.loginStatus == LoginStatus.notLogged;
  }

  bool get isEmpregador {
    return authService.authPayload.isEmpregador;
  }

  bool get jaCadastrado {
    return authService.authPayload.jaCadastrado ?? false;
  }

  void doLogout() {
    authService.doLogout();
  }
}
