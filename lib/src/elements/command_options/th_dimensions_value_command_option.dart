part of 'th_command_option.dart';

// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
class THDimensionsValueCommandOption extends THCommandOption {
  late final THDoublePart above;
  late final THDoublePart below;
  late final THLengthUnitPart _unit;
  late final bool unitSet;

  THDimensionsValueCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.above,
    required this.below,
    required THLengthUnitPart unit,
    required this.unitSet,
  })  : _unit = unit,
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

  @override
  THCommandOptionType get optionType => THCommandOptionType.dimensionsValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'above': above.toMap(),
      'below': below.toMap(),
      'unit': _unit.toMap(),
      'unitSet': unitSet,
    };
  }

  factory THDimensionsValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDimensionsValueCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
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
    THDoublePart? above,
    THDoublePart? below,
    THLengthUnitPart? unit,
    bool? unitSet,
  }) {
    return THDimensionsValueCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
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
        other.above == above &&
        other.below == below &&
        other.unit == unit &&
        other.unitSet == unitSet;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
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
