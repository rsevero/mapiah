part of 'th_element.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
abstract class THLineSegment extends THElement
    implements THPointInterface, THHasOptionsMixin {
  late final THPositionPart endPoint;
  Rect? _boundingBox;

  THLineSegment.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.endPoint,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    addOptionsMap(optionsMap);
  }

  THLineSegment.withEndPoint({
    required super.parentMPID,
    super.sameLineComment,
    required this.endPoint,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  THLineSegment.withoutEndPoint({
    required super.parentMPID,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.lineSegment;

  @override
  double get x {
    return endPoint.coordinates.dx;
  }

  @override
  double get y {
    return endPoint.coordinates.dy;
  }

  int get endPointDecimalPositions {
    return endPoint.decimalPositions;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'endPoint': endPoint.toMap(),
      'optionsMap': THHasOptionsMixin.optionsMapToMap(optionsMap),
    });

    return map;
  }

  static THLineSegment fromMap(Map<String, dynamic> map) {
    final THElementType elementType =
        THElementType.values.byName(map['elementType']);

    switch (elementType) {
      case THElementType.straightLineSegment:
        return THStraightLineSegment.fromMap(map);
      case THElementType.bezierCurveLineSegment:
        return THBezierCurveLineSegment.fromMap(map);
      default:
        throw Exception('Invalid THElementType: $elementType');
    }
  }

  @override
  THLineSegment copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THPositionPart? endPoint,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
  });

  @override
  bool equalsBase(Object other) {
    return endPoint == (other as THLineSegment).endPoint &&
        mapEquals(optionsMap, other.optionsMap);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THLineSegment) return false;
    if (!super.equalsBase(other)) return false;

    return equalsBase(other);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        endPoint,
        optionsMap,
      );

  Rect getBoundingBox(Offset startPoint) {
    _boundingBox ??= _calculateBoundingBox(startPoint);

    return _boundingBox!;
  }

  Rect _calculateBoundingBox(Offset startPoint);
}
