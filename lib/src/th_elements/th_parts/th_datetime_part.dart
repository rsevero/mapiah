import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

/// Holds a date time value or interval
/// date . a date (or a time interval) specification in the format
/// YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
/// or ‘-’ to leave a date unspecified.
class THDatetimePart {
  late String _datetime;
  late bool _isRange;
  late bool _isEmpty;

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
      if (!thDatetimeRegex.hasMatch(parts[0])) {
        throw THCustomException(
            "Can´t parse start of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$aDate'");
      }
      newDatetime = parts[0];
      if (parts.length == 2) {
        parts[1] = parts[1].trim();
        if (!thDatetimeRegex.hasMatch(parts[1])) {
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
