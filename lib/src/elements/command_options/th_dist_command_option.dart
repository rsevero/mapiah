part of 'th_command_option.dart';

// dist <distance> . valid for extra points, specifies the distance to the
// nearest station (or station specified using -from option. If not specified,
// appropriate value from LRUD data is used.
class THDistCommandOption extends THCommandOption with THHasLengthMixin {
  THDistCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required THDoublePart length,
    required THLengthUnitPart unit,
    required bool unitSet,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
    this.unitSet = unitSet;
  }

  THDistCommandOption.fromString({
    required super.parentMPID,
    required String distance,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: distance);
    unitFromString(unit);
  }

  THDistCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String distance,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    length = THDoublePart.fromString(valueString: distance);
    unitFromString(unit);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.dist;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'length': length.toMap(), 'unit': unit});

    return map;
  }

  factory THDistCommandOption.fromMap(Map<String, dynamic> map) {
    return THDistCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      unit: THLengthUnitPart.fromMap(map['unit']),
      unitSet: map['unitSet'],
    );
  }

  factory THDistCommandOption.fromJson(String jsonString) {
    return THDistCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDistCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? length,
    THLengthUnitPart? unit,
    bool makeUnitNull = false,
    bool? unitSet,
  }) {
    return THDistCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      length: length ?? this.length,
      unit: makeUnitNull
          ? THLengthUnitPart.fromString(unitString: '')
          : unit ?? this.unit,
      unitSet: unitSet ?? this.unitSet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THDistCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.length == length &&
        other.unit == unit &&
        other.unitSet == unitSet;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(length, unit, unitSet);
}
