import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
class THDimensionsValueCommandOption extends THCommandOption {
  late final THDoublePart above;
  late final THDoublePart below;
  late final THLengthUnitPart _unit;
  late final bool unitSet;

  THDimensionsValueCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.above,
    required this.below,
    required THLengthUnitPart unit,
    required this.unitSet,
  })  : _unit = unit,
        super();

  THDimensionsValueCommandOption.fromString({
    required super.optionParent,
    required String above,
    required String below,
    String? unit,
  }) : super.addToOptionParent(
            optionType: THCommandOptionType.dimensionsValue) {
    this.above = THDoublePart.fromString(valueString: above);
    this.below = THDoublePart.fromString(valueString: below);
    unitFromString(unit);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'above': above.toMap(),
      'below': below.toMap(),
      'unit': _unit.toMap(),
      'unitSet': unitSet,
    };
  }

  factory THDimensionsValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDimensionsValueCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      above: THDoublePart.fromMap(map['above']),
      below: THDoublePart.fromMap(map['below']),
      unit: THLengthUnitPart.fromMap(map['unit']),
      unitSet: map['unitSet'],
    );
  }

  factory THDimensionsValueCommandOption.fromJson(String jsonString) {
    return THDimensionsValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDimensionsValueCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    THDoublePart? above,
    THDoublePart? below,
    THLengthUnitPart? unit,
    bool? unitSet,
  }) {
    return THDimensionsValueCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      above: above ?? this.above,
      below: below ?? this.below,
      unit: unit ?? _unit,
      unitSet: unitSet ?? this.unitSet,
    );
  }

  @override
  bool operator ==(covariant THDimensionsValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.above == above &&
        other.below == below &&
        other.unit == unit &&
        other.unitSet == unitSet;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        above,
        below,
        unit,
        unitSet,
      );

  void unitFromString(String? unit) {
    if ((unit != null) && (unit.isNotEmpty)) {
      _unit = THLengthUnitPart.fromString(unitString: unit);
      unitSet = true;
    } else {
      _unit = THLengthUnitPart.fromString(unitString: thDefaultLengthUnit);
      unitSet = false;
    }
  }

  @override
  String specToFile() {
    var asString = "${above.toString()} ${below.toString()}";

    if (unitSet) {
      asString += " ${_unit.toString()}";
    }

    asString = "[ $asString ]";

    return asString;
  }

  String get unit => _unit.toString();
}
