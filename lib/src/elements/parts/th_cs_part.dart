import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/auxiliary/th_serializeable.dart';

@serializable
class THCSPart with Dataclass<THCSPart> implements THSerializable {
  late final String name;
  late final bool forOutputOnly;

  THCSPart({
    required this.name,
    required this.forOutputOnly,
  });

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
  Map<String, dynamic> toMap() {
    return dogs.toNative<THCSPart>(this);
  }

  factory THCSPart.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THCSPart>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THCSPart>(this);
  }

  factory THCSPart.fromJson(String jsonString) {
    return dogs.fromJson<THCSPart>(jsonString);
  }

  @override
  THCSPart copyWith({
    String? name,
    bool? forOutputOnly,
    bool makeNameNull = false,
  }) {
    return THCSPart(
      name: name ?? this.name,
      forOutputOnly: forOutputOnly ?? this.forOutputOnly,
    );
  }

  @override
  String toString() {
    return name;
  }

  // set name(String aCS) {
  //   if (!THCSPart.isCS(aCS, _forOutputOnly)) {
  //     String message = _forOutputOnly ? 'OUTPUT ONLY' : 'non-output';
  //     message = "Unsupported THCSPart '$aCS' in '$message' mode.";
  //     throw THCustomException(message);
  //   }

  //   _name = aCS;
  // }
}
