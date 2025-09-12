part of 'th_command_option.dart';

// scale <specification> . is used to pre-scale (convert coordinates from pixels
// to meters) the scrap data. If scrap projection is none, this is the only
// transformation that is done with coordinates. The <specification> has four
// forms:
// 1. <number> . <number> meters per drawing unit.
// 2. [<number> <length units>] . <number> <length units> per drawing unit.
// 3. [<num1> <num2> <length units>] . <num1> drawing units corresponds to
// <num2> <length units> in reality.
// 4. [<num1> ... <num8> [<length units>]] . this is the most general format,
// where you specify, in order, the x and y coordinates of two points in the
// scrap and two points in reality. Optionally, you can also specify units for
// the coordinates of the ‘points in reality’. This form allows you to apply
// both scaling and rotation to the scrap.
class THScrapScaleCommandOption extends THCommandOption {
  final List<THDoublePart> numericSpecifications;
  final THLengthUnitPart unitPart;

  THScrapScaleCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.numericSpecifications,
    required this.unitPart,
  }) : super.forCWJM();

  THScrapScaleCommandOption({
    required super.optionParent,
    required this.numericSpecifications,
    required this.unitPart,
    super.originalLineInTH2File = '',
  }) : super();

  THScrapScaleCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    super.originalLineInTH2File = '',
    required this.numericSpecifications,
    required this.unitPart,
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.scrapScale;

  @override
  String typeToFile() => 'scale';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'numericSpecifications': numericSpecifications
          .map((e) => e.toMap())
          .toList(),
      'unit': unitPart.toMap(),
    });

    return map;
  }

  factory THScrapScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THScrapScaleCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      numericSpecifications: List<THDoublePart>.from(
        map['numericSpecifications'].map((e) => THDoublePart.fromMap(e)),
      ),
      unitPart: THLengthUnitPart.fromMap(map['unit']),
    );
  }

  factory THScrapScaleCommandOption.fromJson(String jsonString) {
    return THScrapScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrapScaleCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    List<THDoublePart>? numericSpecifications,
    THLengthUnitPart? unitPart,
  }) {
    return THScrapScaleCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      numericSpecifications:
          numericSpecifications ?? this.numericSpecifications,
      unitPart: unitPart ?? this.unitPart,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THScrapScaleCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.numericSpecifications == numericSpecifications &&
        other.unitPart == unitPart;
  }

  @override
  int get hashCode =>
      super.hashCode ^ Object.hash(numericSpecifications, unitPart);

  double get lengthUnitsPerPoint {
    switch (numericSpecifications.length) {
      case 1:
        return numericSpecifications[0].value;
      case 2:
        return numericSpecifications[1].value / numericSpecifications[0].value;
      case 8:
        double pointSize = MPNumericAux.pointsDistance(
          Offset(
            numericSpecifications[0].value,
            numericSpecifications[1].value,
          ),
          Offset(
            numericSpecifications[2].value,
            numericSpecifications[3].value,
          ),
        );
        double realSize = MPNumericAux.pointsDistance(
          Offset(
            numericSpecifications[4].value,
            numericSpecifications[5].value,
          ),
          Offset(
            numericSpecifications[6].value,
            numericSpecifications[7].value,
          ),
        );
        return realSize / pointSize;
      default:
        throw THCustomException(
          'THScrapScaleCommandOption.lengthUnitsPerPoint',
        );
    }
  }

  @override
  String specToFile() {
    String asString = '';

    for (THDoublePart numericSpecification in numericSpecifications) {
      asString += ' ${numericSpecification.toString()}';
    }

    asString += ' ${unitPart.toString()}';
    asString = '[ ${asString.trim()} ]';

    return asString;
  }
}
