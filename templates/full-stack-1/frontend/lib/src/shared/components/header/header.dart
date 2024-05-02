import 'package:new_sali_frontend/new_sali_frontend.dart';

@Component(
  selector: 'header-comp',
  templateUrl: 'header.html',
  styleUrls: ['header.css'],
  directives: [
    routerDirectives,
  ],
  exports: [RoutePaths],
)
class HeaderComp {}
