part of 'th_command_option.dart';

// height: according to the sign of the value (positive, negative or unsigned),
// this type of symbol represents chimney height, pit depth or step height in
// general. The numeric value can be optionally followed by ‘?’, if the value is
// presumed and units can be added (e.g. -value [40? ft]).
class THPointHeightValueCommandOption extends THCommandOption
    with THHasLengthMixin {
  late bool isPresumed;
  late THPointHeightValueMode mode;

  THPointHeightValueCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required THDoublePart length,
    required this.isPresumed,
    required this.mode,
    required THLengthUnitPart unit,
    required bool unitSet,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
    this.unitSet = unitSet;
  }

  THPointHeightValueCommandOption.fromString({
    required super.optionParent,
    required String height,
    required this.isPresumed,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    height = height.trim();
    switch (height[0]) {
      case '+':
        mode = THPointHeightValueMode.chimney;
        height = height.substring(1);
      case '-':
        mode = THPointHeightValueMode.pit;
        height = height.substring(1);
      default:
        mode = THPointHeightValueMode.step;
    }
    length = THDoublePart.fromString(valueString: height);
    unitFromString(unit);
  }

  THPointHeightValueCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.isPresumed,
    required this.mode,
    required String length,
    required String unit,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    this.length = THDoublePart.fromString(valueString: length);
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
      'mode': mode.name,
      'unit': unit.toMap(),
      'unitSet': unitSet,
    });

    return map;
  }

  factory THPointHeightValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THPointHeightValueCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      isPresumed: map['isPresumed'],
      mode: THPointHeightValueMode.values.byName(map['mode']),
      unit: THLengthUnitPart.fromMap(map['unit']),
      unitSet: map['unitSet'],
    );
  }

  factory THPointHeightValueCommandOption.fromJson(String jsonString) {
    return THPointHeightValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPointHeightValueCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? length,
    bool? isPresumed,
    THPointHeightValueMode? mode,
    THLengthUnitPart? unit,
    bool makeUnitNull = false,
    bool? unitSet,
  }) {
    return THPointHeightValueCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      length: length ?? this.length,
      isPresumed: isPresumed ?? this.isPresumed,
      mode: mode ?? this.mode,
      unit: makeUnitNull
          ? THLengthUnitPart.fromString(unitString: '')
          : unit ?? this.unit,
      unitSet: unitSet ?? this.unitSet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THPointHeightValueCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.length == length &&
        other.isPresumed == isPresumed &&
        other.mode == mode &&
        other.unit == unit &&
        other.unitSet == unitSet;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        length,
        isPresumed,
        mode,
        unit,
        unitSet,
      );

  @override
  String specToFile() {
    String asString = length.toString();

    switch (mode) {
      case THPointHeightValueMode.pit:
        asString = '-$asString';
      case THPointHeightValueMode.chimney:
        asString = '+$asString';
      case THPointHeightValueMode.step:
        break;
    }

    if (isPresumed) {
      asString += '?';
    }

    if (unitSet) {
      asString += " $unit";
    }

    return "[ $asString ]";
  }
}

enum THPointHeightValueMode {
  chimney,
  pit,
  step,
}
