import 'dart:collection';

import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THCSPart {
  late String _name;
  late bool forOutputOnly;

  static final _csList =
      HashSet<String>.from(['lat-long', 'long-lat', 'S-MERC']);

  static final _csNotForOutput =
      HashSet<String>.from(['lat-long', 'long-lat', 'JTSK']);

  static final _csRegexes = [
    RegExp(r'^(UTM\d{1,2}(N|S)?)?'),
    RegExp(r'^((EPSG|ESRI):\d+)$'),
    RegExp(r'^(i?JTSK(03)?)$'),
    RegExp(r'^(ETRS(2[89]|3[0-7])?)$'),
    RegExp(r'^(OSGB:[HNOST][A-HJ-Z])$'),
  ];

  THCSPart(String aCS, this.forOutputOnly) {
    name = aCS;
  }

  static bool isCS(String aCS, bool forOutput) {
    if (forOutput && _csNotForOutput.contains(aCS)) {
      return false;
    }

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
    if (!THCSPart.isCS(aCS, forOutputOnly)) {
      var message = forOutputOnly ? 'OUTPUT ONLY' : 'non-output';
      message = "Unsupported THCSPart '$aCS' in '$message' mode.";
      throw THCustomException(message);
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
