import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_bezier_curve.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_segment.dart';
import 'package:mapiah/src/auxiliary/mp_straight_segment.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

class MPNumericAux {
  static RegExp endingZeroes = RegExp(r'0*$');
  static RegExp endingDot = RegExp(r'\.$');

  // Adapted from https://github.com/Ephenodrom/Dart-Basic-Utils/blob/master/lib/src/MathUtils.dart
  static double round(double value, int decimals) {
    final double magnitude = math.pow(10.0, decimals).toDouble();

    return (value * magnitude).round() / magnitude;
  }

  static int getMinimumNumberOfDecimals(double value) {
    String valueString = value.toStringAsFixed(mpMaxDecimalPositions);

    valueString = removeTrailingZeros(valueString);

    return valueString.contains('.') ? valueString.split('.')[1].length : 0;
  }

  /// Robust floating-point comparison adapted from the C++ implementation
  /// available at https://stackoverflow.com/a/32334103
  ///
  /// Returns true when `a` and `b` are nearly equal taking into account
  /// a relative epsilon and an absolute threshold. Defaults use float64
  /// tolerances (so behaviour is not similar to the original C++ code).
  ///
  /// The defaults use double precision tolerances: epsilon = 128 * DBL_EPSILON,
  /// absTh = DBL_MIN.
  static bool nearlyEqual(
    double a,
    double b, {
    double epsilon = 128 * mpDoubleNextEpsilon, // 128 * DBL_EPSILON
    double absTh = mpDoubleMinNormalized, // DBL_MIN (normalized)
  }) {
    // sanity checks similar to the C++ asserts
    assert(epsilon >= mpDoubleNextEpsilon);
    assert(epsilon < 1.0);

    // NaNs are never equal
    if (a.isNaN || b.isNaN) {
      return false;
    }

    // Fast path for exact equality (covers infinities of same sign too)
    if (a == b) {
      return true;
    }

    // If either is infinite (and they aren't equal above) they are not nearly equal
    if (a.isInfinite || b.isInfinite) {
      return false;
    }

    final double diff = (a - b).abs();
    final double norm = math.min((a.abs() + b.abs()), double.maxFinite);

    return diff < math.max(absTh, epsilon * norm);
  }

  static THDoublePart fromString(String valueString) {
    valueString = valueString.trim();

    final double? doubleValue = double.tryParse(valueString);
    if (doubleValue == null) {
      throw THConvertFromStringException(
        'THDoublePart fromString',
        valueString,
      );
    }
    final double value = doubleValue;

    final int dotPosition = valueString.indexOf(thDecimalSeparator);
    final int decimalPositions = (dotPosition > 0)
        ? valueString.length - (dotPosition + 1)
        : 0;

    return THDoublePart(value: value, decimalPositions: decimalPositions);
  }

  static String doubleToString(double value, int decimalPositions) {
    /// Adapted from https://stackoverflow.com/a/67497099/11754455
    if (decimalPositions > 0) {
      if (value < 0) {
        value = nextDown(value);
      } else {
        value = nextUp(value);
      }
    }

    final String valueString = value.toStringAsFixed(decimalPositions);

    return removeTrailingZeros(valueString);
  }

  static String removeTrailingZeros(String valueString) {
    if (valueString.contains('.')) {
      // Remove trailing zeros
      valueString = valueString.replaceAll(endingZeroes, '');
      // Remove the decimal point if it is the last character
      valueString = valueString.replaceAll(endingDot, '');
    }

    return valueString;
  }

  static bool isRect1InsideRect2({required Rect rect1, required Rect rect2}) {
    return rect2.contains(rect1.topLeft) && rect2.contains(rect1.bottomRight);
  }

  static bool rectContainsPointInclusive({
    required Rect rect,
    required Offset point,
  }) {
    final Rect orderedRect = orderedRectFromRect(rect);

    return (point.dx >= orderedRect.left) &&
        (point.dx <= orderedRect.right) &&
        (point.dy >= orderedRect.top) &&
        (point.dy <= orderedRect.bottom);
  }

