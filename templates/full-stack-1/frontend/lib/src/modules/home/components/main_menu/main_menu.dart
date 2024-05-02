import 'dart:async';
import 'dart:html' as html;
import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

import 'package:new_sali_frontend/src/shared/extensions/menu_extension.dart';
import 'package:new_sali_frontend/src/shared/js_interop/bootstrap_interop.dart'
    as bootstrap;

@Component(
  selector: 'main-menu',
  styleUrls: ['main_menu.css'],
  templateUrl: 'main_menu.html',
  directives: [
    coreDirectives,
    // NgTemplateOutlet,
  ],
  providers: [],
  exports: [RoutePaths],
)
class MainMenuComponent implements AfterViewInit, OnDestroy {
  @ViewChild('ulroot')
  html.UListElement? ulroot;

  @ViewChild('container')
  html.DivElement? container;

  @ViewChild('errorView')
  html.DivElement? errorView;

  final AuthService authService;
  final MenuService menuService;
  final RouterGuard _routerGuard;

  Router _router;
  Location _location;

  bool showError = false;

  /// sidebar Main Element
  html.Element _hostElement;
  late SimpleLoading _loading;

  MainMenuComponent(this.authService, this.menuService, this._router,
      this._location, this._hostElement, this._routerGuard) {
    //sidebar sidebar-dark sidebar-main sidebar-expand-lg
    _hostElement.classes.addAll(
        ['sidebar', 'sidebar-dark', 'sidebar-main', 'sidebar-expand-lg']);
    _loading = SimpleLoading();
  }

  List<MenuItem> list = [];

  bool falhaAoCarregar = false;

  MenuItem? lastMenuActive;

  List<MenuItem> mapeiRotas(List<MenuItem> list) {
    var currentPath = _location.path();

    currentPath =
        currentPath.contains('/') ? currentPath.split('/').last : currentPath;

    if (currentPath.contains('?')) {
      currentPath = currentPath.split('?').first;
    }

    list.forEach((gestao) {
      //ph-note
      //ph-newspaper-clipping
      var isActiveSetado = false;
      gestao.icone = 'ph-note';
      gestao.children.forEach((modulo) {
        modulo.children.forEach((func) {
          func.children.forEach((acao) {
            if (acao.codAcao != null) {
              //print('MainMenuComponent fill menus');
              authService.menus.add(acao);
            }

            acao.rota = acao.getRoutePath?.path;
            if (currentPath != 'nao-implementado') {
              if (currentPath == acao.rota && isActiveSetado == false) {
                lastMenuActive = acao;
                gestao.isCollapse = false;
                modulo.isCollapse = false;
                func.isCollapse = false;
                acao.active = true;
                //print('mapeiRotas codAcao: ${acao.codAcao} $currentPath');
                isActiveSetado = true;
              }
            }
          });
        });
      });
    });
    return list;
  }

  StreamSubscription? ssOnNavigate;
  bool ssOnNavigateInit = false;

  Future<void> loadMenus() async {
    if (ssOnNavigateInit == false) {
      ssOnNavigate = _routerGuard.onNavigate.listen((event) {
        var currentPath = event.routePath;
        var isActiveSetado = false;
        list.forEach((gestao) {
          gestao.children.forEach((modulo) {
            modulo.children.forEach((func) {
              func.children.forEach((acao) {
                if (currentPath.path == acao.getRoutePath?.path &&
                    isActiveSetado == false) {
                  if (currentPath.path != 'nao-implementado') {
                    lastMenuActive = acao;
                    gestao.isCollapse = false;
                    modulo.isCollapse = false;
                    func.isCollapse = false;
                    acao.active = true;
                    isActiveSetado = true;
                  }
                } else {
                  acao.active = false;
                  acao.isCollapse = true;
                }
              });
            });
          });
        });
      });
      ssOnNavigateInit = true;
    }
    try {
      _loading.show(target: container);
      var menus = <MenuItem>[];
      menus = await menuService.getAll();
      list = mapeiRotas(menus);

      showError = false;
    } catch (e, s) {
      print('MainMenuComponent@loadMenus $e, $s');
      showError = true;
    } finally {
      _loading.hide();
    }
  }

