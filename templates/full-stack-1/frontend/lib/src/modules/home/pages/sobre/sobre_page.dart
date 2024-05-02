import 'package:ngdart/angular.dart';


@Component(
  selector: 'sobre-page',
  templateUrl: 'sobre_page.html',
  styleUrls: ['sobre_page.css'],
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  pipes: [commonPipes],
  exports: [],
)
class SobrePage implements OnInit, OnActivate {
  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState? previous, RouterState current) {}
}
