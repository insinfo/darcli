import 'dart:async';
//import 'package:ngdart/angular.dart';

enum NotificationCompColor {
  primary,
  secondary,
  success,
  info,
  warning,
  danger,
  pink,
  teal,
  none,
}

extension NotificationCompColorExtension on NotificationCompColor {
  String asString() {
    switch (this) {
      case NotificationCompColor.primary:
        return 'primary';
      case NotificationCompColor.secondary:
        return 'secondary';
      case NotificationCompColor.success:
        return 'success';
      case NotificationCompColor.info:
        return 'info';
      case NotificationCompColor.warning:
        return 'warning';
      case NotificationCompColor.danger:
        return 'danger';
      case NotificationCompColor.pink:
        return 'pink';
      case NotificationCompColor.teal:
        return 'teal';
      case NotificationCompColor.none:
        return 'none';
      default:
        // return 'unknown';
        throw Exception('NotificationCompColor unknown');
    }
  }
}

NotificationCompColor _stringAsNotificationCompColor(String val) {
  switch (val) {
    case 'primary':
      return NotificationCompColor.primary;
    case 'secondary':
      return NotificationCompColor.secondary;
    case 'success':
      return NotificationCompColor.success;
    case 'info':
      return NotificationCompColor.info;
    case 'warning':
      return NotificationCompColor.warning;
    case 'danger':
      return NotificationCompColor.danger;
    case 'pink':
      return NotificationCompColor.pink;
    case 'teal':
      return NotificationCompColor.teal;
    case 'none':
      return NotificationCompColor.none;
    default:
      // return 'unknown';
      throw Exception('NotificationCompColor unknown');
  }
}

/// A service that manages toasts that should be displayed.
//@Injectable()
class NotificationComponentService {
  /// A list of toasts that should be displayed.
  List<Toast> toasts = [];

  final StreamController<Toast> _onNotifyStreamController;
  Stream<Toast> get onNotify => _onNotifyStreamController.stream;

  /// Constructor.
  NotificationComponentService()
      : _onNotifyStreamController = StreamController<Toast>.broadcast();

  void notify(
    String message, {
    NotificationCompColor type = NotificationCompColor.teal,
    String? title = 'Notificação',
    String? icon,
    int durationSeconds = 3,
  }) {
    final toast = Toast(
      type: type,
      title: title,
      message: message,
      icon: icon,
      durationSeconds: durationSeconds,
    );
    toasts.insert(0, toast);
    _onNotifyStreamController.add(toast);

    final milliseconds = ((1000 * toast.durationSeconds) + 300).round();
    // How to get size of each toast?
    Timer(Duration(milliseconds: milliseconds), () {
      toast.toBeDeleted = true;
      Timer(Duration(milliseconds: 300), () {
        toasts.remove(toast);
      });
    });
  }

  /// Display a toast.
  void add(NotificationCompColor type, String title, String message,
      {String? icon, int durationSeconds = 3}) {
    final toast = Toast(
      type: type,
      title: title,
      message: message,
      icon: icon,
      durationSeconds: durationSeconds,
    );
    toasts.insert(0, toast);
    final milliseconds = (1000 * toast.durationSeconds + 300).round();
    // How to get size of each toast?
    Timer(Duration(milliseconds: milliseconds), () {
      toast.toBeDeleted = true;
      Timer(Duration(milliseconds: 300), () {
        toasts.remove(toast);
      });
    });
  }
}

/// Data model for a toast, a.k.a. pop-up notification.
class Toast {
  /// The type (color) of this toast.
  NotificationCompColor type;

  /// The title to display (optional).
  String? title;

  /// The message to diplay.
  String message;

  /// The icon to display. If not specified, an icon is selected automatically
  /// based on `type`.
  String? icon;

  /// How long to display the toast before removing it.
  int durationSeconds;

  /// Duration as a CSS property string.
  String get cssDuration => '${durationSeconds}s';

  /// Set to true before the item is deleted. This allows time to fade the
  /// item out.
  bool toBeDeleted = false;
  /// data de criação
  late DateTime created;

  String get cssAnimation => toBeDeleted == true
      ? 'toast-fade-out 0.3s ease-out'
      : 'toast-fade-in 0.3s ease-in';

  /// Constructor
  Toast(
      {this.type = NotificationCompColor.info,
      this.title,
      required this.message,
      this.icon,
      this.durationSeconds = 3}) {
    created = DateTime.now();
    if (icon == null) {
      if (type == NotificationCompColor.success) {
        icon = 'check';
      } else if (type == NotificationCompColor.info) {
        icon = 'info';
      } else if (type == NotificationCompColor.warning) {
        icon = 'exclamation';
      } else if (type == NotificationCompColor.danger) {
        icon = 'times';
      } else {
        icon = 'bullhorn';
      }
    }
  }

  factory Toast.fromMap(Map<String, dynamic> map) {
    final t = Toast(
      message: map['message'],
      icon: map['icon'],
      title: map['title'],
      durationSeconds: map['durationSeconds'],
    );
    t.type = _stringAsNotificationCompColor(map['type']);
    t.toBeDeleted = map['toBeDeleted'];
    if (map.containsKey('created')) {
      final dt = DateTime.tryParse(map['created']);
      if (dt != null) {
        t.created = dt;
      }
    }
    return t;
  }

  Map<String, dynamic> toMap() {
    final map = {
      'type': type.asString(),
      'title': title,
      'message': message,
      'icon': icon,
      'durationSeconds': durationSeconds,
      'toBeDeleted': toBeDeleted,
      'created': created.toIso8601String(),
    };
    return map;
  }

  String get bgColor {
    if (type == NotificationCompColor.primary) {
      return 'bg-primary';
    } else if (type == NotificationCompColor.secondary) {
      return 'bg-secondary';
    } else if (type == NotificationCompColor.success) {
      return 'bg-success';
    } else if (type == NotificationCompColor.info) {
      return 'bg-info';
    } else if (type == NotificationCompColor.warning) {
      return 'bg-warning';
    } else if (type == NotificationCompColor.danger) {
      return 'bg-danger';
    } else if (type == NotificationCompColor.primary) {
      return 'bg-primary';
    } else if (type == NotificationCompColor.pink) {
      return 'bg-pink';
    } else if (type == NotificationCompColor.teal) {
      return 'bg-teal';
    } else {
      return 'bg-white';
    }
  }
}
