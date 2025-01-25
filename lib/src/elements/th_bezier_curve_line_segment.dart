part of 'th_element.dart';

// [[LINE DATA] specify the coordinates of a Bézier curve arc:
// <c1x> <c1y> <c2x> <c2y> <x> <y>, where c indicates the control point.
class THBezierCurveLineSegment extends THLineSegment with THHasOptionsMixin {
  late final THPositionPart controlPoint1;
  late final THPositionPart controlPoint2;

  // Used by dart_mappable.
  THBezierCurveLineSegment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.controlPoint1,
    required this.controlPoint2,
    required super.endPoint,
    required super.optionsMap,
  }) : super.forCWJM();

  THBezierCurveLineSegment({
    required super.parentMapiahID,
    super.sameLineComment,
    required this.controlPoint1,
    required this.controlPoint2,
    required super.endPoint,
  }) : super.withEndPoint();

  THBezierCurveLineSegment.fromString({
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> controlPoint1,
    required List<dynamic> controlPoint2,
    required List<dynamic> endPoint,
  }) : super.withoutEndPoint() {
    this.controlPoint1 = THPositionPart.fromStringList(list: controlPoint1);
    this.controlPoint2 = THPositionPart.fromStringList(list: controlPoint2);
    this.endPoint = THPositionPart.fromStringList(list: endPoint);
  }

  @override
  THElementType get elementType => THElementType.bezierCurveLineSegment;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'controlPoint1': controlPoint1.toMap(),
      'controlPoint2': controlPoint2.toMap(),
      'endPoint': endPoint.toMap(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THBezierCurveLineSegment.fromMap(Map<String, dynamic> map) {
    return THBezierCurveLineSegment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      controlPoint1: THPositionPart.fromMap(map['controlPoint1']),
      controlPoint2: THPositionPart.fromMap(map['controlPoint2']),
      endPoint: THPositionPart.fromMap(map['endPoint']),
      optionsMap: LinkedHashMap<String, THCommandOption>.from(
        map['optionsMap']
            .map((key, value) => MapEntry(key, THCommandOption.fromMap(value))),
      ),
    );
  }

  factory THBezierCurveLineSegment.fromJson(String jsonString) {
    return THBezierCurveLineSegment.fromMap(jsonDecode(jsonString));
  }

  @override
  THBezierCurveLineSegment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    THPositionPart? controlPoint1,
    THPositionPart? controlPoint2,
    THPositionPart? endPoint,
    LinkedHashMap<String, THCommandOption>? optionsMap,
    bool makeSameLineCommentNull = false,
  }) {
    return THBezierCurveLineSegment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      controlPoint1: controlPoint1 ?? this.controlPoint1,
      controlPoint2: controlPoint2 ?? this.controlPoint2,
      endPoint: endPoint ?? this.endPoint,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THBezierCurveLineSegment other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.controlPoint1 == controlPoint1 &&
        other.controlPoint2 == controlPoint2 &&
        other.endPoint == endPoint &&
        const DeepCollectionEquality().equals(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        controlPoint1,
        controlPoint2,
        endPoint,
        optionsMap,
      );

  @override
  bool isSameClass(Object object) {
    return object is THBezierCurveLineSegment;
  }

  double get controlPoint1X {
    return controlPoint1.coordinates.dx;
  }

  double get controlPoint1Y {
    return controlPoint1.coordinates.dy;
  }

  int get controlPoint1DecimalPositions {
    return controlPoint1.decimalPositions;
  }

  set controlPoint1DecimalPositions(int decimalPositions) {
    controlPoint1.decimalPositions = decimalPositions;
  }

  double get controlPoint2X {
    return controlPoint2.coordinates.dx;
  }

  double get controlPoint2Y {
    return controlPoint2.coordinates.dy;
  }

  int get controlPoint2DecimalPositions {
    return controlPoint2.decimalPositions;
  }

  set controlPoint2DecimalPositions(int decimalPositions) {
    controlPoint2.decimalPositions = decimalPositions;
  }

  @override
  Rect _calculateBoundingBox(Offset startPoint) {
    final List<Offset> points = [
      startPoint,
      controlPoint1.coordinates,
      controlPoint2.coordinates,
      endPoint.coordinates,
    ];

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final Offset point in points) {
      if (point.dx < minX) {
        minX = point.dx;
      }
      if (point.dx > maxX) {
        maxX = point.dx;
      }
      if (point.dy < minY) {
        minY = point.dy;
      }
      if (point.dy > maxY) {
        maxY = point.dy;
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
