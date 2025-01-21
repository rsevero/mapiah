import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';

// cs <coordinate system> assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.
class THCSCommandOption extends THCommandOption {
  static const String _thisOptionType = 'cs';
  late final THCSPart cs;

  /// Constructor necessary for dart_mappable support.
  THCSCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.cs,
  }) : super();

  THCSCommandOption.fromString({
    required super.optionParent,
    required String csString,
    required bool forOutputOnly,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    cs = THCSPart(name: csString, forOutputOnly: forOutputOnly);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'cs': cs.toMap(),
    };
  }

  factory THCSCommandOption.fromMap(Map<String, dynamic> map) {
    return THCSCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      cs: THCSPart.fromMap(map['cs']),
    );
  }

  factory THCSCommandOption.fromJson(String jsonString) {
    return THCSCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCSCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THCSPart? cs,
  }) {
    return THCSCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      cs: cs ?? this.cs,
    );
  }

  @override
  bool operator ==(covariant THCSCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.cs == cs;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        cs,
      );

  @override
  String specToFile() {
    return cs.toString();
  }
}
