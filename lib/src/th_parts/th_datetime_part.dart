import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

/// Holds a date time value or interval
class THDatetimePart {
  late String _datetime;
  late bool _isRange;
  late bool _isEmpty;

  static final _datetimeRegex = RegExp(
      r'^(?<year>\d{4}(\.(?<month>(0[1-9]|1[0-2]))(\.(?<day>(0[1-9]|[12][0-9]|3[01]))(\@(?<hour>(0[0-9]|1[0-9]|2[0-4]))(\:(?<minute>(0[0-9]|[1-5][0-9]))(\:(?<second>(0[0-9]|[1-5][0-9]))(\.(?<fractional>(0[0-9]|[1-5][0-9])))?)?)?)?)?)?)$');

  THDatetimePart(String aDatetime) {
    datetime = aDatetime;
  }

  bool get isRange {
    return _isRange;
  }

  bool get isEmpty {
    return _isEmpty;
  }

  set datetime(String aDate) {
    aDate = aDate.trim();

    _isRange = false;
    if (aDate == '-') {
      _isEmpty = true;
      _datetime = '-';
      return;
    } else {
      _isEmpty = false;
    }

    final parts = aDate.split('-');

    var newDatetime = '';

    if ((parts.length == 1) || (parts.length == 2)) {
      parts[0] = parts[0].trim();
      if (!_datetimeRegex.hasMatch(parts[0])) {
        throw THCustomException(
            "Can´t parse start of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$aDate'");
      }
      newDatetime = parts[0];
      if (parts.length == 2) {
        parts[1] = parts[1].trim();
        if (!_datetimeRegex.hasMatch(parts[1])) {
          throw THCustomException(
              "Can´t parse end of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$aDate'");
        }
        newDatetime += ' - ${parts[1]}';
        _isRange = true;
      }
    } else {
      throw THCustomException(
          "Can´t parse datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]) from '$aDate'");
    }

    _datetime = newDatetime;
  }

  @override
  String toString() {
    return _datetime;
  }
}
