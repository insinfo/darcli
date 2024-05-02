import 'dart:async';
import 'dart:html';

import 'package:sibem_frontend/sibem_frontend.dart';

class PopoverComponent {
  static String css = ''' 
<style>
.popover {
  --popover-zindex: 1070;
  --popover-max-width: 276px;
  --popover-font-size: var(--body-font-size);
  --popover-bg: var(--white);
  --popover-border-width: var(--border-width);
  --popover-border-color: var(--border-color-translucent);
  --popover-border-radius: var(--border-radius);
  --popover-inner-border-radius: calc(var(--border-radius) - (var(--border-width)));
  --popover-box-shadow: var(--box-shadow);
  --popover-header-padding-x: var(--spacer);
  --popover-header-padding-y: 0.75rem;
  --popover-header-font-size: var(--body-font-size);
  --popover-header-color: var(--body-color);
  --popover-header-bg: var(--gray-100);
  --popover-body-padding-x: var(--spacer);
  --popover-body-padding-y: calc(var(--spacer) * 0.75);
  --popover-body-color: var(--body-color);
  --popover-arrow-width: 1rem;
  --popover-arrow-height: 0.5rem;
  --popover-arrow-border: var(--popover-border-color);
  z-index: var(--popover-zindex);
  display: block;
  max-width: var(--popover-max-width);
  font-family: var(--font-sans-serif);
  font-style: normal;
  font-weight: 400;
  line-height: 1.5715;
  text-align: left;
  text-align: start;
  text-decoration: none;
  text-shadow: none;
  text-transform: none;
  letter-spacing: normal;
  word-break: normal;
  white-space: normal;
  word-spacing: normal;
  line-break: auto;
  font-size: var(--popover-font-size);
  word-wrap: break-word;
  background-color: var(--popover-bg);
  background-clip: padding-box;
  border: var(--popover-border-width) solid var(--popover-border-color);
  border-radius: var(--popover-border-radius);
  box-shadow: var(--popover-box-shadow);
}
.popover--top {
  margin-top: -16px;
}
.popover--top::before, .popover--top::after {
  content: "";
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -8px;
  border: 8px solid transparent;
  border-top-color: white;
}
.popover--top::before {
  margin-top: 1px;
  border-top-color: rgba(0, 0, 0, 0.125);
}
.popover--right {
  margin-left: 16px;
}
.popover--right::before, .popover--right::after {
  content: "";
  position: absolute;
  top: 50%;
  right: 100%;
  margin-top: -8px;
  border: 8px solid transparent;
  border-right-color: white;
}
.popover--right::before {
  margin-right: 1px;
  border-right-color: rgba(0, 0, 0, 0.125);
}
.popover--bottom {
  margin-top: 16px;
}
.popover--bottom::before, .popover--bottom::after {
  content: "";
  position: absolute;
  bottom: 100%;
  left: 50%;
  margin-left: -8px;
  border: 8px solid transparent;
  border-bottom-color: white;
}
.popover--bottom::before {
  margin-bottom: 1px;
  border-bottom-color: rgba(0, 0, 0, 0.125);
}
.popover--left {
  margin-left: -16px;
}
.popover--left::before, .popover--left::after {
  content: "";
  position: absolute;
  top: 50%;
  left: 100%;
  margin-top: -8px;
  border: 8px solid transparent;
  border-left-color: white;
}
.popover--left::before {
  margin-left: 1px;
  border-left-color: rgba(0, 0, 0, 0.125);
}
</style>
  ''';

