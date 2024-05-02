/// A span of time, such as 27 days, 4 hours, 12 minutes, and 3 seconds.
///
/// A `TimeSpan` represents a difference from one point in time to another. The
/// TimeSpan may be "negative" if the difference is from a later time to an
/// earlier.
///
/// TimeSpans are context independent. For example, a TimeSpan of 2 days is
/// always 48 hours, even when it is added to a `DateTime` just when the
/// time zone is about to make a daylight-savings switch. (See [DateTime.add]).
///
/// Despite the same name, a `TimeSpan` object does not implement "TimeSpans"
/// as specified by ISO 8601. In particular, a TimeSpan object does not keep
/// track of the individually provided members (such as "days" or "hours"), but
/// only uses these arguments to compute the length of the corresponding time
/// interval.
///
/// To create a new `TimeSpan` object, use this class's single constructor
/// giving the appropriate arguments:
/// ```dart
/// const fastestMarathon = TimeSpan(hours: 2, minutes: 3, seconds: 2);
/// ```
/// The [TimeSpan] represents a single number of microseconds,
/// which is the sum of all the individual arguments to the constructor.
///
/// Properties can access that single number in different ways.
/// For example the [inMinutes] gives the number of whole minutes
/// in the total TimeSpan, which includes the minutes that were provided
/// as "hours" to the constructor, and can be larger than 59.
///
/// ```dart
/// const fastestMarathon = TimeSpan(hours: 2, minutes: 3, seconds: 2);
/// print(fastestMarathon.inDays); // 0
/// print(fastestMarathon.inHours); // 2
/// print(fastestMarathon.inMinutes); // 123
/// print(fastestMarathon.inSeconds); // 7382
/// print(fastestMarathon.inMilliseconds); // 7382000
/// ```
/// The TimeSpan can be negative, in which case
/// all the properties derived from the TimeSpan are also non-positive.
/// ```dart
/// const overDayAgo = TimeSpan(days: -1, hours: -10);
/// print(overDayAgo.inDays); // -1
/// print(overDayAgo.inHours); // -34
/// print(overDayAgo.inMinutes); // -2040
/// ```
/// Use one of the properties, such as [inDays],
/// to retrieve the integer value of the `TimeSpan` in the specified time unit.
/// Note that the returned value is rounded down.
/// For example,
/// ```dart
/// const aLongWeekend = TimeSpan(hours: 88);
/// print(aLongWeekend.inDays); // 3
/// ```
/// This class provides a collection of arithmetic
/// and comparison operators,
/// plus a set of constants useful for converting time units.
/// ```dart
/// const firstHalf = TimeSpan(minutes: 45); // 00:45:00.000000
/// const secondHalf = TimeSpan(minutes: 45); // 00:45:00.000000
/// const overTime = TimeSpan(minutes: 30); // 00:30:00.000000
/// final maxGameTime = firstHalf + secondHalf + overTime;
/// print(maxGameTime.inMinutes); // 120
///
/// // The TimeSpan of the firstHalf and secondHalf is the same, returns 0.
/// var result = firstHalf.compareTo(secondHalf);
/// print(result); // 0
///
/// // TimeSpan of overTime is shorter than firstHalf, returns < 0.
/// result = overTime.compareTo(firstHalf);
/// print(result); // < 0
///
/// // TimeSpan of secondHalf is longer than overTime, returns > 0.
/// result = secondHalf.compareTo(overTime);
/// print(result); // > 0
/// ```
///
/// **See also:**
/// * [DateTime] to represent a point in time.
/// * [Stopwatch] to measure time-spans.
class TimeSpan implements Comparable<TimeSpan> {
  /// get top int max value 9223372036854775807
  static const int intMaxValue = 9223372036854775807; //0x7fffffffffffffff;

  /// get top int min value -9223372036854775808
  static const int intMinValue = -9223372036854775808; //0x8000000000000000;

  static TimeSpan timeSpanFromDoubleTicks(double ticks) {
    if ((ticks > intMaxValue) || (ticks < intMinValue)) {
      throw Exception('Ticks OverflowException');
    }
    // if (ticks == maxValue) {
    //   int microseconds = maxValue ~/ 10;
    //   return TimeSpan(microseconds: microseconds);
    // }
    int microseconds = (ticks * 10000).toInt();
    return TimeSpan.fromMicroseconds(microseconds);
  }

