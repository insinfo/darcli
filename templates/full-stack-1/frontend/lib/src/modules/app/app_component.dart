// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html' as html;

import 'package:new_sali_frontend/new_sali_frontend.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: [
    routerDirectives,
    coreDirectives,
  ],
  exports: [
    MyRoutes,
    RoutePaths,
  ],
)
class AppComponent implements OnInit, AfterViewInit {
  static bool isLogged = true;
  AuthService _authService;

  // ignore: unused_field
  Router _router;

  AppComponent(
    this._authService,
    this._router,
  );

  @override
  void ngOnInit() {
    //print('AppComponent@ngOnInit ${html.document.querySelector(".sidebar-secondary-toggle")}');

    html.document.addEventListener('keydown', (event) {
      if (event is html.KeyboardEvent &&
          _authService.loginStatus == LoginStatus.logged) {
        // ignore: unnecessary_cast
        var e = event as html.KeyboardEvent;
        var listKeys = ['F1', 'F2', 'F3', 'F4', 'F6', 'F7'];
        if (listKeys.contains(e.code)) {
          e.preventDefault();
        }

        switch (e.code) {
          case 'F1':
            // _router.navigate(
            //     RoutePaths.consultarProcesso.toUrl(),
            //     NavigationParams(queryParameters: {
            //       'a': '67',
            //       'f': '19',
            //       'm': '5',
            //       'g': '1'
            //     }));
            // break;
          case 'F2':
           
          case 'F3':
           
          case 'F4':
           
            break;
          case 'F6':
           
            break;
          case 'F7':
           
            break;
        }
      }
    });
  }

  @override
  void ngAfterViewInit() {
    //inicializa os comportamentos do limitless
    //js_interop.limitlessInitCore();
  }
}
