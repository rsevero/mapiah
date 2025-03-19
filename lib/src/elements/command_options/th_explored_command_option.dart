part of 'th_command_option.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
class THExploredCommandOption extends THCommandOption with THHasLengthMixin {
  THExploredCommandOption.forCWJM({
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

  THExploredCommandOption.fromString({
    required super.optionParent,
    required String distance,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: distance);
    unitFromString(unit);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.explored;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'length': length.toMap(),
      'unit': unit.toMap(),
      'unitSet': unitSet,
    });

    return map;
  }

  factory THExploredCommandOption.fromMap(Map<String, dynamic> map) {
    return THExploredCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      unit: THLengthUnitPart.fromMap(map['unit']),
      unitSet: map['unitSet'],
    );
  }

  factory THExploredCommandOption.fromJson(String jsonString) {
    return THExploredCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THExploredCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? length,
    THLengthUnitPart? unit,
    bool makeUnitNull = false,
    bool? unitSet,
  }) {
    return THExploredCommandOption.forCWJM(
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
  bool operator ==(covariant THExploredCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.length == length &&
        other.unit == unit &&
        other.unitSet == unitSet;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        length,
        unit,
        unitSet,
      );
}
