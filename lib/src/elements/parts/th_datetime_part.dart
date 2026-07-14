// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Holds a date time value or interval
/// date . a date (or a time interval) specification in the format
/// YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
/// or ‘-’ to leave a date unspecified.
class THDatetimePart extends THPart {
  late final String _datetime;
  late final bool isRange;
  late final bool isEmpty;

  THDatetimePart({required String datetime}) : super() {
    _setDatetime(datetime);
  }

  THDatetimePart.fromString({required String datetime}) {
    _setDatetime(datetime);
  }

  @override
  THPartType get type => THPartType.datetime;

  @override
  Map<String, dynamic> toMap() {
    return {
      'partType': type.name,
      'datetime': _datetime,
      'isRange': isRange,
      'isEmpty': isEmpty,
    };
  }

  factory THDatetimePart.fromMap(Map<String, dynamic> map) {
    return THDatetimePart(datetime: map['datetime']);
  }

  factory THDatetimePart.fromJson(String jsonString) {
    return THDatetimePart.fromMap(jsonDecode(jsonString));
  }

  @override
  THDatetimePart copyWith({String? datetime}) {
    return THDatetimePart(datetime: datetime ?? _datetime);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THDatetimePart &&
        other._datetime == _datetime &&
        other.isRange == isRange &&
        other.isEmpty == isEmpty;
  }

  @override
  int get hashCode => Object.hash(_datetime, isRange, isEmpty);

  void _setDatetime(String date) {
    date = date.trim();

    bool tempIsRange = false;
    if (date == '-') {
      isEmpty = true;
      _datetime = '-';
      return;
    } else {
      isEmpty = false;
    }

    final List<String> parts = date.split('-');

    String newDatetime = '';

    if ((parts.length == 1) || (parts.length == 2)) {
      parts[0] = parts[0].trim();
      if (!mpDatetimeRegex.hasMatch(parts[0])) {
        throw THCustomException(
          "Can´t parse start of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$date'",
        );
      }
      newDatetime = parts[0];
      if (parts.length == 2) {
        parts[1] = parts[1].trim();
        if (!mpDatetimeRegex.hasMatch(parts[1])) {
          throw THCustomException(
            "Can´t parse end of datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]]) from '$date'",
          );
        }
        newDatetime += ' - ${parts[1]}';
        tempIsRange = true;
      }
    } else {
      throw THCustomException(
        "Can´t parse datetime range (a datetime in the format YYYY[.MM.[DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]) from '$date'",
      );
    }

    isRange = tempIsRange;
    _datetime = newDatetime;
  }

  @override
  String toString() {
    return _datetime;
  }
}
