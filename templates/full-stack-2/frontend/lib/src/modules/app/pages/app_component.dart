import 'package:esic_frontend/src/shared/services/auth_service.dart';
import 'package:esic_frontend/src/modules/home/pages/home/home_page.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
    HomePage,
  ],
)
class AppComponent implements OnInit {
  bool isLogged = true;
  final AuthService authService;
  AppComponent(this.authService);

  @override
  void ngOnInit() async {
    /*isLogged = await authService.checkPermissionServer();
    if (!isLogged) {
      message =
          'Você não esta logado  ou sua sessão expirou.<\BR>Tente atualizar a pagina ou logar novamente!';
    }*/
  }

  String message = 'Checando permissão...';
}
