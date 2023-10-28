import 'dart:collection';

class THCSPart {
  late String _coordinateSystem;

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
    if (!THCSPart.isCS(aCS)) {
      throw 'Unknown coordinate system.';
    }

    coordinateSystem = aCS;
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

  set coordinateSystem(String aCS) {
    if (!THCSPart.isCS(aCS)) {
      return;
    }

    _coordinateSystem = aCS;
  }

  String get coordinateSystem {
    return _coordinateSystem;
  }

  @override
  String toString() {
    return coordinateSystem;
  }
}
