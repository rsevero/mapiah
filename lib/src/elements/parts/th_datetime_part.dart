import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Holds a date time value or interval
/// date . a date (or a time interval) specification in the format
/// YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
/// or ‘-’ to leave a date unspecified.
class THDatetimePart extends THPart {
  late final String _datetime;
  late final bool _isRange;
  late final bool _isEmpty;

  THDatetimePart({
    required String datetime,
    required bool isRange,
    required bool isEmpty,
  }) {
    _datetime = datetime;
    _isRange = isRange;
    _isEmpty = isEmpty;
  }

  THDatetimePart.fromString({required String datetime}) {
    this.datetime = datetime;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'datetime': _datetime,
      'isRange': _isRange,
      'isEmpty': _isEmpty,
    };
  }

  factory THDatetimePart.fromMap(Map<String, dynamic> map) {
    return THDatetimePart(
      datetime: map['datetime'],
      isRange: map['isRange'],
      isEmpty: map['isEmpty'],
    );
  }

  factory THDatetimePart.fromJson(String jsonString) {
    return THDatetimePart.fromMap(jsonDecode(jsonString));
  }

  @override
  THDatetimePart copyWith({
    String? datetime,
    bool? isRange,
    bool? isEmpty,
  }) {
    return THDatetimePart(
      datetime: datetime ?? _datetime,
      isRange: isRange ?? _isRange,
      isEmpty: isEmpty ?? _isEmpty,
    );
  }

  @override
  bool operator ==(covariant THDatetimePart other) {
    if (identical(this, other)) return true;

    return other._datetime == _datetime &&
        other._isRange == _isRange &&
        other._isEmpty == _isEmpty;
  }

  @override
  int get hashCode => Object.hash(_datetime, _isRange, _isEmpty);

  String get datetime {
    return _datetime;
  }

  set datetime(String date) {
    date = date.trim();

    _isRange = false;
    if (date == '-') {
      _isEmpty = true;
      _datetime = '-';
      return;
    } else {
      _isEmpty = false;
    }

    final List<String> parts = date.split('-');

    String newDatetime = '';

    if ((parts.length == 1) || (parts.length == 2)) {
      parts[0] = parts[0].trim();
      if (!thDatetimeRegex.hasMatch(parts[0])) {
        throw THCustomException(
            "Can´t parse start of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$date'");
      }
      newDatetime = parts[0];
      if (parts.length == 2) {
        parts[1] = parts[1].trim();
        if (!thDatetimeRegex.hasMatch(parts[1])) {
          throw THCustomException(
              "Can´t parse end of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$date'");
        }
        newDatetime += ' - ${parts[1]}';
        _isRange = true;
      }
    } else {
      throw THCustomException(
          "Can´t parse datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]) from '$date'");
    }

    _datetime = newDatetime;
  }

  bool get isRange {
    return _isRange;
  }

  bool get isEmpty {
    return _isEmpty;
  }

  @override
  String toString() {
    return _datetime;
  }
}