  /// [target] target trigger element
  static void showPopover(Element trigger, String message,
      {String initPosition = 'bottom',
      String? title = 'Atenção',
      Duration? timeout = const Duration(seconds: 3)}) async {
    var orderedPositions = ['top', 'right', 'bottom', 'left'];

    final id = 'popover441630';

    final olds = document.querySelectorAll('#$id');
    if (olds.isNotEmpty) {
      for (var e in olds) {
        e.remove();
      }
    }
    final className = 'popover';
    final popover = DivElement();
    popover.attributes['id'] = id;

    popover.classes.add(className);
    popover.style.position = 'fixed';
    // popover.style.zIndex = '1070';

    popover.setInnerHtml(css, treeSanitizer: NodeTreeSanitizer.trusted);
    document.body!.append(popover);

    if (title != null) {
      final popoverHeader = HeadingElement.h3();
      popoverHeader.classes.add('popover-header');
      popoverHeader.text = title;
      popover.append(popoverHeader);
    }

    final popoverBody = DivElement();
    popoverBody.classes.add('popover-body');
    popoverBody.setInnerHtml(message, treeSanitizer: NodeTreeSanitizer.trusted);
    popover.append(popoverBody);

    StreamSubscription? streamSubscriptionOnClick,
        streamSubscriptionOnScroll,
        streamSubscriptionOnResize,
        streamSubscriptionOnKeyDown;

    void destroy() {
      trigger.attributes.remove('data-popover');
      popover.remove();
      streamSubscriptionOnClick?.cancel();
      streamSubscriptionOnScroll?.cancel();
      streamSubscriptionOnKeyDown?.cancel();
      streamSubscriptionOnResize?.cancel();
    }

    void show() {
      final triggerRect = trigger.getBoundingClientRect();
      final triggerTop = triggerRect.top;
      final triggerLeft = triggerRect.left;
      final triggerHeight = trigger.offsetHeight;
      final triggerWidth = trigger.offsetWidth;

      final popoverHeight = popover.offsetHeight;
      final popoverWidth = popover.offsetWidth;

      final positionIndex = orderedPositions.indexOf(initPosition);

      final positions = {
        'top': {
          'name': 'top',
          'top': triggerTop - popoverHeight,
          'left': triggerLeft - ((popoverWidth - triggerWidth) / 2)
        },
        'right': {
          'name': 'right',
          'top': triggerTop - ((popoverHeight - triggerHeight) / 2),
          'left': triggerLeft + triggerWidth
        },
        'bottom': {
          'name': 'bottom',
          'top': triggerTop + triggerHeight,
          'left': triggerLeft - ((popoverWidth - triggerWidth) / 2)
        },
        'left': {
          'name': 'left',
          'top': triggerTop - ((popoverHeight - triggerHeight) / 2),
          'left': triggerLeft - popoverWidth
        }
      };

      final positionsList = orderedPositions
          .skip(positionIndex)
          .followedBy(orderedPositions.take(positionIndex))
          .map((pos) => positions[pos])
          .toList();

      Map<String, dynamic>? position;
      for (final pos in positionsList) {
        final x = pos!['top'];
        final y = pos['left'];
        popover.style.top = "${x}px";
        popover.style.left = "${y}px";
        if (_isInViewport(popover)) {
          position = pos;
          break;
        }
      }

      for (final pos in orderedPositions) {
        popover.classes.remove('$className--$pos');
      }

      if (position != null) {
        popover.classes.add('$className--${position['name']}');
      } else {
        // popover.style.top = '${positions['bottom']!['top']}px';
        // popover.style.left = '${positions['bottom']!['left']}px';
        // popover.classes.add('$className--bottom');
        destroy();
      }
    }

    show();

    void handleWindowEvent(Event evt) {
      if (_isVisible(popover)) {
        show();
      }
    }

    void handleDocumentEvent(MouseEvent evt) {
      if (_isVisible(popover) &&
          evt.target != trigger &&
          evt.target != popover) {
        destroy();
      }
    }

    // popover.onClick.listen((event) {
    //   event.stopPropagation();
    //   destroy();
    // });

    final parrentScroll = FrontUtils.findOverflowParent(trigger);

    Future.delayed(Duration(milliseconds: 250), () {
      streamSubscriptionOnClick = document.onClick.listen(handleDocumentEvent);

      if (parrentScroll != null) {
        streamSubscriptionOnScroll =
            parrentScroll.onScroll.listen(handleWindowEvent);
      }

      streamSubscriptionOnResize = window.onResize.listen(handleWindowEvent);
      streamSubscriptionOnKeyDown = document.onKeyDown.listen((event) {
        // KeyCode.ESC =27
        if (event.keyCode == KeyCode.ESC) {
          destroy();
        }
      });
    });

    if (trigger.attributes['data-popover'] == null) {
      trigger.attributes['data-popover'] = 'true';
    }
  }

  static bool _isVisible(Element element) {
    return document.body!.contains(element);
  }

  static bool _isInViewport(Element element) {
    final rect = element.getBoundingClientRect();
    final html = document.documentElement;
    if (html == null) {
      return false;
    }
    final windowHeight = window.innerHeight ?? html.clientHeight;
    final windowWidth = window.innerWidth ?? html.clientWidth;
    return rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= windowHeight &&
        rect.right <= windowWidth;
  }

  // ignore: unused_element
  static bool _isInViewport2(Element element) {
    final rect = element.getBoundingClientRect();
    // Calculate viewport dimensions with null checks
    final viewportTop = window.scrollY;
    final viewportLeft = window.scrollX;
    final viewportBottom = viewportTop + (window.innerHeight ?? 0);
    final viewportRight = viewportLeft + (window.innerWidth ?? 0);
    // Check element intersection with viewport
    return rect.top >= viewportTop &&
        rect.left >= viewportLeft &&
        rect.bottom <= viewportBottom &&
        rect.right <= viewportRight;
  }
}
