import 'package:intl/intl.dart';

import '../utils/utils.dart';

extension DateTimeExtension on DateTime {
  String get asDateOnlyString {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}

extension DateTimeIsBeforeExtension on DateTime {
  bool isDateTimeBefore(DateTime dateTime2) {
    DateTime dateTime1 = this;
    return FrontUtils.isDateTimeBefore(dateTime1, dateTime2);
  }

  bool isDateBefore(DateTime dateTime2) {
    DateTime dateTime1 = this;
    return FrontUtils.isDateBefore(dateTime1, dateTime2);
  }

  bool isDateEqual(DateTime dateTime2) {
    DateTime dateTime1 = this;
    return FrontUtils.dateAreEqual(dateTime1, dateTime2);
  }
}
