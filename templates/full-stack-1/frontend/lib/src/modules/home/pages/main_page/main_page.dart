import 'dart:async';
import 'dart:convert';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/modules/home/components/main_menu/main_menu.dart';
import 'package:new_sali_frontend/src/modules/home/components/main_nav/main_nav.dart';

import 'dart:html' as html;

@Component(
  selector: 'main-page',
  templateUrl: 'main_page.html',
  styleUrls: ['main_page.css'],
  directives: [
    coreDirectives,
    routerDirectives,
    MainMenuComponent,
    MainNavComponent,
    NotificationComponent,
  ],
  pipes: [commonPipes],
  exports: [
    MyRoutes,
    LoginStatus,
    RoutePaths,
  ],
)
class MainPage implements OnInit, OnActivate, CanReuse, OnDestroy {
  StreamSubscription? _onNotifyStreamSubscription;
  final NotificationComponentService notificationComponentService;
  final AuthService _authService;
  final StatusBarService statusBarService;
  List<Toast> toasts = [];
  int toastsLimit = 20;

  String get toastsKey => 'toasts_${_authService.authPayload.numCgm}';

  MainPage(this.notificationComponentService, this.statusBarService,
      this._authService) {
    _onNotifyStreamSubscription =
        notificationComponentService.onNotify.listen((toast) {
      toasts.insert(0, toast);
      if (toasts.length > toastsLimit) {
        toasts.removeAt(toasts.length - 1);
      }
      updateToastsLocalStorage();
    });
  }

  void updateToastsLocalStorage() {
    html.window.localStorage[toastsKey] =
        jsonEncode(toasts.map((e) => e.toMap()).toList());
  }

  void getToastsFromLocalStorage() {
    if (html.window.localStorage.containsKey(toastsKey)) {
      final item = html.window.localStorage[toastsKey];

      if (item != null) {
        final json = jsonDecode(item);
        if (json is List) {
          toasts = json
              .whereType<Map<String, dynamic>>()
              .map((e) => Toast.fromMap(e))
              .toList();
        }
      }
    }
  }

  void toogleExpStatusBar() {
    statusBarService.toogleExpand();
  }

  @override
  void ngOnDestroy() {
    _onNotifyStreamSubscription?.cancel();
  }

  @override
  void ngOnInit() {
    getToastsFromLocalStorage();
  }

  @ViewChild('mainMenu')
  MainMenuComponent? mainMenu;

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    //so recarrega o menu em caso de reload da pagina ou quando faz login
    if (previous?.routePath.path == 'login' ||
        previous?.routePath.path == null) {
      await mainMenu?.loadMenus();
    }
  }

  @override
  Future<bool> canReuse(RouterState current, RouterState next) async {
    return true;
  }
}
