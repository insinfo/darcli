import 'dart:async';
import 'dart:html' as html;
import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/shared/exceptions/invalid_argument_exception.dart';

import 'custom_option.dart';

class _CustomSelectItem {
  String text;
  dynamic value;
  bool selected = false;
  bool hover = false;
  bool visible = true;
  //Map<String, dynamic>? instanceMap;
  dynamic instanceObj;
  _CustomSelectItem(
      {required this.text,
      this.value,
      // this.selected = false,
      // this.hover = false,
      // this.instanceMap,
      this.instanceObj});
}

///
/// <custom-select [title]="'My dropdown'" [dataSource]="dropdownOptions" [fields]="{'text': 'name', 'value': 'value'}"  (currentValueChange)="dropdownValueChanged($event)"></custom-select>
@Component(
  selector: 'custom-select',
  templateUrl: 'custom_select.html',
  styleUrls: ['custom_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
    ClickOutsideDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, CustomSelectComponent),
  ],
)
class CustomSelectComponent
    implements
        ControlValueAccessor<dynamic>,
        OnInit,
        OnDestroy,
        AfterContentInit {
  html.Element nativeElement;

  CustomSelectComponent(this.nativeElement) {
    globalResizeSS = html.window.onResize.listen(handleWindowResize);
  }

  /// Stream Controller do currentValueChange event
  StreamController<dynamic> _changeController = StreamController<dynamic>();
  StreamSubscription? globalWheelSS;
  StreamSubscription? globalResizeSS;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @ContentChildren(CustomOptionComp)
  List<CustomOptionComp> childrenSelectOptions = [];

  @override
  void ngAfterContentInit() {
    childrenSelectOptions.forEach((opt) {
      opt.parent = this;

      options.add(
        _CustomSelectItem(
          value: opt.value,
          text: opt.text,
          instanceObj: opt.value,
        ),
      );
    });
  }

  @override
  void writeValue(dynamic newVal) {
    //value = newVal ?? '';
    //print('writeValue $newVal');
    if (newVal == null) {
      currentValue = null;
    } else {
      //value
      for (var opt in options) {
        if (opt.value == newVal) {
          currentValue = opt;
          break;
        }
      }
      if (options.where((o) => o.value == newVal).isEmpty) {
        currentValue = null;
      }
    }
  }

  /// ngModel Value Change Callback
  dynamic Function(dynamic, {String rawValue})? _ngModelValueChangeCallback;

  @override
  void registerOnChange(callback) {
    _ngModelValueChangeCallback = callback;
  }

  // optionally you can implement the rest interface methods
  @override
  void registerOnTouched(TouchFunction callback) {}

  @override
  void onDisabledChanged(bool state) {}

  @ViewChild('dropdownContainer')
  html.Element? dropdownContainerEle;

  @ViewChild('inputSearch')
  html.InputElement? inputSearch;

  @ViewChild('dropdownButton')
  html.Element? dropdownButtonElement;

  int currentIndex = -1;
  _CustomSelectItem? currentValue;
  bool dropdownOpen = false;

  @Input('id')
  String id = 'custom_select_1';

  /// maps the local data column to fields property ex: {'text': 'Name', 'value': 'Code'}
  // @Input('fields')
  // Map<String, String> fields = {'text': 'text', 'value': 'value'};

  /// define de key used get label to diplay from data source options
  @Input('labelKey')
  String labelKey = 'label';

  @Input('valueKey')
  String? valueKey;

  // @Input('isReturnInstanceOnSelected')
  // bool isReturnInstanceOnSelected = false;

  List<_CustomSelectItem> options = [];

  int get minHeight {
    var mh = options.length < 5 ? options.length * 25 : 5 * 25;
    return mh;
  }

  html.Element get listElement => dropdownContainerEle!.querySelector('ul')!;

  /// dataSource
  @Input()
  set dataSource(dynamic ops) {
    options = [];
    if (ops is List<Map<String, dynamic>>) {
      ops.forEach((map) {
        options.add(
          _CustomSelectItem(
            value: valueKey != null ? map[valueKey] : map,
            text: map[labelKey],
            instanceObj: map,
          ),
        );
      });
    } else if (ops is DataFrame) {
      var opAsMap = ops.itemsAsMap;
      for (var i = 0; i < ops.length; i++) {
        var map = opAsMap[i];
        options.add(
          _CustomSelectItem(
            value: valueKey != null ? map[valueKey] : ops[i],
            text: map[labelKey] ?? '',
            instanceObj: ops[i],
          ),
        );
      }
    } else {
      throw InvalidArgumentException(CustomSelectComponent, ops);
    }
  }

  //placeholder
  @Input()
  String placeholder = 'Selecione';

  html.DivElement backdropDiv = html.DivElement();

  bool isScrollable(html.Element? ele) {
    if (ele == null) {
      return false;
    }
    // var hasScrollableContent = ele.scrollHeight > ele.clientHeight;
    // if (hasScrollableContent) {
    //   return true;
    // }
    //
    var overflowYStyle = ele.getComputedStyle().overflowY;
    if (overflowYStyle.contains('auto')) {
      return true;
    }

    if (overflowYStyle.contains('scroll')) {
      return true;
    }
    var overflowStyle = ele.getComputedStyle().overflow;
    if (overflowStyle.contains('auto')) {
      return true;
    }
    if (overflowStyle.contains('scroll')) {
      return true;
    }
    return false;
  }

  dynamic getScrollableParent(html.Element? ele) {
    if (ele == null || ele == html.document.body) {
      return html.document.body;
    }
    //print('ele  ${ele}');
    if (isScrollable(ele)) {
      return ele;
    } else {
      var parent = ele.parent;
      //print('parent ${parent}');
      return getScrollableParent(parent);
    }
  }

  @override
  void ngOnInit() {
    //dropdownContainerEle.onMouseWheel.listen((e) => e.stopPropagation());

    backdropDiv.classes.add('CustomSelectComponent');
    backdropDiv.style.position = 'fixed';
    backdropDiv.style.top = '0';
    backdropDiv.style.left = '0';
    backdropDiv.style.width = '100%';
    backdropDiv.style.height = '100%';
    //backdropDiv.style.backgroundColor = '#000';
    backdropDiv.style.zIndex = '1000';
    backdropDiv.style.pointerEvents = 'none';
    //backdropDiv.style.overflow = 'visible'; //hidden visible auto
    //body.style.overflow = "hidden";
    //backdropDiv.style.opacity = '.5';
    html.document.body!.append(backdropDiv);
    dropdownContainerEle!.style.position = 'fixed';
    dropdownContainerEle!.style.pointerEvents = 'auto';
    dropdownContainerEle!.style.zIndex = '1000';
    backdropDiv.append(dropdownContainerEle!);

    if (options.isNotEmpty == true) {
      currentValue = options[0];
    }
  }

  void setPositionOfDropdown() {
    final box = dropdownButtonElement!.getBoundingClientRect();
    // final nativeEleCompStyle = dropdownButtonElement.getComputedStyle();
    dropdownContainerEle!.style.top = '${box.top + box.height}px';
    dropdownContainerEle!.style.left = '${box.left}px';
    dropdownContainerEle!.style.width = '${box.width}px';

    var maxH = html.window.innerHeight! - (box.top + box.height + 90);
    listElement.style.maxHeight = '${maxH}px';
    listElement.style.minHeight = '${minHeight}px';

    //dropdownContainerEle.style.transform = 'transform: translateY(0px);';
  }

  void closeDropdown() {
    dropdownContainerEle!.querySelectorAll('li').forEach((element) {
      if (element.classes.contains('dropdown-item-hover')) {
        element.classes.remove('dropdown-item-hover');
      }
    });
    dropdownContainerEle!.setAttribute('aria-expanded', 'false');
    currentIndex = -1;
    dropdownOpen = false;

    options.forEach((o) {
      o.visible = true;
    });
    inputSearch?.value = '';

    //removePreventScrolling(html.document.body);
    globalWheelSS?.cancel();
  }

  void openDropdown() {
    //addPreventScrolling(html.document.body);
    setPositionOfDropdown();
    //pega o primeito pai com overflow auto ou overflow |  overflow-y: auto;
    var re = getScrollableParent(nativeElement);

    globalWheelSS = re?.onScroll?.listen(handleBodyWheel);
    //open
    dropdownContainerEle!.setAttribute('aria-expanded', 'true');
    currentIndex = -1;
    dropdownOpen = true;
    Future.delayed(Duration(milliseconds: 20), () {
      //print('openDropdown focus');
      inputSearch?.focus();
    });
  }

  /// seleciona um item programaticamente pelo value da instancia das options
  /// [isCloseDropDown] fecha o dropdown se estivar aberto
  /// [isCallNgModelChange] define o ngModel (ngModel)="value"
  /// [isCallCurrentValueChange] chama o evento (currentValueChange)
  void setSelectedItemByValue(dynamic value,
      {bool isCloseDropDown = true,
      bool isCallNgModelChange = true,
      bool isCallCurrentValueChange = true}) {
    for (var i = 0; i < options.length; i++) {
      var opt = options[i];
      if (opt.value == value) {
        currentValue = opt;

        if (isCloseDropDown && dropdownOpen == true) {
          closeDropdown();
        }
        if (isCallCurrentValueChange) {
          _changeController.add(currentValue?.value);
        }
        if (isCallNgModelChange && _ngModelValueChangeCallback != null) {
          _ngModelValueChangeCallback!(currentValue?.value);
        }
      }
    }
  }

  void select(_CustomSelectItem selItem) {
    currentValue = selItem;
    closeDropdown();
    _changeController.add(currentValue?.value);
    if (_ngModelValueChangeCallback != null) {
      _ngModelValueChangeCallback!(currentValue?.value);
    }
    // currentValueChangeSC.add(isReturnInstanceOnSelected == true
    //     ? currentValue?.instanceObj
    //     : currentValue?.value);
  }

  void toggleDropdown() {
    dropdownOpen = !dropdownOpen;
    //dropdownElement.setAttribute( 'aria-expanded', dropdownOpen ? 'true' : 'false');
    if (dropdownOpen) {
      openDropdown();
    } else {
      closeDropdown();
    }
  }

  void _selectOptionFromIndex() {
    //options[currentIndex].hover = true;
    for (var i = 0; i < options.length; i++) {
      if (i == currentIndex) {
        options[currentIndex].hover = true;
      } else {
        options[currentIndex].hover = false;
      }
    }

    dropdownContainerEle!.querySelectorAll('li').forEach((element) {
      if (element.classes.contains('dropdown-item-hover')) {
        element.classes.remove('dropdown-item-hover');
      }
    });

    dropdownContainerEle!
        .querySelectorAll('li')[currentIndex]
        .classes
        .add('dropdown-item-hover');
    currentValue = options[currentIndex];
    _changeController.add(currentValue?.value);
  }

  /// implement keyboard navigation
  @HostListener('keydown')
  void handleKeydownEvents(html.KeyboardEvent event) {
    //print('handleKeydownEvents keydown $event');
    event.preventDefault();

    if (event.code == 'Enter' || event.code == 'NumpadEnter') {
      if (dropdownOpen == true) {
        closeDropdown();
      } else {
        openDropdown();
      }
    } else if (event.code == 'ArrowUp') {
      if (currentIndex < 0) {
        currentIndex = 0;
      } else if (currentIndex > 0) {
        currentIndex--;
      }

      _selectOptionFromIndex();
    } else if (event.code == 'ArrowDown') {
      if (currentIndex < 0) {
        currentIndex = 0;
      } else if (currentIndex < options.length - 1) {
        currentIndex++;
      }

      _selectOptionFromIndex();
    } else if (event.code == 'Escape') {
      closeDropdown();
    }
  }

  //@HostListener('wheel')
  void handleBodyWheel(e) {
    if (dropdownOpen == true) {
      final box = dropdownButtonElement!.getBoundingClientRect();
      var result = (box.top + box.height).round();
      //dropdownContainerEle.style.transform = 'translateY(${result}px)';
      dropdownContainerEle!.style.top = '${result}px';
      // print('handleBodyWheel');
      //setPositionOfDropdown();
      //closeDropdown();
    }
  }

  void handleWindowResize(e) {
    setPositionOfDropdown();
  }

  void searchHandle(String? searchString, html.KeyboardEvent e) {
    if (searchString != null && searchString.trim().isNotEmpty == true) {
      options.forEach((o) {
        //busca pelo label ou pelo value
        if ((o.text.containsIgnoreAccents(searchString)) == true ||
            o.value.toString() == searchString) {
          o.visible = true;
        } else {
          o.visible = false;
        }
      });
    } else {
      options.forEach((o) {
        o.visible = true;
      });
    }
  }

  @override
  void ngOnDestroy() {
    globalWheelSS?.cancel();
    globalResizeSS?.cancel();
  }
}
