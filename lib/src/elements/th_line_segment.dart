part of 'th_element.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
abstract class THLineSegment extends THElement
    implements THPointInterface, THHasOptionsMixin {
  late final THPositionPart endPoint;
  Rect? _boundingBox;

  THLineSegment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
    required LinkedHashMap<String, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    addOptionsMap(optionsMap);
  }

  THLineSegment.withEndPoint({
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  THLineSegment.withoutEndPoint({
    required super.parentMapiahID,
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
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
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
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THPositionPart? endPoint,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  });

  Rect getBoundingBox(Offset startPoint) {
    _boundingBox ??= _calculateBoundingBox(startPoint);

    return _boundingBox!;
  }

  Rect _calculateBoundingBox(Offset startPoint);
}
