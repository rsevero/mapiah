part of 'th_command_option.dart';

// dist <distance> . valid for extra points, specifies the distance to the nearest station
// (or station specified using -from option. If not specified, appropriate value from LRUD
// data is used.
class THDistCommandOption extends THCommandOption with THHasLengthMixin {
  THDistCommandOption.forCWJM({
    required super.parentMapiahID,
    required THDoublePart length,
    required THLengthUnitPart unit,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
  }

  THDistCommandOption.fromString({
    required super.optionParent,
    required String distance,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: distance);
    unitFromString(unit);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.dist;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'length': length.toMap(),
      'unit': unit,
    };
  }

  factory THDistCommandOption.fromMap(Map<String, dynamic> map) {
    return THDistCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      length: THDoublePart.fromMap(map['length']),
      unit: map['unit'],
    );
  }

  factory THDistCommandOption.fromJson(String jsonString) {
    return THDistCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDistCommandOption copyWith({
    int? parentMapiahID,
    THDoublePart? length,
    THLengthUnitPart? unit,
  }) {
    return THDistCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      length: length ?? this.length,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THDistCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.length == length &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        length,
        unit,
      );
}