  void toggleMenu(e, html.AnchorElement a, MenuItem item) {
    //e.preventDefault();
    if (item.rota != null) {
      var routePath = item.getRoutePath;
      if (routePath != null) {
        var queryParameters = {
          'a': '${item.codAcao}',
          'f': '${item.codFuncionalidade}',
          'm': '${item.codModulo}',
          'g': '${item.codGestao}',
        };
        _router.navigate(routePath.toUrl(),
            NavigationParams(queryParameters: queryParameters));

        // if (lastMenuActive != null) {
        //   lastMenuActive!.active = false;
        //   lastMenuActive!.isCollapse = true;
        // }
        // lastMenuActive = item;
        // item.isCollapse = false;
        // item.active = true;
      }
    }

    // parte visual abrir e fechar os menus
    var navContainerClass = 'nav-sidebar',
        navItemOpenClass = 'nav-item-open',
        navSubmenuContainerClass = 'nav-item-submenu',
        navSubmenuClass = 'nav-group-sub';
    var navScrollSpyClass = 'nav-scrollspy';
    var navLinkClass = 'nav-link';
    var navLinkDisabledClass = 'disabled';

    var link = (e.target as html.Element?)?.closest(
        '.${navContainerClass}:not(.${navScrollSpyClass}) .${navSubmenuContainerClass} > .${navLinkClass}:not(.${navLinkDisabledClass})');

    if (link != null) {
      var submenuContainer = link.closest('.${navSubmenuContainerClass}');
      var submenu = link
          .closest('.${navSubmenuContainerClass}')!
          .querySelector(':scope > .${navSubmenuClass}');

      // Collapsible
      if (submenuContainer!.classes.contains(navItemOpenClass) == true) {
        bootstrap.Collapse(submenu!).hide();
        submenuContainer.classes.remove(navItemOpenClass);
      } else {
        bootstrap.Collapse(submenu!).show();
        submenuContainer.classes.add(navItemOpenClass);
      }

      // Accordion
      if (link
              .closest('.${navContainerClass}')!
              .getAttribute('data-nav-type') ==
          'accordion') {
        for (var sibling
            in (link.parentNode!.parentNode as html.Element).children) {
          if (sibling != link.parentNode &&
              sibling.classes.contains(navItemOpenClass)) {
            sibling
                .querySelectorAll(':scope > .${navSubmenuClass}')
                .forEach((submenu) {
              bootstrap.Collapse(submenu).hide();
              //print('accordion hide');
              sibling.classes.remove(navItemOpenClass);
            });
          }
        }
      }
    }
  }

  void sidebarMainResize(e) {
    e.preventDefault();
    var resizeClass = 'sidebar-main-resized';
    var unfoldClass = 'sidebar-main-unfold';
    // Toggle classes on click
    _hostElement.classes.toggle(resizeClass);
    !_hostElement.classes.contains(resizeClass) &&
        _hostElement.classes.remove(unfoldClass);
  }

  void initSidebarMainResize() {
    var resizeClass = 'sidebar-main-resized';
    var unfoldClass = 'sidebar-main-unfold';

    // Define variables
    const unfoldDelay = 150;
    Timer? timerStart;
    Timer? timerFinish;

    // Add class on mouse enter
    _hostElement.addEventListener('mouseenter', (e) {
      if (timerStart?.isActive == true) {
        timerStart!.cancel();
      }
      timerStart = Timer(Duration(milliseconds: unfoldDelay), () {
        _hostElement.classes.contains(resizeClass) &&
            _hostElement.classes.add(unfoldClass);
      });
    });
    // Remove class on mouse leave
    _hostElement.addEventListener('mouseleave', (e) {
      if (timerFinish?.isActive == true) {
        timerFinish!.cancel();
      }
      timerFinish = Timer(Duration(milliseconds: unfoldDelay), () {
        _hostElement.classes.remove(unfoldClass);
      });
    });
  }

  //ativa o evento de exibição ou escoder o menu para mobile ou tela pequena
  void initSidebarMainToggle() {
    var sidebarCollapsedClass = 'sidebar-collapsed';
    var sidebarMobileExpandedClass = 'sidebar-mobile-expanded';

    html.document.body?.onClick.listen((event) {
      var target = (event.target as html.Element);
      // On mobile
      var sidebarMobileBtn = target.closest('.sidebar-mobile-main-toggle');
      if (sidebarMobileBtn != null) {
        var sidebarMainElement = html.document.querySelector('.sidebar-main');
        var sidebarMainRestElements = html.document.querySelectorAll(
            '.sidebar:not(.sidebar-main):not(.sidebar-component)');
        sidebarMainElement!.classes.toggle(sidebarMobileExpandedClass);
        sidebarMainRestElements.forEach((sidebars) {
          sidebars.classes.remove(sidebarMobileExpandedClass);
        });
      }

      //On desktop
      var sidebarDesktopBtn = target.closest('.sidebar-main-toggle');
      if (sidebarDesktopBtn != null) {
        var sidebarMainElement = html.document.querySelector('.sidebar-main');
        sidebarMainElement!.classes.toggle(sidebarCollapsedClass);
      }
    });
  }

  @override
  void ngAfterViewInit() {
    initSidebarMainResize();
    initSidebarMainToggle();
  }

  @override
  void ngOnDestroy() {
    print('ngOnDestroy');
    ssOnNavigate?.cancel();
  }
}