  /// accepts C# TimeSpan [-]d.hh:mm:ss.ff
  static TimeSpan fromString(String str) {
    final regexp = RegExp(
        r'(?:(?<ne>-))?(?:(?:(?<dd>0*[0-9]+)[.])?(?:(?<HH>0*[2][0-3]|0*[1][0-9]|0*[0-9])[:]))?(?<mm>(?<=:)0*[0-5]?[0-9]|0*[5-9]?[0-9](?=[:]))(?:[:](?<ss>0*[0-5]?[0-9](?:[.][0-9]{0,7})?))?');

    final match = regexp.firstMatch(str);
    int days = int.parse((match?.namedGroup('dd')) ?? "0");
    int hours = int.parse((match?.namedGroup('HH')) ?? "0");
    int mins = int.parse((match?.namedGroup('mm')) ?? "0");
    int usecs =
        (double.parse((match?.namedGroup('ss')) ?? "0.0") * 1000000).round();
    bool negative = match?.namedGroup('ne') == "-";

    final duration =
        TimeSpan(days: days, hours: hours, minutes: mins, microseconds: usecs);

    return negative ? TimeSpan.zero - duration : duration;
  }

  /// The number of microseconds per millisecond.
  static const int microsecondsPerMillisecond = 1000;

  /// The number of milliseconds per second.
  static const int millisecondsPerSecond = 1000;

  /// The number of seconds per minute.
  ///
  /// Notice that some minutes of official clock time might
  /// differ in length because of leap seconds.
  /// The [TimeSpan] and [DateTime] classes ignore leap seconds
  /// and consider all minutes to have 60 seconds.
  static const int secondsPerMinute = 60;

  /// The number of minutes per hour.
  static const int minutesPerHour = 60;

  /// The number of hours per day.
  ///
  /// Notice that some days may differ in length because
  /// of time zone changes due to daylight saving.
  /// The [TimeSpan] class is time zone agnostic and
  /// considers all days to have 24 hours.
  static const int hoursPerDay = 24;

  /// The number of microseconds per second.
  static const int microsecondsPerSecond =
      microsecondsPerMillisecond * millisecondsPerSecond;

  /// The number of microseconds per minute.
  static const int microsecondsPerMinute =
      microsecondsPerSecond * secondsPerMinute;

  /// The number of microseconds per hour.
  static const int microsecondsPerHour = microsecondsPerMinute * minutesPerHour;

  /// The number of microseconds per day.
  static const int microsecondsPerDay = microsecondsPerHour * hoursPerDay;

  /// The number of milliseconds per minute.
  static const int millisecondsPerMinute =
      millisecondsPerSecond * secondsPerMinute;

  /// The number of milliseconds per hour.
  static const int millisecondsPerHour = millisecondsPerMinute * minutesPerHour;

  /// The number of milliseconds per day.
  static const int millisecondsPerDay = millisecondsPerHour * hoursPerDay;

  /// The number of seconds per hour.
  static const int secondsPerHour = secondsPerMinute * minutesPerHour;

  /// The number of seconds per day.
  static const int secondsPerDay = secondsPerHour * hoursPerDay;

  /// The number of minutes per day.
  static const int minutesPerDay = minutesPerHour * hoursPerDay;

  /// An empty TimeSpan, representing zero time.
  static const TimeSpan zero = TimeSpan(seconds: 0);

  /// The total microseconds of this [TimeSpan] object.
  final int internalTimeSpan;

  /// Creates a new [TimeSpan] object whose value
  /// is the sum of all individual parts.
  ///
  /// Individual parts can be larger than the number of those
  /// parts in the next larger unit.
  /// For example, [hours] can be greater than 23.
  /// If this happens, the value overflows into the next larger
  /// unit, so 26 [hours] is the same as 2 [hours] and
  /// one more [days].
  /// Likewise, values can be negative, in which case they
  /// underflow and subtract from the next larger unit.
  ///
  /// If the total number of microseconds cannot be represented
  /// as an integer value, the number of microseconds might be truncated
  /// and it might lose precision.
  ///
  /// All arguments are 0 by default.
  /// ```dart
  /// const TimeSpan = TimeSpan(days: 1, hours: 8, minutes: 56, seconds: 59,
  ///   milliseconds: 30, microseconds: 10);
  /// print(TimeSpan); // 32:56:59.030010
  /// ```
  const TimeSpan(
      {int days = 0,
      int hours = 0,
      int minutes = 0,
      int seconds = 0,
      int milliseconds = 0,
      int microseconds = 0})
      : this.fromMicroseconds(microseconds +
            microsecondsPerMillisecond * milliseconds +
            microsecondsPerSecond * seconds +
            microsecondsPerMinute * minutes +
            microsecondsPerHour * hours +
            microsecondsPerDay * days);

