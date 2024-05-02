import 'package:intl/intl.dart';

class CoreUtils {
  static dynamic customJsonEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  /// 28/12/2021 to => 2021-12-28
  static String? stringBrasilDateToIsoDate(String? strBDate) {
    if (strBDate == null) {
      return strBDate;
    }
    try {
      final date = DateFormat('dd/MM/yyyy').parse(strBDate.trim());
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return null;
    }
  }

  static bool isNotNullOrEmpty(String? val) {
    return val != null && val != 'null' && val != '';
  }

  static String? isoDateToBrasilDateString(String? strBDate) {
    if (strBDate == null) {
      return strBDate;
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parse(strBDate.trim());
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return null;
    }
  }

  static String dateToBrasilDateString(DateTime? date) {
    if (date == null) {
      return '';
    }
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }
}
