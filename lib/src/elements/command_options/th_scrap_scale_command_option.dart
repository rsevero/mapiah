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
  final List<THDoublePart> _numericSpecifications;
  final THLengthUnitPart unitPart;

  THScrapScaleCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required List<THDoublePart> numericSpecifications,
    required this.unitPart,
  })  : _numericSpecifications = numericSpecifications,
        super.forCWJM();

  THScrapScaleCommandOption({
    required super.optionParent,
    required List<THDoublePart> numericSpecifications,
    required this.unitPart,
    super.originalLineInTH2File = '',
  })  : _numericSpecifications = numericSpecifications,
        super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.scrapScale;

  @override
  String typeToFile() => 'scale';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'numericSpecifications':
          _numericSpecifications.map((e) => e.toMap()).toList(),
      'unit': unitPart.toMap(),
    });

    return map;
  }

  factory THScrapScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THScrapScaleCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      numericSpecifications: List<THDoublePart>.from(
          map['numericSpecifications'].map((e) => THDoublePart.fromMap(e))),
      unitPart: THLengthUnitPart.fromMap(map['unit']),
    );
  }

  factory THScrapScaleCommandOption.fromJson(String jsonString) {
    return THScrapScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrapScaleCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    List<THDoublePart>? numericSpecifications,
    THLengthUnitPart? unit,
  }) {
    return THScrapScaleCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      numericSpecifications: numericSpecifications ?? _numericSpecifications,
      unitPart: unit ?? this.unitPart,
    );
  }

  @override
  bool operator ==(covariant THScrapScaleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other._numericSpecifications == _numericSpecifications &&
        other.unitPart == unitPart;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        _numericSpecifications,
        unitPart,
      );

  double get lengthUnitsPerPoint {
    switch (_numericSpecifications.length) {
      case 1:
        return _numericSpecifications[0].value;
      case 2:
        return _numericSpecifications[1].value /
            _numericSpecifications[0].value;
      case 8:
        double pointSize = MPNumericAux.pointsDistance(
          Offset(
            _numericSpecifications[0].value,
            _numericSpecifications[1].value,
          ),
          Offset(
            _numericSpecifications[2].value,
            _numericSpecifications[3].value,
          ),
        );
        double realSize = MPNumericAux.pointsDistance(
          Offset(
            _numericSpecifications[4].value,
            _numericSpecifications[5].value,
          ),
          Offset(
            _numericSpecifications[6].value,
            _numericSpecifications[7].value,
          ),
        );
        return realSize / pointSize;
      default:
        throw THCustomException(
            'THScrapScaleCommandOption.lengthUnitsPerPoint');
    }
  }

  @override
  String specToFile() {
    String asString = '';

    for (var aValue in _numericSpecifications) {
      asString += ' ${aValue.toString()}';
    }

    asString += ' ${unitPart.toString()}';
    asString = '[ ${asString.trim()} ]';

    return asString;
  }
}