  // Fast path internal direct constructor to avoids the optional arguments and
  // [_microseconds] recomputation.
  const TimeSpan.fromMicroseconds(this.internalTimeSpan);

  /// Adds this TimeSpan and [other] and
  /// returns the sum as a new TimeSpan object.
  TimeSpan operator +(TimeSpan other) {
    return TimeSpan.fromMicroseconds(internalTimeSpan + other.internalTimeSpan);
  }

  /// Subtracts [other] from this TimeSpan and
  /// returns the difference as a new TimeSpan object.
  TimeSpan operator -(TimeSpan other) {
    return TimeSpan.fromMicroseconds(internalTimeSpan - other.internalTimeSpan);
  }

  /// Multiplies this TimeSpan by the given [factor] and returns the result
  /// as a new TimeSpan object.
  ///
  /// Note that when [factor] is a double, and the TimeSpan is greater than
  /// 53 bits, precision is lost because of double-precision arithmetic.
  TimeSpan operator *(num factor) {
    return TimeSpan.fromMicroseconds((internalTimeSpan * factor).round());
  }

  /// Divides this TimeSpan by the given [quotient] and returns the truncated
  /// result as a new TimeSpan object.
  ///
  /// Throws an [UnsupportedError] if [quotient] is `0`.
  TimeSpan operator ~/(int quotient) {
    // By doing the check here instead of relying on "~/" below we get the
    // exception even with dart2js.
    if (quotient == 0) throw UnsupportedError('IntegerDivisionByZeroException');
    return TimeSpan.fromMicroseconds(internalTimeSpan ~/ quotient);
  }

  /// Whether this [TimeSpan] is shorter than [other].
  bool operator <(TimeSpan other) =>
      this.internalTimeSpan < other.internalTimeSpan;

  /// Whether this [TimeSpan] is longer than [other].
  bool operator >(TimeSpan other) =>
      this.internalTimeSpan > other.internalTimeSpan;

  /// Whether this [TimeSpan] is shorter than or equal to [other].
  bool operator <=(TimeSpan other) =>
      this.internalTimeSpan <= other.internalTimeSpan;

  /// Whether this [TimeSpan] is longer than or equal to [other].
  bool operator >=(TimeSpan other) =>
      this.internalTimeSpan >= other.internalTimeSpan;

  /// The number of entire days spanned by this [TimeSpan].
  ///
  /// For example, a TimeSpan of four days and three hours
  /// has four entire days.
  /// ```dart
  /// const TimeSpan = TimeSpan(days: 4, hours: 3);
  /// print(TimeSpan.inDays); // 4
  /// ```
  int get inDays => internalTimeSpan ~/ TimeSpan.microsecondsPerDay;

  /// The number of entire hours spanned by this [TimeSpan].
  ///
  /// The returned value can be greater than 23.
  /// For example, a TimeSpan of four days and three hours
  /// has 99 entire hours.
  /// ```dart
  /// const TimeSpan = TimeSpan(days: 4, hours: 3);
  /// print(TimeSpan.inHours); // 99
  /// ```
  int get inHours => internalTimeSpan ~/ TimeSpan.microsecondsPerHour;

  /// The number of whole minutes spanned by this [TimeSpan].
  ///
  /// The returned value can be greater than 59.
  /// For example, a TimeSpan of three hours and 12 minutes
  /// has 192 minutes.
  /// ```dart
  /// const TimeSpan = TimeSpan(hours: 3, minutes: 12);
  /// print(TimeSpan.inMinutes); // 192
  /// ```
  int get inMinutes => internalTimeSpan ~/ TimeSpan.microsecondsPerMinute;

  /// The number of whole seconds spanned by this [TimeSpan].
  ///
  /// The returned value can be greater than 59.
  /// For example, a TimeSpan of three minutes and 12 seconds
  /// has 192 seconds.
  /// ```dart
  /// const TimeSpan = TimeSpan(minutes: 3, seconds: 12);
  /// print(TimeSpan.inSeconds); // 192
  /// ```
  int get inSeconds => internalTimeSpan ~/ TimeSpan.microsecondsPerSecond;

