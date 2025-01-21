import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';

// cs <coordinate system> assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.
@serializable
class THCSCommandOption extends THCommandOption
    with Dataclass<THCSCommandOption> {
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
    return dogs.toNative<THCSCommandOption>(this);
  }

  factory THCSCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THCSCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THCSCommandOption>(this);
  }

  factory THCSCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THCSCommandOption>(jsonString);
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
  String specToFile() {
    return cs.toString();
  }
}
