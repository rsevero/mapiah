part of 'th_command_option.dart';

// altitude: the value specified is the altitude difference from the nearest station. The
// value will be set to 0 if defined as ‘-’, ‘.’, ‘nan’, ‘NAN’ or ‘NaN’. If the altitude value is
// prefixed by ‘fix’ (e.g. -value [fix 1300]), this value is used as an absolute altitude.
// The value can optionally be followed by length units.
class THAltitudeValueCommandOption extends THCommandOption
    with THHasLengthMixin, THHasAltitudeMixin {
  THAltitudeValueCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required THDoublePart length,
    required bool isFix,
    required bool isNan,
    required THLengthUnitPart unit,
  }) : super.forCWJM() {
    this.length = length;
    this.isFix = isFix;
    this.isNan = isNan;
    this.unit = unit;
  }

  THAltitudeValueCommandOption({
    required super.optionParent,
    required THDoublePart length,
    required bool isFix,
    bool isNan = false,
    required String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    this.length = length;
    this.isFix = isFix;
    this.isNan = isNan;
    unitFromString(unit);
  }

  THAltitudeValueCommandOption.fromString({
    required super.optionParent,
    required String height,
    required bool isFix,
    bool isNan = false,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: height);
    this.isFix = isFix;
    this.isNan = isNan;
    unitFromString(unit);
  }

  THAltitudeValueCommandOption.fromNan({
    required super.optionParent,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: '0');
    isFix = false;
    isNan = true;
    unitFromString('');
  }

  @override
  THCommandOptionType get type => THCommandOptionType.altitudeValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'length': length.toMap(),
      'isFix': isFix,
      'isNan': isNan,
      'unit': unit,
    });

    return map;
  }

  factory THAltitudeValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THAltitudeValueCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      isFix: map['isFix'],
      isNan: map['isNan'],
      unit: map['unit'],
    );
  }

  factory THAltitudeValueCommandOption.fromJson(String jsonString) {
    return THAltitudeValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAltitudeValueCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? length,
    bool? isFix,
    bool? isNan,
    THLengthUnitPart? unit,
  }) {
    return THAltitudeValueCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      length: length ?? this.length,
      isFix: isFix ?? this.isFix,
      isNan: isNan ?? this.isNan,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THAltitudeValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.length == length &&
        other.isFix == isFix &&
        other.isNan == isNan &&
        other.unit == unit;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        length,
        isFix,
        isNan,
        unit,
      );
}
