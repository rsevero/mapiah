part of 'th_command_option.dart';

// height: according to the sign of the value (positive, negative or unsigned), this type of
// symbol represents chimney height, pit depth or step height in general. The numeric
// value can be optionally followed by ‘?’, if the value is presumed and units can be added
// (e.g. -value [40? ft]).
class THPointHeightValueCommandOption extends THCommandOption
    with THHasLengthMixin {
  late bool isPresumed;

  THPointHeightValueCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required THDoublePart length,
    required this.isPresumed,
    required THLengthUnitPart unit,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
  }

  THPointHeightValueCommandOption.fromString({
    required super.optionParent,
    required String height,
    required this.isPresumed,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: height);
    unitFromString(unit);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.pointHeightValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'length': length.toMap(),
      'isPresumed': isPresumed,
      'unit': unit.toMap(),
    });

    return map;
  }

  factory THPointHeightValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THPointHeightValueCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      isPresumed: map['isPresumed'],
      unit: THLengthUnitPart.fromMap(map['unit']),
    );
  }

  factory THPointHeightValueCommandOption.fromJson(String jsonString) {
    return THPointHeightValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPointHeightValueCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THDoublePart? length,
    bool? isPresumed,
    THLengthUnitPart? unit,
  }) {
    return THPointHeightValueCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      length: length ?? this.length,
      isPresumed: isPresumed ?? this.isPresumed,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THPointHeightValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.length == length &&
        other.isPresumed == isPresumed &&
        other.unit == unit;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        length,
        isPresumed,
        unit,
      );

  @override
  String specToFile() {
    var asString = length.toString();

    if (unitSet || isPresumed) {
      if (isPresumed) {
        asString += '?';
      }

      if (unitSet) {
        asString += " $unit";
      }
      return "[ $asString ]";
    }

    return asString;
  }
}