  /// In Flutter, the Rect.fromLTRB() method does not check if the left is
  /// greater than the right or if the top is greater than the bottom so I am
  /// providing this method to ensure that the Rect is ordered.
  ///
  /// The problem is that for Flutter:
  ///  bool get isEmpty => left >= right || top >= bottom;
  /// for a Rect.
  ///
  /// If you are not paying attention, let me repeat it: for Flutter if the TOP
  /// of a Rect is GREATER than the BOTTOM, the Rect is EMPTY!!
  ///
  /// All created Rects in Mapiah should be ordered according to Flutter
  /// expectations.
  ///
  /// /// For more details, see the Flutter documentation:
  /// [Flutter Rect Documentation](https://main-api.flutter.dev/flutter/dart-ui/Rect/isEmpty.html)
  static Rect orderedRectFromLTRB({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) {
    double rectLeft = left;
    double rectTop = top;
    double rectRight = right;
    double rectBottom = bottom;

    if (rectLeft > rectRight) {
      rectLeft = right;
      rectRight = left;
    } else if (rectLeft == rectRight) {
      rectLeft = nextDown(rectLeft);
      rectRight = nextUp(rectRight);
    }

    if (rectTop > rectBottom) {
      rectTop = bottom;
      rectBottom = top;
    } else if (rectTop == rectBottom) {
      rectTop = nextDown(rectTop);
      rectBottom = nextUp(rectBottom);
    }

    return Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
  }

  static Rect orderedRectFromRect(Rect rect) {
    return orderedRectFromLTRB(
      left: rect.left,
      top: rect.top,
      right: rect.right,
      bottom: rect.bottom,
    );
  }

  /// In Flutter, the Rect.fromLTWH() method does not check if the width is
  /// negative or if the height is negative so I am providing this method to
  /// ensure that the Rect is ordered according to Flutter expectations.
  static Rect orderedRectFromLTWH({
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    return orderedRectFromLTRB(
      left: left,
      top: top,
      right: left + width,
      bottom: top + height,
    );
  }

  static Rect orderedRectSmallestAroundPoint({required Offset center}) {
    return orderedRectFromLTRB(
      left: nextDown(center.dx),
      top: nextDown(center.dy),
      right: nextUp(center.dx),
      bottom: nextUp(center.dy),
    );
  }

  /// In Flutter, the Rect.fromCenter() method does not check if the width or
  /// the height is negative so I am providing this method to ensure that the
  /// Rect is ordered according to Flutter expectations.
  static Rect orderedRectFromCenter({
    required Offset center,
    required double width,
    required double height,
  }) {
    final double left = center.dx - width / 2;
    final double top = center.dy - height / 2;
    final double right = center.dx + width / 2;
    final double bottom = center.dy + height / 2;

    return orderedRectFromLTRB(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  static Rect orderedRectFromCenterHalfLength({
    required Offset center,
    required double halfWidth,
    required double halfHeight,
  }) {
    final double left = center.dx - halfWidth;
    final double top = center.dy - halfHeight;
    final double right = center.dx + halfWidth;
    final double bottom = center.dy + halfHeight;

    return orderedRectFromLTRB(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// In Flutter, the Rect.fromCircle() method does not check if the radius is
  /// negative so I am providing this method to ensure that the Rect is ordered
  /// according to Flutter expectations.
  static Rect orderedRectFromCircle({
    required Offset center,
    required double radius,
  }) {
    final double left = center.dx - radius;
    final double top = center.dy - radius;
    final double right = center.dx + radius;
    final double bottom = center.dy + radius;

    return orderedRectFromLTRB(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// In Flutter, the Rect.fromPoints() method is the only method that actually
  /// checks if the points are ordered correctly but I am providing this method
  /// anyway for consistency: always create Rect through MPNUmeric methods.
  static Rect orderedRectFromPoints({
    required Offset point1,
    required Offset point2,
  }) {
    return orderedRectFromLTRB(
      left: point1.dx,
      top: point1.dy,
      right: point2.dx,
      bottom: point2.dy,
    );
  }

  static Rect orderedRectExpandedByDelta({
    required Rect rect,
    required double delta,
  }) {
    return orderedRectFromLTRB(
      left: rect.left - delta,
      top: rect.top - delta,
      right: rect.right + delta,
      bottom: rect.bottom + delta,
    );
  }

  static Rect orderedRectExpandedToIncludeOffset({
    required Rect rect,
    required Offset offset,
  }) {
    return orderedRectFromLTRB(
      left: math.min(rect.left, offset.dx),
      top: math.min(rect.top, offset.dy),
      right: math.max(rect.right, offset.dx),
      bottom: math.max(rect.bottom, offset.dy),
    );
  }

  /// Base 10 logarithm of x.
  static double log10(double x) {
    return math.log(x) / mpLogN10;
  }

  static double roundScale(double scale) {
    final double scaleMagnitude = (log10(scale) - 2).floorToDouble();
    final double scaleQuanta = math.pow(10, scaleMagnitude) as double;
    final double rounded =
        floorTo(value: scale / scaleQuanta, factor: thCanvasRoundFactor) *
        scaleQuanta;

    return rounded;
  }

  static String roundScaleAsTextPercentage(double scale) {
    final double scaleMagnitude = log10(scale);
    final double scaleMagnitudeInt = scaleMagnitude.floorToDouble();
    final double roundTo = math.pow(10, scaleMagnitudeInt - 2) as double;
    final double scaleInt = roundToFives(scale / roundTo) * roundTo * 100;
    final int fractionalDigits = (scaleMagnitude >= 0)
        ? 0
        : scaleMagnitude.abs().floor();
    return "${scaleInt.toStringAsFixed(fractionalDigits)}%";
  }

  static double roundNumber(double value) {
    final double valueMagnitude = (log10(value) - 1).floorToDouble();
    final double valueQuanta = math.pow(10, valueMagnitude) as double;
    final double rounded = roundToFives(value / valueQuanta) * valueQuanta;

    return rounded;
  }

  static String roundNumberForScreen(double value) {
    final double rounded = roundNumber(value);
    final double valueMagnitude = (log10(value) - 1).floorToDouble();
    final int fractionalDigits = (valueMagnitude >= 0)
        ? 0
        : valueMagnitude.abs().floor();
    String asString = rounded.toStringAsFixed(fractionalDigits);

    if (fractionalDigits > 0) {
      while (asString.endsWith('0')) {
        asString = asString.substring(0, asString.length - 1);
      }
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }

    return asString;
  }

  static double calculateQuanta(double initialMagnitude) {
    final double magnitudeFactorMin = initialMagnitude.floorToDouble();
    final double magnitudeFactorMax = initialMagnitude.ceilToDouble();
    final double magnitudeFactor =
        ((initialMagnitude - magnitudeFactorMin).abs() > 0.5)
        ? magnitudeFactorMax
        : magnitudeFactorMin;
    final double finalQuanta = math.pow(10, magnitudeFactor) as double;

    return finalQuanta;
  }

  static double roundToFives(double value) {
    return (value / 5).round() * 5;
  }

  static double floorTo({required double value, required double factor}) {
    return (value / factor).floor() * factor;
  }

  static double calculateRoundToQuanta({
    required double scale,
    required double factor,
    required bool isIncrease,
  }) {
    double desiredChange = scale * (factor - 1);
    if (!isIncrease) {
      desiredChange /= factor;
    }

    final double magnitudeFactorRef = log10(desiredChange) - 1;
    final double quanta = calculateQuanta(magnitudeFactorRef);
    final double rounded = roundToFives(desiredChange / quanta) * quanta;

    return rounded > 0 ? rounded : 1;
  }

  static double roundChangedScale({
    required double scale,
    required double factor,
    required bool isIncrease,
  }) {
    final double roundToQuanta = calculateRoundToQuanta(
      scale: scale,
      factor: factor,
      isIncrease: isIncrease,
    );

    final int roundFactor = (scale / roundToQuanta).round();

    return roundFactor * roundToQuanta;
  }

  static double calculateNextZoomLevel({
    required double scale,
    required double factor,
    required bool isIncrease,
  }) {
    final double unroundedScale = isIncrease ? scale * factor : scale / factor;
    final double roundedScale = roundChangedScale(
      scale: unroundedScale,
      factor: factor,
      isIncrease: isIncrease,
    );

    return roundedScale;
  }

  static double lengthConversion({
    required double original,
    required THLengthUnitType originalUnit,
    required THLengthUnitType targetUnit,
  }) {
    if (originalUnit == targetUnit) {
      return original;
    }

    return original * lengthConversionFactors[originalUnit]![targetUnit]!;
  }

  static double distanceSquaredToLineSegment({
    required Offset point,
    required Offset segmentStart,
    required Offset segmentEnd,
  }) {
    final double abx = segmentEnd.dx - segmentStart.dx;
    final double aby = segmentEnd.dy - segmentStart.dy;
    final double ab2 = abx * abx + aby * aby;

    // Degenerate segment: distance to the endpoint
    if (ab2 == 0.0) {
      final double dx = point.dx - segmentStart.dx;
      final double dy = point.dy - segmentStart.dy;

      return dx * dx + dy * dy;
    }

    final double apx = point.dx - segmentStart.dx;
    final double apy = point.dy - segmentStart.dy;

    // Clamp projection t to [0,1]
    double t = (apx * abx + apy * aby) / ab2;
    if (t < 0.0) {
      t = 0.0;
    } else if (t > 1.0) {
      t = 1.0;
    }

    final double projx = segmentStart.dx + t * abx;
    final double projy = segmentStart.dy + t * aby;
    final double dx = point.dx - projx;
    final double dy = point.dy - projy;

    return dx * dx + dy * dy;
  }

  // Helper: test if cubic Bezier (p0,p1,p2,p3) is "flat enough".
  static bool isFlat(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double toleranceSquared,
  ) {
    // Precompute chord vector and its squared length once.
    final Offset ab = p3 - p0;
    final double abLen2 = ab.dx * ab.dx + ab.dy * ab.dy;

    // Degenerate chord: treat distances as to the single point p0.
    if (abLen2 == 0.0) {
      final Offset ap1 = p1 - p0;
      final Offset ap2 = p2 - p0;
      final double d1sq = ap1.dx * ap1.dx + ap1.dy * ap1.dy;
      final double d2sq = ap2.dx * ap2.dx + ap2.dy * ap2.dy;

      if ((d1sq > toleranceSquared) || (d2sq > toleranceSquared)) {
        return false;
      }
      // Projection check is irrelevant for zero-length chord.
      return true;
    }

    // Fast perpendicular distance checks to the infinite line through p0->p3.
    final Offset ap1 = p1 - p0;
    final double cross1 = ap1.dx * ab.dy - ap1.dy * ab.dx;
    final double d1sq = (cross1 * cross1) / abLen2;

    if (d1sq > toleranceSquared) {
      return false;
    }

    final Offset ap2 = p2 - p0;
    final double cross2 = ap2.dx * ab.dy - ap2.dy * ab.dx;
    final double d2sq = (cross2 * cross2) / abLen2;

    if (d2sq > toleranceSquared) {
      return false;
    }

    // Secondary projection range guard to avoid control points far beyond the
    // chord endpoints even with small perpendicular distances.
    const double projSlack = 0.05; // 5% slack beyond [0,1]
    final double t1 = (ap1.dx * ab.dx + ap1.dy * ab.dy) / abLen2;
    final double t2 = (ap2.dx * ab.dx + ap2.dy * ab.dy) / abLen2;
    final bool inRange1 = (t1 >= -projSlack) && (t1 <= 1.0 + projSlack);
    final bool inRange2 = (t2 >= -projSlack) && (t2 <= 1.0 + projSlack);

    return inRange1 && inRange2;
  }

  // Helper: flatten cubic into a list of end points (excluding the initial
  // p0, including final p3) so the caller can build straight segments from
  // successive points. Uses an explicit stack to avoid deep recursion.
  static List<Offset> flattenCubic(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double toleranceSquared,
  ) {
    final List<Offset> result = [];
    final List<List<Offset>> stack = [
      [p0, p1, p2, p3],
    ];

    while (stack.isNotEmpty) {
      final List<Offset> c = stack.removeLast();
      final Offset q0 = c[0], q1 = c[1], q2 = c[2], q3 = c[3];

      if (isFlat(q0, q1, q2, q3, toleranceSquared)) {
        // Accept this as a straight segment from q0 to q3; store the end.
        result.add(q3);
      } else {
        final (List<Offset> left, List<Offset> right) = splitBezierCurveOffsets(
          q0,
          q1,
          q2,
          q3,
          0.5,
        );

        // Process right later so left is emitted first (depth-first order).
        stack.add(right);
        stack.add(left);
      }
    }

    return result;
  }

  static bool isPointNearLineSegment({
    required Offset point,
    required Offset segmentStart,
    required Offset segmentEnd,
    required double toleranceSquared,
  }) {
    return distanceSquaredToLineSegment(
          point: point,
          segmentStart: segmentStart,
          segmentEnd: segmentEnd,
        ) <=
        toleranceSquared;
  }

  static bool isPointNearBezierCurve({
    required Offset point,
    required List<Offset> controlPoints,
    required double toleranceSquared,
    int numOfSegmentsToCreate = 10,
  }) {
    List<Offset> pointsOnCurve = [];

    for (int i = 0; i <= numOfSegmentsToCreate; i++) {
      pointsOnCurve.add(deCasteljau(controlPoints, i / numOfSegmentsToCreate));
    }

    for (int i = 0; i < pointsOnCurve.length - 1; i++) {
      if (isPointNearLineSegment(
        point: point,
        segmentStart: pointsOnCurve[i],
        segmentEnd: pointsOnCurve[i + 1],
        toleranceSquared: toleranceSquared,
      )) {
        return true;
      }
    }

    return false;
  }

  static double pointsDistance(Offset point1, Offset point2) {
    final double dx = point2.dx - point1.dx;
    final double dy = point2.dy - point1.dy;

    return math.sqrt(dx * dx + dy * dy);
  }

  static Offset lerp(Offset a, Offset b, double t) {
    return a + (b - a) * t;
  }

  static Offset deCasteljau(List<Offset> points, double t) {
    if (points.length == 1) {
      return points[0];
    }

    final List<Offset> innerLevelPoints = [];

    for (int i = 0; i < points.length - 1; i++) {
      innerLevelPoints.add(lerp(points[i], points[i + 1], t));
    }

    return deCasteljau(innerLevelPoints, t);
  }

  static double estimateBezierLength(List<Offset> controlPoints) {
    double length = 0;

    for (int i = 0; i < controlPoints.length - 1; i++) {
      length += (controlPoints[i + 1] - controlPoints[i]).distance;
    }

    return length;
  }

  static int calculateSegments(
    double estimatedLength,
    double desiredSegmentLength,
  ) {
    return (estimatedLength / desiredSegmentLength).ceil();
  }

  static double nextUp(double x) => nextUpReal(x);
  static double nextDown(double x) => nextDownReal(x);

  static double normalizeAngle(double angle) {
    angle = angle % 360;

    if (angle < 0) {
      angle += 360;
    }

    return angle;
  }

  static double directionOffsetToDegrees(Offset direction) {
    if (direction == Offset.zero) {
      return 0.0;
    }

    final double radians = math.atan2(direction.dx, -direction.dy);
    final double degrees = radians * mp1Radian;

    return normalizeAngle(degrees);
  }

  static double bezierArcLength(
    List<Offset> controlPoints,
    double t, {
    int steps = mpArcBezierLengthSteps,
  }) {
    double length = 0.0;
    Offset prev = controlPoints.first;
    for (int i = 1; i <= steps; i++) {
      double ti = t * i / steps;
      Offset pt = deCasteljau(controlPoints, ti);
      length += (pt - prev).distance;
      prev = pt;
    }
    return length;
  }

  static List<THBezierCurveLineSegment> splitBezierCurveAtPart({
    required Offset startPoint,
    required THBezierCurveLineSegment lineSegment,
    required double part,
  }) {
    final List<Offset> controlPoints = [
      startPoint,
      lineSegment.controlPoint1.coordinates,
      lineSegment.controlPoint2.coordinates,
      lineSegment.endPoint.coordinates,
    ];

    // Estimate total length
    final double totalLength = bezierArcLength(
      controlPoints,
      mpCompleteBezierArcT,
    );
    // Clamp requested part to [0,1]
    final double targetPart = part.clamp(0.0, 1.0);
    final double arcLengthTarget = totalLength * targetPart;

    // Fast paths
    if (targetPart <= 0.0) {
      return splitBezierCurveTHLineSegment(
        startPoint: startPoint,
        lineSegment: lineSegment,
        t: 0.0,
      );
    }
    if (targetPart >= 1.0) {
      return splitBezierCurveTHLineSegment(
        startPoint: startPoint,
        lineSegment: lineSegment,
        t: 1.0,
      );
    }

    double tLow = 0.0;
    double tHigh = 1.0;
    double tMid = targetPart;

    // Initialize lengths at the interval endpoints.
    double lenLow = 0.0;
    double lenHigh = totalLength;

    for (int i = 0; i < mpSplitBezierCurveAtHalfLengthIterations; i++) {
      if (lenHigh != lenLow) {
        // Regula falsi (false position) step
        tMid =
            tLow +
            (arcLengthTarget - lenLow) * (tHigh - tLow) / (lenHigh - lenLow);
        // If interpolation is out of bounds, fallback to midpoint
        if (!((tMid > tLow) && (tMid < tHigh))) {
          tMid = (tLow + tHigh) * 0.5;
        }
      } else {
        // Degenerate: fallback to midpoint
        tMid = (tLow + tHigh) * 0.5;
      }

      final double len = bezierArcLength(controlPoints, tMid);

      if (nearlyEqual(len, arcLengthTarget)) {
        break;
      }

      if (len < arcLengthTarget) {
        tLow = tMid;
        lenLow = len;
      } else {
        tHigh = tMid;
        lenHigh = len;
      }
    }

    // Now split at tMid
    return splitBezierCurveTHLineSegment(
      startPoint: startPoint,
      lineSegment: lineSegment,
      t: tMid,
    );
  }

  static List<THBezierCurveLineSegment> splitBezierCurveTHLineSegment({
    required Offset startPoint,
    required THBezierCurveLineSegment lineSegment,
    required double t,
  }) {
    final (List<Offset> left, List<Offset> right) = splitBezierCurveOffsets(
      startPoint,
      lineSegment.controlPoint1.coordinates,
      lineSegment.controlPoint2.coordinates,
      lineSegment.endPoint.coordinates,
      t,
    );

    final THBezierCurveLineSegment firstSegment = THBezierCurveLineSegment(
      parentMPID: lineSegment.parentMPID,
      controlPoint1: THPositionPart(coordinates: left[1]),
      controlPoint2: THPositionPart(coordinates: left[2]),
      endPoint: THPositionPart(coordinates: left[3]),
    );
    final THBezierCurveLineSegment secondSegment = lineSegment.copyWith(
      controlPoint1: THPositionPart(coordinates: right[1]),
      controlPoint2: THPositionPart(coordinates: right[2]),
      originalLineInTH2File: '',
    );

    return [firstSegment, secondSegment];
  }

  static (List<Offset> left, List<Offset> right) splitBezierCurveOffsets(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    // De Casteljau's algorithm
    final Offset q0 = Offset.lerp(p0, p1, t)!;
    final Offset q1 = Offset.lerp(p1, p2, t)!;
    final Offset q2 = Offset.lerp(p2, p3, t)!;

    final Offset r0 = Offset.lerp(q0, q1, t)!;
    final Offset r1 = Offset.lerp(q1, q2, t)!;

    final Offset s = Offset.lerp(r0, r1, t)!;

    final List<Offset> left = [p0, q0, r0, s];
    final List<Offset> right = [s, r1, q2, p3];

    return (left, right);
  }

  static Offset bezierCurveTangent(
    MPBezierCurve curve,
    MPExtremityType extremityType,
  ) {
    final Offset raw = switch (extremityType) {
      MPExtremityType.start => curve.c1 - curve.start,
      MPExtremityType.end => curve.end - curve.c2,
    };
    final double length = raw.distance;

    if (length == 0.0) {
      return Offset.zero;
    }

    return raw / length;
  }

  static Offset straightTangent(MPStraightSegment segment) {
    final Offset raw = segment.end - segment.start;
    final double length = raw.distance;

    if (length == 0.0) {
      return Offset.zero;
    }

    return raw / length;
  }

  static Offset anyTypeSegmentTangent(
    MPSegment segment,
    MPExtremityType extremityType,
  ) {
    if (segment is MPBezierCurve) {
      return bezierCurveTangent(segment as MPBezierCurve, extremityType);
    } else {
      return straightTangent(segment as MPStraightSegment);
    }
  }

  static Offset averageTangent(MPSegment first, MPSegment second) {
    final Offset firstTangent = (first is MPBezierCurve)
        ? bezierCurveTangent(first as MPBezierCurve, MPExtremityType.end)
        : straightTangent(first as MPStraightSegment);
    final Offset secondTangent = (second is MPBezierCurve)
        ? bezierCurveTangent(second as MPBezierCurve, MPExtremityType.start)
        : straightTangent(second as MPStraightSegment);
    final Offset average = firstTangent + secondTangent;
    final double length = average.distance;

    if (length == 0.0) {
      return Offset.zero;
    }

    return average / length;
  }

  static Offset segmentTangent(int lineSegmentMPID, THFile thFile) {
    final THLineSegment lineSegment = thFile.lineSegmentByMPID(lineSegmentMPID);
    final THLine line = thFile.lineByMPID(lineSegment.parentMPID);
    final Map<int, int> lineSegmentsPositionList = line
        .getLineSegmentPositionsByLineSegmentMPID(thFile);
    final int position = lineSegmentsPositionList[lineSegmentMPID]!;

    Offset tangent;

    if (position == 0) {
      final THLineSegment nextLineSegment = line.getNextLineSegment(
        lineSegment,
        thFile,
      )!;
      final MPSegment segment = (nextLineSegment is THBezierCurveLineSegment)
          ? MPCubicBezierCurve(
              start: lineSegment.endPoint.coordinates,
              c1: nextLineSegment.controlPoint1.coordinates,
              c2: nextLineSegment.controlPoint2.coordinates,
              end: nextLineSegment.endPoint.coordinates,
            )
          : MPStraightSegment(
              start: lineSegment.endPoint.coordinates,
              end: nextLineSegment.endPoint.coordinates,
            );

      tangent = MPNumericAux.anyTypeSegmentTangent(
        segment,
        MPExtremityType.start,
      );
    } else if (position == (lineSegmentsPositionList.length - 1)) {
      final THLineSegment previousLineSegment = line.getPreviousLineSegment(
        lineSegment,
        thFile,
      )!;
      final MPSegment segment = (lineSegment is THBezierCurveLineSegment)
          ? MPCubicBezierCurve(
              start: previousLineSegment.endPoint.coordinates,
              c1: lineSegment.controlPoint1.coordinates,
              c2: lineSegment.controlPoint2.coordinates,
              end: lineSegment.endPoint.coordinates,
            )
          : MPStraightSegment(
              start: previousLineSegment.endPoint.coordinates,
              end: lineSegment.endPoint.coordinates,
            );

      tangent = MPNumericAux.anyTypeSegmentTangent(
        segment,
        MPExtremityType.end,
      );
    } else {
      final THLineSegment previousLineSegment = line.getPreviousLineSegment(
        lineSegment,
        thFile,
      )!;
      final THLineSegment nextLineSegment = line.getNextLineSegment(
        lineSegment,
        thFile,
      )!;
      final MPSegment segment = (lineSegment is THBezierCurveLineSegment)
          ? MPCubicBezierCurve(
              start: previousLineSegment.endPoint.coordinates,
              c1: lineSegment.controlPoint1.coordinates,
              c2: lineSegment.controlPoint2.coordinates,
              end: lineSegment.endPoint.coordinates,
            )
          : MPStraightSegment(
              start: previousLineSegment.endPoint.coordinates,
              end: lineSegment.endPoint.coordinates,
            );
      final MPSegment nextSegment =
          (nextLineSegment is THBezierCurveLineSegment)
          ? MPCubicBezierCurve(
              start: lineSegment.endPoint.coordinates,
              c1: nextLineSegment.controlPoint1.coordinates,
              c2: nextLineSegment.controlPoint2.coordinates,
              end: nextLineSegment.endPoint.coordinates,
            )
          : MPStraightSegment(
              start: lineSegment.endPoint.coordinates,
              end: nextLineSegment.endPoint.coordinates,
            );

      tangent = MPNumericAux.averageTangent(segment, nextSegment);
    }

    if (MPCommandOptionAux.isReversed(line)) {
      tangent = -tangent;
    }

    return tangent;
  }

  static Offset normalFromTangent(Offset tangent, {bool clockwise = false}) {
    if (tangent == Offset.zero) {
      return Offset.zero;
    }

    final Offset rawNormal = clockwise
        ? Offset(tangent.dy, tangent.dx) // rotate +90°
        : Offset(-tangent.dy, -tangent.dx); // rotate -90°
    final double length = rawNormal.distance;

    if (length == 0.0) {
      return Offset.zero;
    }

    return rawNormal / length;
  }

  static double segmentNormal(int lineSegmentMPID, THFile thFile) {
    final Offset tangent = MPNumericAux.segmentTangent(lineSegmentMPID, thFile);
    final Offset normal = MPNumericAux.normalFromTangent(tangent);
    final double azimuth = MPNumericAux.directionOffsetToDegrees(normal);

    return azimuth;
  }

  static Rect boundingBoxFromOffsets(List<Offset> points) {
    if (points.isEmpty) {
      return Rect.zero;
    }

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (int i = 1; i < points.length; i++) {
      final Offset p = points[i];

      if (p.dx < minX) {
        minX = p.dx;
      }
      if (p.dx > maxX) {
        maxX = p.dx;
      }
      if (p.dy < minY) {
        minY = p.dy;
      }
      if (p.dy > maxY) {
        maxY = p.dy;
      }
    }

    return orderedRectFromLTRB(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }

  static double nextUpReal(double x) {
    if ((x.isNaN) || (x == double.infinity)) {
      return x;
    }

    if (x == double.negativeInfinity) {
      return -double.maxFinite;
    }

    if ((x == 0.0) || (x == -0.0)) {
      return double.minPositive;
    }

    if (x == -double.minPositive) {
      return 0.0;
    }

    // final int bits = _doubleToBits(x);
    // final int next = x > 0 ? bits + 1 : bits - 1;

    // return _bitsToDouble(next);

    return x + ulp(x);
  }

  static double nextDownReal(double x) {
    if ((x.isNaN) || (x == double.negativeInfinity)) {
      return x;
    }

    if (x == double.infinity) {
      return double.maxFinite;
    }

    if ((x == 0.0) || (x == -0.0)) {
      return -double.minPositive;
    }

    if (x == double.minPositive) {
      return 0.0;
    }

    // final int bits = _doubleToBits(x);
    // final int next = x > 0 ? bits - 1 : bits + 1;

    // return _bitsToDouble(next);

    return x - ulp(x);
  }

  static int _doubleToBits(double value) {
    final ByteData b = ByteData(8);

    b.setFloat64(0, value, Endian.big);

    return b.getUint64(0, Endian.big);
  }

  static double _bitsToDouble(int bits) {
    final ByteData b = ByteData(8);

    b.setUint64(0, bits, Endian.big);

    return b.getFloat64(0, Endian.big);
  }

  static double ulp(double d) {
    final int exp = _getExponent(d);

    // NaN or infinity
    if (exp == _doubleMaxExponent + 1) {
      return d.abs();
    }

    // zero or subnormal
    if (exp == _doubleMinExponent - 1) {
      return double.minPositive;
    }

    // normal numbers
    int e = exp - (_doubleSignificandWidth - 1);

    if (e >= _doubleMinExponent) {
      // 2^(e)
      return _powerOfTwo(e);
    } else {
      // subnormal result: shift the min subnormal left
      final int shift =
          e - (_doubleMinExponent - (_doubleSignificandWidth - 1));

      return _bitsToDouble(1 << shift);
    }
  }

  static const int _doubleSignificandWidth = 53; // includes implicit leading 1
  static const int _doubleExponentBias = 1023;
  static const int _doubleMaxExponent =
      1023; // unbiased max exponent for normal doubles
  static const int _doubleMinExponent =
      -1022; // unbiased min exponent for normal doubles

  static int _getExponent(double d) {
    final int bits = _doubleToBits(d);
    final int rawExp = (bits >> 52) & 0x7ff;

    if (rawExp == 0x7ff) {
      return _doubleMaxExponent + 1;
    } // NaN or infinity
    if (rawExp == 0) {
      return _doubleMinExponent - 1;
    } // zero or subnormal

    return rawExp - _doubleExponentBias; // unbiased exponent
  }

  static double _powerOfTwo(int exp) => math.pow(2.0, exp).toDouble();
}
