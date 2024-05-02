

import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime{
  String get asDateOnlyString{
    return DateFormat('yyyy-MM-dd').format(this);
  }
}