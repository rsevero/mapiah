import 'dart:collection';

import 'package:mapiah/src/th_exceptions/th_convert_from_string_exception.dart';

class THCSPart {
  late String _name;

  static final _csList =
      HashSet<String>.from(['lat-long', 'long-lat', 'S-MERC']);

  static final _csRegexes = [
    RegExp(r'^(UTM\d{1,2}(N|S)?)?'),
    RegExp(r'^((EPSG|ESRI):\d+)$'),
    RegExp(r'^(i?JTSK(03)?)$'),
    RegExp(r'^(ETRS(2[89]|3[0-7])?)$'),
    RegExp(r'^(OSGB:[HNOST][A-HJ-Z])$'),
  ];

  THCSPart(String aCS) {
    name = aCS;
  }

  static bool isCS(String aCS) {
    if (_csList.contains(aCS)) {
      return true;
    }

    for (final regex in _csRegexes) {
      if (regex.hasMatch(aCS)) {
        return true;
      }
    }

    return false;
  }

  set name(String aCS) {
    if (!THCSPart.isCS(aCS)) {
      throw THConvertFromStringException(runtimeType.toString(), aCS);
    }

    _name = aCS;
  }

  String get name {
    return _name;
  }

  @override
  String toString() {
    return name;
  }
}
