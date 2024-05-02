// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:new_sali_frontend/new_sali_frontend.dart';

import 'dart:html' as html;

@Component(
  selector: 'main-nav',
  styleUrls: ['main_nav.css'],
  templateUrl: 'main_nav.html',
  directives: [
    coreDirectives,
    formDirectives,
    // NgTemplateOutlet,
  ],
  pipes: [commonPipes, TruncatePipe, TitleCasePipe],
  providers: [],
  exports: [RoutePaths],
)

/// <main-menu class="sidebar sidebar-dark sidebar-main sidebar-expand-lg"></main-menu>
class MainNavComponent implements OnInit {
  AuthService authService;
  StatusBarService _statusBarService;

  // ignore: unused_field
  final Router _router;

  MainNavComponent(this.authService, this._statusBarService, this._router);

  void logout() {
    authService.doLogout();
  }

  void handleSearch(e, String? searchString) {
    e.preventDefault();
    irParaProcesso(searchString);
  }

  void irParaProcesso(String? searchString) {}

  @override
  void ngOnInit() {
    //print('MainNavComponent@ngOnInit');
    //=> html.querySelector('html')!.hasAttribute('data-color-theme')
    final theme = html.window.localStorage['color-theme'];
    if (theme == 'dark') {
      html.querySelector('html')?.dataset['color-theme'] = 'dark';
    } else if (theme == 'blu') {
      html.querySelector('html')?.dataset['color-theme'] = 'blu';
    } else if (theme == 'pin') {
      html.querySelector('html')?.dataset['color-theme'] = 'pin';
    } else {
      html.querySelector('html')!.attributes.remove('data-color-theme');
    }
  }

  void toggleStatusBar() {
    _statusBarService.toggle();
  }

  void changeTheme(String theme) {
    if (theme == 'light') {
      html.querySelector('html')!.attributes.remove('data-color-theme');
      html.window.localStorage['color-theme'] = 'light';
    } else if (theme == 'dark') {
      html.querySelector('html')?.dataset['color-theme'] = 'dark';
      html.window.localStorage['color-theme'] = 'dark';
    } else if (theme == 'blu') {
      html.querySelector('html')?.dataset['color-theme'] = 'blu';
      html.window.localStorage['color-theme'] = 'blu';
    } else if (theme == 'pin') {
      html.querySelector('html')?.dataset['color-theme'] = 'pin';
      html.window.localStorage['color-theme'] = 'pin';
    }
  }
}
