part of 'th_command_option.dart';

enum THPassageHeightModes {
  height,
  depth,
  distanceBetweenFloorAndCeiling,
  distanceToCeilingAndDistanceToFloor,
}

// passage-height: the following four forms of value are supported: +<number> (the height
// of the ceiling), -<number> (the depth of the floor or water depth), <number> (the dis-
// tance between floor and ceiling) and [+<number> -<number>] (the distance to ceiling
// and distance to floor).
class THPassageHeightValueCommandOption extends THCommandOption {
  late final THDoublePart? plusNumber;
  late final THDoublePart? minusNumber;
  late final THPassageHeightModes mode;
  late final THLengthUnitPart unit;
  late final bool plusHasSign;

  THPassageHeightValueCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    this.plusNumber,
    this.minusNumber,
    required this.unit,
    required this.mode,
    required this.plusHasSign,
  }) : super.forCWJM();

  THPassageHeightValueCommandOption.fromString({
    required super.optionParent,
    required String plusNumber,
    required String minusNumber,
    String? unit,
    super.originalLineInTH2File = '',
  }) : super() {
    unitFromString(unit);
    plusAndMinusNumbersFromString(plusNumber, minusNumber);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.passageHeightValue;

  @override
  String typeToFile() => 'value';

  void unitFromString(String? unit) {
    if ((unit != null) && (unit.isNotEmpty)) {
      this.unit = THLengthUnitPart.fromString(unitString: unit);
    } else {
      this.unit =
          THLengthUnitPart.fromString(unitString: thDefaultLengthUnitAsString);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'plusNumber': plusNumber?.toMap(),
      'minusNumber': minusNumber?.toMap(),
      'unit': unit.toMap(),
      'mode': mode.toString(),
      'plusHasSign': plusHasSign,
    });

    return map;
  }

  factory THPassageHeightValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THPassageHeightValueCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      plusNumber: map['plusNumber'] != null
          ? THDoublePart.fromMap(map['plusNumber'])
          : null,
      minusNumber: map['minusNumber'] != null
          ? THDoublePart.fromMap(map['minusNumber'])
          : null,
      unit: THLengthUnitPart.fromMap(map['unit']),
      mode: THPassageHeightModes.values
          .firstWhere((e) => e.toString() == map['mode']),
      plusHasSign: map['plusHasSign'],
    );
  }

  factory THPassageHeightValueCommandOption.fromJson(String jsonString) {
    return THPassageHeightValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPassageHeightValueCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? plusNumber,
    THDoublePart? minusNumber,
    THLengthUnitPart? unit,
    THPassageHeightModes? mode,
    bool? plusHasSign,
    bool makePlusNumberNull = false,
    bool makeMinusNumberNull = false,
  }) {
    return THPassageHeightValueCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      plusNumber: makePlusNumberNull ? null : (plusNumber ?? this.plusNumber),
      minusNumber:
          makeMinusNumberNull ? null : (minusNumber ?? this.minusNumber),
      unit: unit ?? this.unit,
      mode: mode ?? this.mode,
      plusHasSign: plusHasSign ?? this.plusHasSign,
    );
  }

  @override
  bool operator ==(covariant THPassageHeightValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.plusNumber == plusNumber &&
        other.minusNumber == minusNumber &&
        other.unit == unit &&
        other.mode == mode &&
        other.plusHasSign == plusHasSign;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        plusNumber,
        minusNumber,
        unit,
        mode,
        plusHasSign,
      );

  void _setMode() {
    if (plusNumber == null) {
      if (minusNumber == null) {
        throw THCustomException(
            "Passage-height command option must have at least one number.");
      } else {
        mode = THPassageHeightModes.depth;
      }
    } else {
      if (minusNumber == null) {
        if (plusHasSign) {
          mode = THPassageHeightModes.height;
        } else {
          mode = THPassageHeightModes.distanceBetweenFloorAndCeiling;
        }
      } else {
        mode = THPassageHeightModes.distanceToCeilingAndDistanceToFloor;
      }
    }
  }

  void plusAndMinusNumbersFromString(
    String newPlusNumber,
    String newMinusNumber,
  ) {
    if (newPlusNumber.isEmpty) {
      plusNumber = null;
      plusHasSign = false;
    } else {
      if (newPlusNumber.startsWith('+')) {
        plusHasSign = true;
        newPlusNumber = newPlusNumber.substring(1);
      } else {
        plusHasSign = false;
      }

      plusNumber = THDoublePart.fromString(valueString: newPlusNumber);

      if (plusNumber!.value < 0) {
        throw THCustomException(
            "Plus number in passage-height command option must be positive.");
      }
    }

    if (newMinusNumber.isEmpty) {
      minusNumber = null;
    } else {
      minusNumber = THDoublePart.fromString(valueString: newMinusNumber);

      if (minusNumber!.value > 0) {
        throw THCustomException(
            "Minus number in passage-height command option must be negative.");
      }
    }

    _setMode();
  }

  @override
  String specToFile() {
    switch (mode) {
      case THPassageHeightModes.height:
        return "[ +${plusNumber!.toString()} $unit ]";
      case THPassageHeightModes.depth:
        return "[ ${minusNumber!.toString()} $unit ]";
      case THPassageHeightModes.distanceBetweenFloorAndCeiling:
        return "[ ${plusNumber!.toString()} $unit ]";
      case THPassageHeightModes.distanceToCeilingAndDistanceToFloor:
        return "[ +${plusNumber!.toString()} ${minusNumber!.toString()} $unit ]";
    }
  }
}
