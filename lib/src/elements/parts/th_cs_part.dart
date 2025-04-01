import 'dart:collection';
import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';

class THCSPart extends THPart {
  late final String name;
  late final bool forOutputOnly;

  THCSPart({
    required this.name,
    required this.forOutputOnly,
  });

  @override
  THPartType get type => THPartType.cs;

  static final HashSet<String> _csList =
      HashSet<String>.from(['lat-long', 'long-lat', 's-merc']);

  static final HashSet<String> _csNotForOutput =
      HashSet<String>.from(['lat-long', 'long-lat', 'jtsk']);

  static final List<RegExp> _csRegexes = [
    RegExp(r'^(UTM\d{1,2}(N|S)?)?', caseSensitive: false),
    RegExp(r'^((EPSG|ESRI):\d+)$', caseSensitive: false),
    RegExp(r'^(i?JTSK(03)?)$', caseSensitive: false),
    RegExp(r'^(ETRS(2[89]|3[0-7])?)$', caseSensitive: false),
    RegExp(r'^(OSGB:[HNOST][A-HJ-Z])$', caseSensitive: false),
  ];

  static bool isCS(String cs, bool forOutput) {
    final String lowerCS = cs.toLowerCase();

    if (forOutput && _csNotForOutput.contains(lowerCS)) {
      return false;
    }

    if (_csList.contains(lowerCS)) {
      return true;
    }

    for (final RegExp regex in _csRegexes) {
      if (regex.hasMatch(cs)) {
        return true;
      }
    }

    return false;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'partType': type.name,
      'name': name,
      'forOutputOnly': forOutputOnly,
    };
  }

  factory THCSPart.fromMap(Map<String, dynamic> map) {
    return THCSPart(
      name: map['name'],
      forOutputOnly: map['forOutputOnly'],
    );
  }

  factory THCSPart.fromJson(String jsonString) {
    return THCSPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THCSPart copyWith({
    String? name,
    bool? forOutputOnly,
  }) {
    return THCSPart(
      name: name ?? this.name,
      forOutputOnly: forOutputOnly ?? this.forOutputOnly,
    );
  }

  @override
  bool operator ==(covariant THCSPart other) {
    if (identical(this, other)) return true;

    return other.name == name && other.forOutputOnly == forOutputOnly;
  }

  @override
  int get hashCode => Object.hash(name, forOutputOnly);

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
