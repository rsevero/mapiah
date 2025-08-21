part of 'th_command_option.dart';

// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
class THDimensionsValueCommandOption extends THCommandOption {
  late final THDoublePart above;
  late final THDoublePart below;
  late final THLengthUnitPart _unit;
  late final bool unitSet;

  THDimensionsValueCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.above,
    required this.below,
    required THLengthUnitPart unit,
    required this.unitSet,
  }) : _unit = unit,
       super.forCWJM();

  THDimensionsValueCommandOption.fromString({
    required super.optionParent,
    required String above,
    required String below,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    this.above = THDoublePart.fromString(valueString: above);
    this.below = THDoublePart.fromString(valueString: below);
    unitFromString(unit);
  }

  THDimensionsValueCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String above,
    required String below,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    this.above = THDoublePart.fromString(valueString: above);
    this.below = THDoublePart.fromString(valueString: below);
    unitFromString(unit);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.dimensionsValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'above': above.toMap(),
      'below': below.toMap(),
      'unit': _unit.toMap(),
      'unitSet': unitSet,
    });

    return map;
  }

  factory THDimensionsValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDimensionsValueCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
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
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? above,
    THDoublePart? below,
    THLengthUnitPart? unit,
    bool? unitSet,
  }) {
    return THDimensionsValueCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      above: above ?? this.above,
      below: below ?? this.below,
      unit: unit ?? _unit,
      unitSet: unitSet ?? this.unitSet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THDimensionsValueCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.above == above &&
        other.below == below &&
        other.unit == unit &&
        other.unitSet == unitSet;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(above, below, unit, unitSet);

  void unitFromString(String? unit) {
    if ((unit != null) && (unit.isNotEmpty)) {
      _unit = THLengthUnitPart.fromString(unitString: unit);
      unitSet = true;
    } else {
      _unit = THLengthUnitPart.fromString(
        unitString: thDefaultLengthUnitAsString,
      );
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
