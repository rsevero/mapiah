import 'package:intl/intl.dart';

typedef THDatetimePart = ({
  int? year,
  int? month,
  int? day,
  int? hour,
  int? minute,
  int? second,
  int? fractionalSeconds,
});

/// Holds a date time value or interval
class THDatetime {
  THDatetimePart start = (
    year: null,
    month: null,
    day: null,
    hour: null,
    minute: null,
    second: null,
    fractionalSeconds: null,
  );

  THDatetimePart end = (
    year: null,
    month: null,
    day: null,
    hour: null,
    minute: null,
    second: null,
    fractionalSeconds: null,
  );

  String singleDateToString(THDatetimePart date) {
    var result = '';

    if (date.year == null) {
      return '-';
    }
    var year = (start.year! < 1000) ? date.year! + 2000 : date.year;
    result += year.toString();

    NumberFormat twoDigitsFormatter = NumberFormat("00");

    if (date.month == null) {
      return result;
    }
    result += ".${twoDigitsFormatter.format(date.month)}";

    if (date.day == null) {
      return result;
    }
    result += ".${twoDigitsFormatter.format(date.day)}";

    if (date.hour == null) {
      return result;
    }
    result += "@${twoDigitsFormatter.format(date.hour)}";

    if (date.minute == null) {
      return result;
    }
    result += ":${twoDigitsFormatter.format(date.minute)}";

    if (date.second == null) {
      return result;
    }
    result += ":${twoDigitsFormatter.format(date.second)}";

    if (date.fractionalSeconds == null) {
      return result;
    }
    var fractional = (date.fractionalSeconds! > 99)
        ? date.fractionalSeconds.toString()
        : twoDigitsFormatter.format(date.fractionalSeconds);

    result += ".$fractional";

    return result;
  }

  @override
  String toString() {
    if (start.year == null) {
      return '-';
    }

    var result = singleDateToString(start);

    if (end.year != null) {
      result += ' - ${singleDateToString(end)}';
    }

    return result;
  }
}
