part of 'th_command_option.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
class THExploredCommandOption extends THCommandOption with THHasLengthMixin {
  THExploredCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required THDoublePart length,
    required THLengthUnitPart unit,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
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
    });

    return map;
  }

  factory THExploredCommandOption.fromMap(Map<String, dynamic> map) {
    return THExploredCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      unit: THLengthUnitPart.fromMap(map['unit']),
    );
  }

  factory THExploredCommandOption.fromJson(String jsonString) {
    return THExploredCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THExploredCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THDoublePart? length,
    THLengthUnitPart? unit,
  }) {
    return THExploredCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      length: length ?? this.length,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THExploredCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.length == length &&
        other.unit == unit;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        length,
        unit,
      );
}
