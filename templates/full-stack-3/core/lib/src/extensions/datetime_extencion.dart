import 'package:intl/intl.dart';
import 'package:sibem_core/core.dart';

extension DateTimeExtension on DateTime {
  String get asDateOnlyString {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}

extension DateTimeIsBeforeExtension on DateTime {
  bool isDateTimeBefore(DateTime dateTime2) {
    DateTime dateTime1 = this;
    return CoreUtils.isDateTimeBefore(dateTime1, dateTime2);
  }

  bool isDateBefore(DateTime dateTime2) {
    DateTime dateTime1 = this;
    return CoreUtils.isDateBefore(dateTime1, dateTime2);
  }

  bool isDateEqual(DateTime dateTime2) {
    DateTime dateTime1 = this;
    return CoreUtils.dateAreEqual(dateTime1, dateTime2);
  }
}
