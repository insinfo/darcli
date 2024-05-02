import 'package:esic_frontend/src/shared/components/datatable/datatable_component.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'lista-usuario-page',
  templateUrl: 'lista_usuario_page.html',
  styleUrls: ['lista_usuario_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DatatableComponent,
  ],
  providers: [],
)
class ListaUsuarioPage implements OnActivate {
  @override
  void onActivate(RouterState? previous, RouterState current) {
    //
  }
}
