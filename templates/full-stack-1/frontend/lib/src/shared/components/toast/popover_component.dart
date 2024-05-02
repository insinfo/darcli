import 'dart:async';
import 'dart:html';

import 'package:new_sali_frontend/new_sali_frontend.dart';


class PopoverComponent {
  static void showPopover(Element target, String message,
      {String title = 'Atenção',
      Duration? timeout = const Duration(seconds: 3)}) async {
//     var template = '''
//    <div class="popover-arrow" style="position: absolute; left: 0px; transform: translate(129px, 0px);"></div>
//    <h3 class="popover-header">${title}</h3>
//    <div class="popover-body">${message}</div>
// ''';

    final id = 'popover441630';

    var olds = document.querySelectorAll('#$id');
    if (olds.isNotEmpty) {
      olds.forEach((e) {
        e.remove();
      });
    }

    var rootPopover = DivElement();
    rootPopover.attributes['id'] = id;
    rootPopover.classes.addAll(['popover', 'bs-popover-auto', 'fade', 'show']);
    rootPopover.attributes['data-popper-placement'] = 'top';
    rootPopover.style.position = 'absolute';
    rootPopover.style.margin = '0px';

    var popoverArrow = DivElement();
    popoverArrow.classes.add('popover-arrow');
    rootPopover.append(popoverArrow);
    popoverArrow.style.position = 'absolute';
    popoverArrow.style.left = '0px';

    var popoverHeader = HeadingElement.h3();
    popoverHeader.classes.add('popover-header');
    popoverHeader.text = title;
    rootPopover.append(popoverHeader);

    var popoverBody = DivElement();
    popoverBody.classes.add('popover-body');
    popoverBody.text = message;
    rootPopover.append(popoverBody);

    // ignore: unsafe_html
    // rootPopover.setInnerHtml(template,
    //     treeSanitizer: NodeTreeSanitizer.trusted);

    document.body!.append(rootPopover);

    document.body!.classes.addAll(['swal2-toast-shown', 'swal2-shown']);

    var x = 0, y = 0, arrowX = 0, arrowY = 0, targetX, targetY;

    var calcPosition = () {
      final targetPosition = target.getBoundingClientRect();
      final popoverPosition = rootPopover.getBoundingClientRect();
      targetX = (targetPosition.left + window.scrollX).round();
      targetY = (targetPosition.top + window.scrollY).round();

      x = (targetX - targetPosition.width / 2).round();
      arrowX = ((popoverPosition.width / 2) - 8).round();

      if (x < 0) {
        x = 0;
        arrowX = targetX;
      }

      var rotate = '';

      if (targetY < popoverPosition.height + 100) {
        //print('targetPosition y: $y');
        y = (targetY + targetPosition.height).round();
        y = y + 10;
        arrowY = (-popoverPosition.height).round() - 8;
        rotate = ' rotate(180deg)';
      } else {
        y = (targetY - popoverPosition.height).round();
        y = y - 10;
        arrowY = 0;
      }

      popoverArrow.style.transform =
          'translate(${arrowX}px, ${arrowY}px)$rotate';
      rootPopover.style.transform = 'translate(${x}px, ${y}px)';
    };
    calcPosition();

    StreamSubscription? ssoc, ssos, ssokd;

    var close = () {
      target.attributes.remove('data-popover');
      document.body!.classes.removeAll(['swal2-toast-shown', 'swal2-shown']);
      rootPopover.remove();
      ssoc?.cancel();
      ssos?.cancel();
      ssokd?.cancel();
    };

    rootPopover.onClick.listen((event) {
      event.stopPropagation();
      close();
    });
    if (timeout != null) {
      //Future.delayed(timeout, () => close(););
    }

    var parrentScroll = FrontUtils.findOverflowParent(target);

    Future.delayed(Duration(milliseconds: 250), () {
      ssoc = document.onClick.listen((event) {
        var te = (event.target as Element);
        if (te != rootPopover) {
          close();
        }
      });

      if (parrentScroll != null) {
        //  parrentScroll.addEventListener('scroll', (event)  {
        //   calcPosition();
        // });
        ssos = parrentScroll.onScroll.listen((event) {
          calcPosition();
        });
        // monitora se um elemnto não esta mais visivel
        // var obr = IntersectionObserver((entries, ob) {
        //   if (entries[0].intersectionRatio <= 0) {
        //     close();
        //     ob.unobserve(target);
        //   }
        // });
        // obr.observe(target);
      }

      ssokd = document.onKeyDown.listen((event) {
        // print('onKeyDown ${event.key} | ${event.code} | ${event.keyCode}');
        if (event.keyCode == 27) {
          close();
        }
      });
    });

    if (target.attributes['data-popover'] == null) {
      target.attributes['data-popover'] = 'true';
    }
  }
}
