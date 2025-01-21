import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';

// cs <coordinate system> assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.
class THCSCommandOption extends THCommandOption {
  late final THCSPart cs;

  /// Constructor necessary for dart_mappable support.
  THCSCommandOption({
    required super.parentMapiahID,
    required this.cs,
  }) : super();

  THCSCommandOption.fromString({
    required super.optionParent,
    required String csString,
    required bool forOutputOnly,
  }) : super.addToOptionParent() {
    cs = THCSPart(name: csString, forOutputOnly: forOutputOnly);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.cs;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'cs': cs.toMap(),
    };
  }

  factory THCSCommandOption.fromMap(Map<String, dynamic> map) {
    return THCSCommandOption(
      parentMapiahID: map['parentMapiahID'],
      cs: THCSPart.fromMap(map['cs']),
    );
  }

  factory THCSCommandOption.fromJson(String jsonString) {
    return THCSCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCSCommandOption copyWith({
    int? parentMapiahID,
    THCSPart? cs,
  }) {
    return THCSCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      cs: cs ?? this.cs,
    );
  }

  @override
  bool operator ==(covariant THCSCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.cs == cs;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        cs,
      );

  @override
  String specToFile() {
    return cs.toString();
  }
}
