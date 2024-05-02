/// Provides constants used to control terity of [prettyDuration] and
/// [printDuration].
class DurationTersity {
  /// Unique id used to identify and compare [DurationTersity]
  final int _id;
  final int mod;
  final String name;

  const DurationTersity._(this._id, this.mod, this.name);

  @override
  String toString() => name;

  /// Skip all time units below week
  static const week = DurationTersity._(7, 1, 'week');

  /// Skip all time units below day
  static const day = DurationTersity._(6, 7, 'day');

  /// Skip all time units below hour
  static const hour = DurationTersity._(5, 24, 'hour');

  /// Skip all time units below minute
  static const minute = DurationTersity._(4, 60, 'minute');

  /// Skip all time units below second
  static const second = DurationTersity._(3, 60, 'second');

  /// Skip all time units below millisecond
  static const millisecond = DurationTersity._(2, 1000, 'millisecond');

  /// Skip all time units below microsecond
  static const microsecond = DurationTersity._(1, 1000, 'microsecond');

  static const list = [
    week,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond
  ];

  bool operator >(DurationTersity other) => _id > other._id;

  bool operator <(DurationTersity other) => _id < other._id;

  bool operator >=(DurationTersity other) => _id >= other._id;

  bool operator <=(DurationTersity other) => _id <= other._id;
}

extension DurExt on Duration {
  int get inWeeks => inDays ~/ 7;

  int inUnit(DurationTersity unit) {
    switch (unit) {
      case DurationTersity.week:
        return inWeeks;
      case DurationTersity.day:
        return inDays;
      case DurationTersity.hour:
        return inHours;
      case DurationTersity.minute:
        return inMinutes;
      case DurationTersity.second:
        return inSeconds;
      case DurationTersity.millisecond:
        return inMilliseconds;
      case DurationTersity.microsecond:
        return inMicroseconds;
      default:
        throw UnsupportedError('support duration unit provided: $unit');
    }
  }
}

/// Interface to print time units for different locale
abstract class DurationLocale {
  const DurationLocale();

  String get defaultSpacer => ' ';

  /// Print [amount] years for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String year(int amount, [bool abbreviated = true]);

  /// Print [amount] month for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String month(int amount, [bool abbreviated = true]);

  /// Print [amount] week for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String week(int amount, [bool abbreviated = true]);

  /// Print [amount] day for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String day(int amount, [bool abbreviated = true]);

  /// Print [amount] hour for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String hour(int amount, [bool abbreviated = true]);

  /// Print [amount] minute for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String minute(int amount, [bool abbreviated = true]);

  /// Print [amount] second for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String second(int amount, [bool abbreviated = true]);

  /// Print [amount] millisecond for the corresponding locale. The unit is abbreviated
  /// if [abbreviated] is set to true.
  String millisecond(int amount, [bool abbreviated = true]);

  /// Print [amount] microseconds for the corresponding locale. The unit is
  /// abbreviated if [abbreviated] is set to true.
  String microseconds(int amount, [bool abbreviated = true]);

  String inUnit(DurationTersity unit, int amount, [bool abbreviated = true]) {
    switch (unit) {
      case DurationTersity.week:
        return week(amount, abbreviated);
      case DurationTersity.day:
        return day(amount, abbreviated);
      case DurationTersity.hour:
        return hour(amount, abbreviated);
      case DurationTersity.minute:
        return minute(amount, abbreviated);
      case DurationTersity.second:
        return second(amount, abbreviated);
      case DurationTersity.millisecond:
        return millisecond(amount, abbreviated);
      case DurationTersity.microsecond:
        return microseconds(amount, abbreviated);
      default:
        throw UnsupportedError('unsupported duration unit: $unit');
    }
  }

  static DurationLocale? fromLanguageCode(String languageCode) {
    return _locales[languageCode];
  }
}

/// [DurationLocale] for English language
const EnglishDurationLocale englishLocale = EnglishDurationLocale();

/// [DurationLocale] for Portuguese language
const PortugueseBRDurationLanguage portugueseBrLocale =
    PortugueseBRDurationLanguage();

const _locales = <String, DurationLocale>{
  'en': englishLocale,
  'pt': portugueseBrLocale
};

class EnglishDurationLocale extends DurationLocale {
  const EnglishDurationLocale();

  @override
  String year(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'y';
    } else {
      return 'year' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String month(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'mon';
    } else {
      return 'month' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String week(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'w';
    } else {
      return 'week' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String day(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'd';
    } else {
      return 'day' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String hour(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'h';
    } else {
      return 'hour' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String minute(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'min';
    } else {
      return 'minute' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String second(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 's';
    } else {
      return 'second' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String millisecond(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'ms';
    } else {
      return 'millisecond' + (amount.abs() != 1 ? 's' : '');
    }
  }

  @override
  String microseconds(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'us';
    } else {
      return 'microsecond' + (amount.abs() != 1 ? 's' : '');
    }
  }
}

class PortugueseBRDurationLanguage extends DurationLocale {
  const PortugueseBRDurationLanguage();

  @override
  String year(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'a';
    } else {
      return 'ano' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String month(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'mês';
    } else {
      return 'mês' + (amount > 1 ? 'es' : '');
    }
  }

  @override
  String week(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'sem';
    } else {
      return 'semana' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String day(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'd';
    } else {
      return 'día' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String hour(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'h';
    } else {
      return 'hora' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String minute(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'm';
    } else {
      return 'minuto' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String second(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 's';
    } else {
      return 'segundo' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String millisecond(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'ms';
    } else {
      return 'milisegundo' + (amount > 1 ? 's' : '');
    }
  }

  @override
  String microseconds(int amount, [bool abbreviated = true]) {
    if (abbreviated) {
      return 'us';
    } else {
      return 'microsegundo' + (amount > 1 ? 's' : '');
    }
  }
}
