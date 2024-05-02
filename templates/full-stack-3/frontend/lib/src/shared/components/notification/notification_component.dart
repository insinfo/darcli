import 'package:ngdart/angular.dart';

import 'notification_component_service.dart';

/// Top navigation component.
@Component(
  selector: 'notification-outlet',
  templateUrl: 'notification.html',
  styleUrls: ['notification.css'],
  /* styles: [
      ''' 
        @keyframes toast-fade-in {
        from {opacity: 0;}
        to {opacity: 1;}
        }
        @keyframes toast-fade-out {
        from {opacity: 1;}
        to {opacity: 0;}
        }
        @keyframes timer {
        from {width: 0%;}
        to {width: 100%;}
        }
   '''
    ],*/
  directives: [
    coreDirectives,
  ],
  exports: [
    NotificationCompColor,
  ],
)
class NotificationComponent {
  @Input()
  NotificationComponentService? service;

  /// Produce a CSS style for the `top` property.
  String styleTop(int i) {
    return '${i * 20}px';
  }

  void closeToast(Toast toast) {
    service?.toasts.remove(toast);
  }
}
