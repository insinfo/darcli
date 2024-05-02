import 'package:ngdart/angular.dart';

/// este componente é para representar uma lista vazia
/// <no-data-component message="Não ha items aqui!"></no-data-component>
@Component(
  selector: 'no-data-component',
  templateUrl: 'no_data_component.html',
  styleUrls: ['no_data_component.css'],
  directives: [
    coreDirectives,
  ],
)
class NoDataComponent {


  @Input('message')
  String message = 'Não ha items aqui!';
}
