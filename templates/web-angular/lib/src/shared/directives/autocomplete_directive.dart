import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';

@Directive(selector: '[customAutocomplete]')
class CustomAutocompleteDirective implements OnDestroy {
  final Element _el;
  late InputElement inputElement;
  StreamSubscription<Event>? onChangeStreamSubscription;

  StreamSubscription<Event>? onGlobalClickStreamSubscription;

  CustomAutocompleteDirective(this._el) {
    inputElement = _el as InputElement;
    onChangeStreamSubscription = inputElement.onInput.listen((e) {
      _onChange();
    });

    onGlobalClickStreamSubscription = document.body!.onClick.listen((e) {
      divRoot?.hidden = true;
    });
  }

  @Input('autocomplete')
  Future<List<String>> Function(String val)? onRequest;
  DivElement? divRoot;

  List<String> items = [];
  String idOfRootElement = '__autocomplete';

  void _onChange() async {
    var text = inputElement.value!;
    //print('AutocompleteDirective _onChange $text');
    if (text.length > 2 && onRequest != null) {
      items = await onRequest!(text);
      draw();
    }
  }

  void draw() {
    divRoot = inputElement.parent?.querySelector('div.$idOfRootElement')
        as DivElement?;
    UListElement ulRoot;
    if (divRoot == null) {
      divRoot = DivElement();
      divRoot!.hidden = true;
      divRoot!.classes.add(idOfRootElement);
      divRoot!.style.padding = '10px';
      divRoot!.style.minWidth = '100px';
      divRoot!.style.minHeight = '100px';
      divRoot!.style.width = 'fit-content';
      divRoot!.style.height = 'fit-content';
      divRoot!.style.position = 'absolute';
      divRoot!.style.zIndex = '10000';
      divRoot!.style.background = 'white';
      divRoot!.style.boxShadow =
          '0 1px 3px rgb(0 0 0 / 12%), 0 1px 2px rgb(0 0 0 / 24%)';
      ulRoot = UListElement();
      ulRoot.style.listStyle = 'none';
      ulRoot.style.padding = '0';
      divRoot?.append(ulRoot);
      inputElement.parent?.append(divRoot!);
    } else {
      ulRoot = divRoot!.querySelector('ul') as UListElement;
    }

    if (divRoot!.attributes['data-stop-propagation'] == null) {
      divRoot!.onClick.listen((e) => e.stopPropagation());
      divRoot!.attributes['data-stop-propagation'] = 'true';
    }

    ulRoot.innerHtml = '';
    var idx = 0;
    for (var element in items) {
      final li = LIElement();
      li.tabIndex = idx;
      li.style.padding = '3px';
      li.text = element;
      li.onClick.listen((event) {
        inputElement.value = li.text;
        divRoot!.hidden = true;
      });
      ulRoot.append(li);
      //idx++;
    }

    divRoot!.hidden = false;
  }

  @override
  void ngOnDestroy() {
    onChangeStreamSubscription?.cancel();
    onGlobalClickStreamSubscription?.cancel();
  }
}
