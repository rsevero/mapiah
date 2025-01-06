import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_cs_part.mapper.dart';

@MappableClass()
class THCSPart with THCSPartMappable {
  late String _name;
  late final bool _forOutputOnly;

  THCSPart(String name, bool forOutputOnly) {
    _forOutputOnly = forOutputOnly;
    this.name = name;
  }

  static final HashSet<String> _csList =
      HashSet<String>.from(['lat-long', 'long-lat', 'S-MERC']);

  static final HashSet<String> _csNotForOutput =
      HashSet<String>.from(['lat-long', 'long-lat', 'JTSK']);

  static final List<RegExp> _csRegexes = [
    RegExp(r'^(UTM\d{1,2}(N|S)?)?'),
    RegExp(r'^((EPSG|ESRI):\d+)$'),
    RegExp(r'^(i?JTSK(03)?)$'),
    RegExp(r'^(ETRS(2[89]|3[0-7])?)$'),
    RegExp(r'^(OSGB:[HNOST][A-HJ-Z])$'),
  ];

  static bool isCS(String aCS, bool forOutput) {
    if (forOutput && _csNotForOutput.contains(aCS)) {
      return false;
    }

    if (_csList.contains(aCS)) {
      return true;
    }

    for (final RegExp regex in _csRegexes) {
      if (regex.hasMatch(aCS)) {
        return true;
      }
    }

    return false;
  }

  @override
  String toString() {
    return _name;
  }

  set name(String aCS) {
    if (!THCSPart.isCS(aCS, _forOutputOnly)) {
      String message = _forOutputOnly ? 'OUTPUT ONLY' : 'non-output';
      message = "Unsupported THCSPart '$aCS' in '$message' mode.";
      throw THCustomException(message);
    }

    _name = aCS;
  }

  String get name {
    return _name;
  }

  bool get forOutputOnly {
    return _forOutputOnly;
  }
}
