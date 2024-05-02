

import 'package:new_sali_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:new_sali_frontend_site/src/shared/routes/route_paths.dart';
import 'package:ngdart/angular.dart';


class Ano {
  final String value;
  final String label;
  final bool selected;
  Ano(this.value, this.label, this.selected);
}

@Component(
  selector: 'consulta-processo-page',
  styleUrls: ['consulta_processo_page.css'],
  templateUrl: 'consulta_processo_page.html',
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [],
)
class ConsultaProcessoPage implements OnInit {
  final Router _router;

  String codigoProcesso = '';
  String anoExcercicio = '';
  DateTime now = DateTime.now();
  int anoInicial = 2003;
  List<Ano> anos = [];

  ConsultaProcessoPage(this._router) {
    anoExcercicio = now.year.toString();
    anos = List.generate((now.year + 1) - anoInicial, (index) {
      final value = '${index + anoInicial}';
      return Ano(value, value, value == now.year.toString());
    })
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  void clear() {
    codigoProcesso = '';
    anoExcercicio = now.year.toString();
  }

  @override
  void ngOnInit() async {}

  void onSubmit() {   
    irParaProcesso();
  }

  void irParaProcesso() {    
    if (int.tryParse(codigoProcesso) != null) {
      _router.navigate(
        RoutePaths.visualizaProcesso.toUrl(
            parameters: {'cdp': '$codigoProcesso', 'ae': '$anoExcercicio'}),
        NavigationParams(queryParameters: {}),
      );
    }else{
       SimpleDialogComponent.showAlert('Código de processo é inválido!');
    }
  }
}