  /// The number of whole milliseconds spanned by this [TimeSpan].
  ///
  /// The returned value can be greater than 999.
  /// For example, a TimeSpan of three seconds and 125 milliseconds
  /// has 3125 milliseconds.
  /// ```dart
  /// const TimeSpan = TimeSpan(seconds: 3, milliseconds: 125);
  /// print(TimeSpan.inMilliseconds); // 3125
  /// ```
  int get inMilliseconds =>
      internalTimeSpan ~/ TimeSpan.microsecondsPerMillisecond;

  /// The number of whole microseconds spanned by this [TimeSpan].
  ///
  /// The returned value can be greater than 999999.
  /// For example, a TimeSpan of three seconds, 125 milliseconds and
  /// 369 microseconds has 3125369 microseconds.
  /// ```dart
  /// const TimeSpan = TimeSpan(seconds: 3, milliseconds: 125,
  ///     microseconds: 369);
  /// print(TimeSpan.inMicroseconds); // 3125369
  /// ```
  int get inMicroseconds => internalTimeSpan;

  /// Whether this [TimeSpan] has the same length as [other].
  ///
  /// TimeSpans have the same length if they have the same number
  /// of microseconds, as reported by [inMicroseconds].
  bool operator ==(Object other) =>
      other is TimeSpan && internalTimeSpan == other.inMicroseconds;

  int get hashCode => internalTimeSpan.hashCode;

  /// Compares this [TimeSpan] to [other], returning zero if the values are equal.
  ///
  /// Returns a negative integer if this [TimeSpan] is shorter than
  /// [other], or a positive integer if it is longer.
  ///
  /// A negative [TimeSpan] is always considered shorter than a positive one.
  ///
  /// It is always the case that `TimeSpan1.compareTo(TimeSpan2) < 0` iff
  /// `(someDate + TimeSpan1).compareTo(someDate + TimeSpan2) < 0`.
  int compareTo(TimeSpan other) =>
      internalTimeSpan.compareTo(other.internalTimeSpan);

  /// Returns a string representation of this [TimeSpan].
  ///
  /// Returns a string with hours, minutes, seconds, and microseconds, in the
  /// following format: `H:MM:SS.mmmmmm`. For example,
  /// ```dart
  /// var d = const TimeSpan(days: 1, hours: 1, minutes: 33, microseconds: 500);
  /// print(d.toString()); // 25:33:00.000500
  ///
  /// d = const TimeSpan(hours: 1, minutes: 10, microseconds: 500);
  /// print(d.toString()); // 1:10:00.000500
  /// ```
  String toString() {
    var microseconds = inMicroseconds;
    var sign = (microseconds < 0) ? "-" : "";

    var hours = microseconds ~/ microsecondsPerHour;
    microseconds = microseconds.remainder(microsecondsPerHour);

    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ microsecondsPerMinute;
    microseconds = microseconds.remainder(microsecondsPerMinute);

    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ microsecondsPerSecond;
    microseconds = microseconds.remainder(microsecondsPerSecond);

    var secondsPadding = seconds < 10 ? "0" : "";

    var paddedMicroseconds = microseconds.toString().padLeft(6, "0");
    return "$sign${hours.abs()}:"
        "$minutesPadding$minutes:"
        "$secondsPadding$seconds.$paddedMicroseconds";
  }

  /// Whether this [TimeSpan] is negative.
  ///
  /// A negative [TimeSpan] represents the difference from a later time to an
  /// earlier time.
  bool get isNegative => internalTimeSpan < 0;

  /// Creates a new [TimeSpan] representing the absolute length of this
  /// [TimeSpan].
  ///
  /// The returned [TimeSpan] has the same length as this one, but is always
  /// positive where possible.
  TimeSpan abs() => TimeSpan.fromMicroseconds(internalTimeSpan.abs());

  /// Creates a new [TimeSpan] with the opposite direction of this [TimeSpan].
  ///
  /// The returned [TimeSpan] has the same length as this one, but will have the
  /// opposite sign (as reported by [isNegative]) as this one where possible.
  // Using subtraction helps dart2js avoid negative zeros.
  TimeSpan operator -() => TimeSpan.fromMicroseconds(0 - internalTimeSpan);
}
