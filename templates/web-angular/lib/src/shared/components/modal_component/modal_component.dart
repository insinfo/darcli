import 'dart:html';

import 'package:ngdart/angular.dart';

/// example of use
/// size => modal-xs | modal-sm | default | large | xtra-large | modal-full
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
  encapsulation: ViewEncapsulation.none,
)
class CustomModalComponent implements OnInit, OnDestroy {
  //@Input()
  //String id;

  late Element rootElement;

  @Input()
  bool enableHeader = true;

  /// add `modal-body` to div
  @Input()
  bool enableModalBodyClass = true;

  @Input()
  bool enableBackdrop = true;

  @Input()
  bool enableRoundedCorners = true;

  @Input()
  bool closeOnBackdropClick = true;

  @Input()
  bool enableCloseBtn = true;

  @Input()
  bool showError = false;

  @Input()
  String errorMessage = '';

  void showErrorMessage([String? errorMsg]) {
    showError = true;
    if (errorMsg != null) {
      errorMessage = errorMsg;
    }
  }

  void hideErrorMessage() {
    showError = false;
  }

  @Input()
  bool verticalCenter = false;

  @Input()
  bool dialogScrollable = false;

  @Input()
  String size = 'default'; // modal-xs modal-sm default xtra-large modal-full

  @Input()
  String headerColor =
      'default'; //Primary | Danger |Success |Warning |Info |Default | bg-indigo

  CustomModalComponent(this.rootElement);

  @Input('title-text')
  String titleText = '';

  @Input('start-open')
  bool startOpen = false;

  @Input()
  bool enableShadow = false;

  @ViewChild('modalRootElement')
  DivElement? modalRootElement;

  @ViewChild('modalContent')
  DivElement? modalContent;

  @ViewChild('modalHeader')
  DivElement? modalHeader;

  @ViewChild('modalBody')
  DivElement? modalBody;

  @override
  void ngOnInit() {
    // ensure id attribute exists
    //if (id == null) {
    //  print('modal must have an id');
    //  return;
    //}
    // move o elemento para o final da página (logo antes de </body>) para que possa ser exibido acima de tudo
    // move element to bottom of page (just before </body>) so it can be displayed above everything else
    document.body?.append(rootElement);

    // close modal on background click
    rootElement.addEventListener('mousedown', (el) {
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
    rootElement.remove();
  }

  void stopPropagation(event) {
    event.stopPropagation();
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
    backdropDiv.style.zIndex = '1055';
    backdropDiv.style.opacity = '.5';
    //backdropDiv.addEventListener('click', (event) {
    //   close();
    //});
    if (enableBackdrop) {
      // document.body?.append(backdropDiv);

      document.body?.insertBefore(backdropDiv, rootElement);
    }

    // element.style.display = 'block';
    modalRootElement?.style.display = 'block';
    modalRootElement?.attributes['data-status'] = 'open';
    document.body?.classes.add('modal-open');
  }

  bool get isOpen => modalRootElement?.style.display == 'block';

  // close modal
  void close() {
    backdropDiv.remove();
    //element.style.display = 'none';
    modalRootElement?.style.display = 'none';
    modalRootElement?.attributes['data-status'] = 'close';
    document.body?.classes.remove('modal-open');
    showError = false;
  }
}
