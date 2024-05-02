import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'footer-comp',
  templateUrl: 'footer_comp.html',
  styleUrls: ['footer_comp.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  exports: [],
)
class FooterComponent implements OnInit {
  @override
  void ngOnInit() {}
}
