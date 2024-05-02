import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';


@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    routerDirectives,
    coreDirectives,
    NotificationComponent,
  ],
  exports: [Routes, RoutePaths],
)
class AppComponent
    implements OnInit, OnActivate, AfterContentInit, AfterViewInit {
  final NotificationComponentService notificationComponentService;
  final AuthService authService;
  bool isLogged = false;
  String message = 'Checando permissão...';

  final html.Element root;

  AppComponent(this.notificationComponentService, this.authService, this.root);

  @override
  void ngOnInit() async {
    isLogged = await authService.checkPermissionServer();
    if (!isLogged) {
      message =
          'Você não esta logado na Jubarte ou sua sessão expirou.Tente atualizar a pagina ou logar novamente!';
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) {}

  @override
  void ngAfterContentInit() {
    //print('AppComponent@ngAfterContentInit ');
  }

  @override
  void ngAfterViewInit() {
    // print('AppComponent@ngAfterViewInit ');
  }

  void toggleSubMenu(target, e) {
    final menuClass = 'dropdown-menu',
        submenuClass = 'dropdown-submenu',
        showClass = 'show';

    e.stopPropagation();
    e.preventDefault();
    final subMenu = target.closest('.$submenuClass');

    // Toggle classes
    subMenu?.classes.toggle(showClass);

    subMenu?.querySelectorAll(':scope > .$menuClass').forEach((children) {
      children.classes.toggle(showClass);
    });

    // When submenu is shown, hide others in all siblings
    final parentParentNode = target.parentNode?.parentNode;
    if (parentParentNode is html.Element) {
      for (var sibling in parentParentNode.children) {
        if (sibling != target.parentNode) {
          sibling.classes.remove(showClass);
          sibling.querySelectorAll('.$showClass').forEach((submenu) {
            submenu.classes.remove(showClass);
          });
        }
      }
    }

    // Hide all levels when parent dropdown is closed
    root.querySelectorAll('.$menuClass').forEach((link) {
      if (link.parent?.classes.contains(submenuClass) == false) {
        link.parent?.addEventListener('hidden.bs.dropdown', (e) {
          link.querySelectorAll('.$menuClass.$showClass').forEach((children) {
            children.classes.remove(showClass);
          });
        });
      }
    });
  }
}
