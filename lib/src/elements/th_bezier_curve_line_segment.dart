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

    return bezierBoundingBoxExtrema(points);
  }

  Rect bezierBoundingBoxExtrema(List<Offset> points) {
    if (points.isEmpty) {
      return Rect.zero;
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // Function to calculate a point on the Bezier curve at t
    Offset bezierPoint(double t) {
      // Cubic Bezier
      double u = 1 - t;
      double tt = t * t;
      double ttt = tt * t;
      double uu = u * u;
      double uuu = uu * u;
      return Offset(
        uuu * points[0].dx +
            3 * uu * t * points[1].dx +
            3 * u * tt * points[2].dx +
            ttt * points[3].dx,
        uuu * points[0].dy +
            3 * uu * t * points[1].dy +
            3 * u * tt * points[2].dy +
            ttt * points[3].dy,
      );
    }

    // Function to solve quadratic equation for t values
    List<double> solveQuadratic(double a, double b, double c) {
      double discriminant = b * b - 4 * a * c;
      if (discriminant < 0) return [];
      if (discriminant == 0) return [-b / (2 * a)];
      double sqrtDiscriminant = sqrt(discriminant);
      return [
        (-b + sqrtDiscriminant) / (2 * a),
        (-b - sqrtDiscriminant) / (2 * a)
      ];
    }

    final List<Offset> endPoints = [points.first, points.last];

    // Add start and end control points to the bounding box
    for (final p in endPoints) {
      minX = min(minX, p.dx);
      maxX = max(maxX, p.dx);
      minY = min(minY, p.dy);
      maxY = max(maxY, p.dy);
    }

    // Cubic Bezier: Calculate extrema
    double a = -3 * points[0].dx +
        9 * points[1].dx -
        9 * points[2].dx +
        3 * points[3].dx;
    double b = 6 * points[0].dx - 12 * points[1].dx + 6 * points[2].dx;
    double c = -3 * points[0].dx + 3 * points[1].dx;

    List<double> xt = solveQuadratic(a, b, c);

    a = -3 * points[0].dy +
        9 * points[1].dy -
        9 * points[2].dy +
        3 * points[3].dy;
    b = 6 * points[0].dy - 12 * points[1].dy + 6 * points[2].dy;
    c = -3 * points[0].dy + 3 * points[1].dy;

    List<double> yt = solveQuadratic(a, b, c);

    for (double t in xt) {
      if (t > 0 && t < 1) {
        Offset p = bezierPoint(t);
        minX = min(minX, p.dx);
        maxX = max(maxX, p.dx);
      }
    }
    for (double t in yt) {
      if (t > 0 && t < 1) {
        Offset p = bezierPoint(t);
        minY = min(minY, p.dy);
        maxY = max(maxY, p.dy);
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
