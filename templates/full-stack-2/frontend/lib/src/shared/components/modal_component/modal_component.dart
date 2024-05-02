import 'dart:html';

import 'package:ngdart/angular.dart';

/// example of use
/// size => small | default | large | extra | large
/// headerColor => primary | danger | success | warning | info | default
/// <custom-modal [start-open]="true" title-text="example title" size="large" headerColor="primary">
///   <h1>example</h1>
/// </custom-modal>
///
@Component(
  selector: 'custom-modal',
  templateUrl: 'modal_component.html',
  styleUrls: ['modal_component.css'],
  directives: [
    coreDirectives,
  ],
  encapsulation: ViewEncapsulation.None,
)
class CustomModalComponent implements OnInit, OnDestroy {
  //@Input()
  //String id;
  late Element element;

  @Input()
  bool enableHeader = true;

  @Input()
  bool enableBackdrop = true;

  @Input()
  bool enableRoundedCorners = true;

  @Input()
  bool closeOnBackdropClick = true;

  @Input()
  String size = 'modal-default'; // Small Default Large Extra large

  @Input()
  String headerColor =
      'default'; //Primary | Danger |Success |Warning |Info |Default

  //ModalComponent(ElementRef ref) {
  CustomModalComponent(this.element) {
    //element = ref.nativeElement;
  }

  @Input('title-text')
  String titleText = '';

  @Input('start-open')
  bool startOpen = false;

  @Input()
  bool enableShadow = false;

  /*String get sizeClass {
    if (size == 'small') {
      return 'modal-sm';
    } else if (size == 'large') {
      return 'modal-lg';
    } else if (size == 'xtra-large') {
      return 'modal-xl';
    } else {
      return 'modal-default';
    }
  }

  String get bgHeaderClass {
    var hColor = headerColor?.toLowerCase();
    if (hColor == 'primary') {
      return 'custom-modal-header-primary';
    } else if (hColor == 'success') {
      return 'custom-modal-header-success';
    } else if (hColor == 'info') {
      return 'custom-modal-header-info';
    } else if (hColor == 'dange') {
      return 'custom-modal-header-dange';
    } else {
      return 'custom-modal-header-default';
    }
  }*/

  @override
  void ngOnInit() {
    // ensure id attribute exists
    //if (id == null) {
    //  print('modal must have an id');
    //  return;
    //}
    // move o elemento para o final da página (logo antes de </body>) para que possa ser exibido acima de tudo
    // move element to bottom of page (just before </body>) so it can be displayed above everything else
    document.body?.append(element);

    // close modal on background click
    element.addEventListener('mousedown', (el) {
      if (closeOnBackdropClick) {
        //var target = el.target as HtmlElement;
        close();
      }
    });

    if (startOpen == true) {
      open();
    }

    // add self (this modal instance) to the modal service so it's accessible from controllers
    //this.modalService.add(this);
  }

  // remove self from modal service when component is destroyed
  @override
  void ngOnDestroy() {
    element.remove();
  }

  void stopPropagation(event) {
    event.stopPropagation();
    //print('mouseEvent $event');
  }

  DivElement backdropDiv = DivElement();

  // open modal
  void open() {
    backdropDiv = DivElement();
    backdropDiv.style.position = 'fixed';
    backdropDiv.style.top = '0';
    backdropDiv.style.left = '0';
    backdropDiv.style.width = '100vw';
    backdropDiv.style.height = '100vh';
    backdropDiv.style.backgroundColor = '#000';
    backdropDiv.style.zIndex = '900';
    backdropDiv.style.opacity = '.5';
    //backdropDiv.addEventListener('click', (event) {
    //   close();
    //});
    if (enableBackdrop) {
      document.body?.append(backdropDiv);
    }

    element.style.display = 'block';
    document.body?.classes.add('custom-modal-open');
  }

  // close modal
  void close() {
    backdropDiv.remove();
    element.style.display = 'none';
    document.body?.classes.remove('custom-modal-open');
  }
}
