part of 'th_command_option.dart';

// altitude <value> . can be specified only with the wall type. This option creates an
// altitude label on the wall. All altitudes are exported as a difference against grid Z
// origin (which is 0 by default). If the value is specified, it gives the altitude difference
// of the point on the wall relative to the nearest station. The value will be set to 0 if
// defined as ”-”, ”.”, ”nan”, ”NAN” or ”NaN”. The value can be prefixed by a keyword
// “fix”, then no nearest station is taken into consideration; the absolute given value is
// used instead. Units can follow the value. Examples: +4, [+4 m], [fix 1510 m].
class THAltitudeCommandOption extends THCommandOption
    with THHasLengthMixin, THHasAltitudeMixin {
  THAltitudeCommandOption.forCWJM({
    required super.parentMapiahID,
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

  THAltitudeCommandOption({
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

  THAltitudeCommandOption.fromString({
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

  THAltitudeCommandOption.fromNan({
    required super.optionParent,
    super.originalLineInTH2File = '',
  }) : super() {
    length = THDoublePart.fromString(valueString: '0');
    isFix = false;
    isNan = true;
    unitFromString('');
  }

  @override
  THCommandOptionType get type => THCommandOptionType.altitude;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'length': length.toMap(),
      'isFix': isFix,
      'isNan': isNan,
      'unit': unit.toMap(),
    });

    return map;
  }

  factory THAltitudeCommandOption.fromMap(Map<String, dynamic> map) {
    return THAltitudeCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      length: THDoublePart.fromMap(map['length']),
      isFix: map['isFix'],
      isNan: map['isNan'],
      unit: map['unit'],
    );
  }

  factory THAltitudeCommandOption.fromJson(String jsonString) {
    return THAltitudeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAltitudeCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THDoublePart? length,
    bool? isFix,
    bool? isNan,
    THLengthUnitPart? unit,
    bool makeUnitNull = false,
  }) {
    return THAltitudeCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      length: length ?? this.length,
      isFix: isFix ?? this.isFix,
      isNan: isNan ?? this.isNan,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THAltitudeCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
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
