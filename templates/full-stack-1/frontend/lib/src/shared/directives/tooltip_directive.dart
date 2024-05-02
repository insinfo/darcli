import 'dart:async';
import 'dart:html';
import 'package:ngdart/angular.dart';

///
///
/// baseada em
///
@Directive(selector: '[tooltip]')
class TooltipDirective implements OnDestroy, OnInit {
  Element nativeElement;

  StreamSubscription? onMouseOverSS;
  StreamSubscription? onMouseOutSS;
  late Element base;

  @Input('tooltip')
  String? tooltip;

  TooltipDirective(this.nativeElement) {
    //nativeElement.onMouseMove.listen(onMouseOver);
    nativeElement.onMouseOver.listen(onMouseOver);
    nativeElement.onMouseOut.listen(onMouseOut);
    base = document.createElement('tooltip');

    //base.style.position = 'absolute';
    // base.style.background = '#fff';
    // base.style.color = '#333';
    // base.style.border = '1px solid #ddd';
    // base.style.borderRadius = '10px';
    // base.style.padding = '10px';
    // base.style.fontSize = '15px';
    base.attributes['class'] =
        'tooltip tooltip-custom bs-tooltip-auto fade show';
    base.attributes['style'] =
        'position: absolute; inset: 0px auto auto 0px; margin: 0px; transform: translate(326px, 332px);';
    base.attributes['data-popper-placement'] = 'bottom';

    var tooltipArrow = DivElement();
    tooltipArrow.attributes['class'] = 'tooltip-arrow border-primary';
    tooltipArrow.attributes['style'] =
        'position: absolute; left: 0px; transform: translate(20px, 0px);';
    base.append(tooltipArrow);

    var tooltipInner = DivElement();
    tooltipInner.attributes['class'] = 'tooltip-inner bg-primary text-white';
    base.append(tooltipInner);
    // <div class="tooltip tooltip-custom bs-tooltip-auto fade" role="tooltip" id="tooltip432836"
    // data-popper-placement="bottom"
    // style="position: absolute; inset: 0px auto auto 0px; margin: 0px; transform: translate(326px, 332px);">
    //   <div class="tooltip-arrow border-primary" style="position: absolute; left: 0px; transform: translate(0px, 0px);">
    //   </div>
    //   <div class="tooltip-inner bg-primary text-white">Primary tooltip
    //   </div>
    // </div>
  }

  void onMouseOver(MouseEvent event) {
    var text = tooltip; //nativeElement.getAttribute('tooltip');

    //var box = nativeElement.getBoundingClientRect();

    if (text != null) {
      base.querySelector('.tooltip-inner')?.text = text;

      // Checking if tooltip is empty or not.

      if (document.getElementsByTagName('tooltip').isNotEmpty) {
        // Checking for any "tooltip" element
        document
            .getElementsByTagName('tooltip')[0]
            .remove(); // Removing old tooltip
      }
      //  base.style.top = (event.pageY + 10) + 'px';
      // base.style.top = '${event.page.y + 10}px';
      // base.style.left = '${event.page.x + 10}px';
      // base.style.top = '${box.top - box.height}px';
      // base.style.left = '${box.left + 10}px';
      base.style.transform =
          'translate(${event.page.x + 10}px, ${event.page.y + 10}px)';
      document.body?.append(base);
    }
  }

  void onMouseOut(MouseEvent event) {
    if (document.getElementsByTagName('tooltip').isNotEmpty) {
      document
          .getElementsByTagName('tooltip')[0]
          .remove(); // Remove last tooltip
    }
  }

  @override
  void ngOnInit() {}

  @override
  void ngOnDestroy() {
    onMouseOverSS?.cancel();
  }
}
