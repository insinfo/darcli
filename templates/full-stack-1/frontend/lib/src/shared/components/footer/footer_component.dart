

import 'package:new_sali_frontend/new_sali_frontend.dart';

@Component(
  selector: 'footer-comp',
  templateUrl: 'footer_component.html',
  // styleUrls: ['footer_comp.css'],
  directives: [
    routerDirectives,
  ],
  exports: [
    RoutePaths,
  ],
)
class FooterComponent {

  final Router _router;

  FooterComponent(this._router);

  void irParaSobre(){
    _router.navigate(RoutePaths.sobre.toUrl());
  }
  
}
