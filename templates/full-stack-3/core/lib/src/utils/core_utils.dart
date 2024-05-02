class CoreUtils {
  static bool dateTimeAreEqual(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day &&
        dateTime1.hour == dateTime2.hour &&
        dateTime1.minute == dateTime2.minute &&
        dateTime1.second == dateTime2.second &&
        dateTime1.millisecond == dateTime2.millisecond &&
        dateTime1.microsecond == dateTime2.microsecond;
  }

  static bool dateAreEqual(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  /// function to verify if one DateTime is before another
  /// comparar dois objetos DateTime sem considerar fusos horários,
  /// comparando diretamente seus componentes individuais (ano, mês, dia, hora, minuto, segundo, milissegundo)
  static bool isDateTimeBefore(DateTime dateTime1, DateTime dateTime2) {
    if (dateTime1.year < dateTime2.year) {
      return true;
    } else if (dateTime1.year == dateTime2.year) {
      if (dateTime1.month < dateTime2.month) {
        return true;
      } else if (dateTime1.month == dateTime2.month) {
        if (dateTime1.day < dateTime2.day) {
          return true;
        } else if (dateTime1.day == dateTime2.day) {
          if (dateTime1.hour < dateTime2.hour) {
            return true;
          } else if (dateTime1.hour == dateTime2.hour) {
            if (dateTime1.minute < dateTime2.minute) {
              return true;
            } else if (dateTime1.minute == dateTime2.minute) {
              if (dateTime1.second < dateTime2.second) {
                return true;
              } else if (dateTime1.second == dateTime2.second) {
                if (dateTime1.millisecond < dateTime2.millisecond) {
                  return true;
                } else if (dateTime1.millisecond == dateTime2.millisecond) {
                  if (dateTime1.microsecond < dateTime2.microsecond) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
    return false;
  }

  static bool isDateBefore(DateTime date1, DateTime date2) {
    // Compare years
    if (date1.year < date2.year) {
      return true;
    } else if (date1.year > date2.year) {
      return false;
    }

    // If years are equal, compare months
    if (date1.month < date2.month) {
      return true;
    } else if (date1.month > date2.month) {
      return false;
    }

    // If years and months are equal, compare days
    return date1.day < date2.day;
  }

  static dynamic customJsonEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  static bool isNotNullOrEmpty(value) {
    return value != null && value != 'null' && value != '';
  }

  static bool isNotNullOrEmptyAndContain(Map<String, dynamic> json, key) {
    return json.containsKey(key) && isNotNullOrEmpty(json[key]);
  }
}
