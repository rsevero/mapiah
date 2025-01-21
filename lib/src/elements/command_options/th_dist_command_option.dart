import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// dist <distance> . valid for extra points, specifies the distance to the nearest station
// (or station specified using -from option. If not specified, appropriate value from LRUD
// data is used.
@serializable
class THDistCommandOption extends THCommandOption
    with Dataclass<THDistCommandOption>, THHasLength {
  static const String _thisOptionType = 'dist';

  /// Constructor necessary for dart_mappable support.
  THDistCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required THDoublePart length,
    required String? unit,
  }) : super() {
    this.length = length;
    if (unit != null) {
      unitFromString(unit);
    }
  }

  THDistCommandOption.fromString({
    required super.optionParent,
    required String distance,
    required String? unit,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    length = THDoublePart.fromString(distance);
    if (unit != null) {
      unitFromString(unit);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THDistCommandOption>(this);
  }

  factory THDistCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THDistCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THDistCommandOption>(this);
  }

  factory THDistCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THDistCommandOption>(jsonString);
  }

  @override
  THDistCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDoublePart? length,
    String? unit,
    bool makeUnitNull = false,
  }) {
    return THDistCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      length: length ?? this.length,
      unit: makeUnitNull ? null : (unit ?? this.unit),
    );
  }
}
