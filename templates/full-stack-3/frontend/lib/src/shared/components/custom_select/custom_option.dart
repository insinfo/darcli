import 'dart:html';

import 'package:sibem_frontend/sibem_frontend.dart';
import 'package:sibem_frontend/src/shared/components/custom_select/custom_select.dart';

@Component(
  selector: 'custom-option',
  templateUrl: 'custom_option.html',
//  styleUrls: ['custom_multi_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
)
class CustomOptionComp {
  @Input('value')
  dynamic value;

  final Element rootElement;

  CustomOptionComp(this.rootElement);

  CustomSelectComponent? parent;

  @HostListener('click')
  void handleOnClick(Event e) {
    e.stopPropagation();
    print('handleOnClick ');
    // parent.dropdownOnSelect(e, value, item?.firstChild?.text);
  }

  String get text {
    return rootElement.text ?? '';
  }

  set text(String inputText) {
    rootElement.text = inputText;
  }

  String? get innerHtml {
    return rootElement.innerHtml;
  }

  set innerHtml(String? inputText) {
    rootElement.innerHtml = innerHtml;
  }
}
