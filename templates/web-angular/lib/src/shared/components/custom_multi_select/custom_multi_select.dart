// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:html' as html;





import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';

import '../../directives/click_outside.dart';
import '../../exceptions/invalid_argument_exception.dart';
import '../../models/data_frame.dart';
import '../custom_select/custom_select.dart';
import 'custom_multi_option.dart';

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
/// <custom-multi-select  [dataSource]="dropdownOptions" [fields]="{'text': 'name', 'value': 'value'}"  (currentValueChange)="dropdownValueChanged($event)"></custom-multi-select>
@Component(
  selector: 'custom-multi-select',
  templateUrl: 'custom_multi_select.html',
  styleUrls: ['custom_multi_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
    ClickOutsideDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, CustomMultiSelectComponent),
  ],
)
class CustomMultiSelectComponent
    implements
        ControlValueAccessor<dynamic>,
        OnInit,
        OnDestroy,
        AfterContentInit {
  html.Element nativeElement;

  CustomMultiSelectComponent(this.nativeElement) {
    globalResizeSS = html.window.onResize.listen(handleWindowResize);
  }

  final StreamController<dynamic> _changeController = StreamController<dynamic>();
  StreamSubscription? globalWheelSS;
  StreamSubscription? globalResizeSS;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @ContentChildren(CustomMultiOptionComp)
  List<CustomMultiOptionComp> childrenSelectOptions = [];

  @override
  void ngAfterContentInit() {
    for (var opt in childrenSelectOptions) {
      opt.parent = this;

      options.add(
        _CustomSelectItem(
          value: opt.value,
          text: opt.text,
          instanceObj: opt.value,
        ),
      );
    }
  }

  @override
  void writeValue(dynamic newVal) {
    if (newVal == null) {
      for (var e in options) {
        e.selected = false;
      }
    } else if (newVal is List) {
      for (var nv in newVal) {
        for (var e in options) {
          if (nv == e.value) {
            e.selected = true;
          }
        }
      }
    }
  }

  dynamic Function(dynamic, {String rawValue})? _callback;

  @override
  void registerOnChange(callback) {
    _callback = callback;
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

  List<dynamic> get selectedValues =>
      options.where((opt) => opt.selected).map((e) => e.value).toList();

  List<String> get selectedLabels =>
      options.where((opt) => opt.selected).map((e) => e.text).toList();

  bool dropdownOpen = false;

  /// define de key used get label to diplay from data source options
  @Input('labelKey')
  String labelKey = 'label';

  @Input('valueKey')
  String? valueKey;

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
      for (var map in ops) {
        options.add(
          _CustomSelectItem(
            value: valueKey != null ? map[valueKey] : map,
            text: map[labelKey],
            instanceObj: map,
          ),
        );
      }
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
      //currentValue = options[0];
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

    dropdownOpen = false;

    for (var o in options) {
      o.visible = true;
    }
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

    dropdownOpen = true;
  }

  void onLiClickHandle(e, _CustomSelectItem value) {
    // currentValue = value;
    // closeDropdown();
    // _changeController.add(currentValue?.value);
    // if (_callback != null) {
    //   _callback!(currentValue?.value);
    // }
  }

  void onCheckboxClickHandle(event, _CustomSelectItem o) {
    //
    event.stopPropagation();
    o.selected = !o.selected;

    _changeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
    }
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

  @override
  void ngOnDestroy() {
    globalWheelSS?.cancel();
    globalResizeSS?.cancel();
  }

  void reset() {
    for (var element in options) {
      element.selected = false;
    }
    _changeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
    }
  }
}
