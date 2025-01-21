import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
@serializable
class THDimensionsValueCommandOption extends THCommandOption
    with Dataclass<THDimensionsValueCommandOption> {
  static const String _thisOptionType = 'value';
  late final THDoublePart _above;
  late final THDoublePart _below;
  final THLengthUnitPart _unit = THLengthUnitPart.fromString('m');
  bool unitSet = false;

  THDimensionsValueCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required THDoublePart above,
    required THDoublePart below,
    String? unit,
  }) : super() {
    _above = above;
    _below = below;
    if ((unit != null) && (unit.isNotEmpty)) {
      unitFromString(unit);
    }
  }

  THDimensionsValueCommandOption.fromString({
    required super.optionParent,
    required String above,
    required String below,
    String? unit,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    _above = THDoublePart.fromString(above);
    _below = THDoublePart.fromString(below);
    if ((unit != null) && (unit.isNotEmpty)) {
      unitFromString(unit);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THDimensionsValueCommandOption>(this);
  }

  factory THDimensionsValueCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THDimensionsValueCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THDimensionsValueCommandOption>(this);
  }

  factory THDimensionsValueCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THDimensionsValueCommandOption>(jsonString);
  }

  @override
  THDimensionsValueCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDoublePart? above,
    THDoublePart? below,
    String? unit,
    bool makeUnitNull = false,
  }) {
    return THDimensionsValueCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      above: above ?? this.above,
      below: below ?? this.below,
      unit: makeUnitNull ? null : (unit ?? this.unit),
    );
  }

  void unitFromString(String aUnit) {
    _unit.fromString(aUnit);
    unitSet = true;
  }

  @override
  String specToFile() {
    var asString = "${_above.toString()} ${_below.toString()}";

    if (unitSet) {
      asString += " ${_unit.toString()}";
    }

    asString = "[ $asString ]";

    return asString;
  }

  THDoublePart get above => _above;

  THDoublePart get below => _below;

  String get unit => _unit.toString();
}
