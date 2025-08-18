import 'package:flutter/services.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';

class MPEditElementAux {
  static THBezierCurveLineSegment
  getBezierCurveLineSegmentFromStraightLineSegment({
    required Offset start,
    required THStraightLineSegment straightLineSegment,
    required int decimalPositions,
  }) {
    final Offset end = straightLineSegment.endPoint.coordinates;
    final double dxThird = (end.dx - start.dx) / 3;
    final double dyThird = (end.dy - start.dy) / 3;
    final Offset controlPoint1 = Offset(start.dx + dxThird, start.dy + dyThird);
    final Offset controlPoint2 = Offset(
      controlPoint1.dx + dxThird,
      controlPoint1.dy + dyThird,
    );

    return THBezierCurveLineSegment.forCWJM(
      mpID: straightLineSegment.mpID,
      parentMPID: straightLineSegment.parentMPID,
      endPoint: straightLineSegment.endPoint,
      controlPoint1: THPositionPart(
        coordinates: controlPoint1,
        decimalPositions: decimalPositions,
      ),
      controlPoint2: THPositionPart(
        coordinates: controlPoint2,
        decimalPositions: decimalPositions,
      ),
      optionsMap: straightLineSegment.optionsMap,
      attrOptionsMap: straightLineSegment.attrOptionsMap,
      originalLineInTH2File: '',
    );
  }

  static bool isEndPoint(MPEndControlPointType type) {
    return ((type == MPEndControlPointType.endPointStraight) ||
        (type == MPEndControlPointType.endPointBezierCurve));
  }

  static bool isControlPoint(MPEndControlPointType type) {
    return ((type == MPEndControlPointType.controlPoint1) ||
        (type == MPEndControlPointType.controlPoint2));
  }

  static Offset? moveMirrorControlPoint(
    MPMoveControlPointSmoothInfo moveControlPointSmoothInfo,
    Offset point,
  ) {
    final Offset junction = moveControlPointSmoothInfo.junction!;
    final Offset newDirectionVector = point - junction;
    final double newDirectionVectorDistance = newDirectionVector.distance;

    if (newDirectionVectorDistance == 0) {
      return null;
    }

    final Offset newUnitDirection = Offset(
      newDirectionVector.dx / newDirectionVectorDistance,
      newDirectionVector.dy / newDirectionVectorDistance,
    );
    final double currentLength =
        moveControlPointSmoothInfo.adjacentControlPointLength!;
    final Offset newAdjacentControlPointPosition =
        junction - newUnitDirection * currentLength;

    return newAdjacentControlPointPosition;
  }

  static Offset moveControlPointInLine(
    MPMoveControlPointSmoothInfo moveControlPointSmoothInfo,
    Offset point,
  ) {
    final Offset start = moveControlPointSmoothInfo.straightStart!;
    final Offset junction = moveControlPointSmoothInfo.junction!;
    final Offset line = moveControlPointSmoothInfo.straightLine!;
    final Offset toPoint = point - start;
    final double lineDx = line.dx;
    final double lineDy = line.dy;
    final double t =
        (toPoint.dx * lineDx + toPoint.dy * lineDy) /
        (lineDx * lineDx + lineDy * lineDy);
    final Offset newPosition = (t > 1.0) ? start + line * t : junction;

    return newPosition;
  }
}

class MPMoveControlPointSmoothInfo {
  final bool shouldSmooth;
  final bool? isAdjacentStraight;
  final THBezierCurveLineSegment? adjacentLineSegment;
  final THBezierCurveLineSegment lineSegment;
  final MPEndControlPointType controlPointType;
  final Offset? straightLine;
  final Offset? straightStart;
  final Offset? junction;
  final double? adjacentControlPointLength;

  MPMoveControlPointSmoothInfo({
    required this.shouldSmooth,
    this.isAdjacentStraight,
    this.adjacentLineSegment,
    required this.lineSegment,
    required this.controlPointType,
    this.straightLine,
    this.straightStart,
    this.junction,
    this.adjacentControlPointLength,
  }) {
    if (shouldSmooth) {
      assert(isAdjacentStraight != null);
      assert(junction != null);
      if (isAdjacentStraight!) {
        assert(straightLine != null);
        assert(straightStart != null);
      } else {
        assert(adjacentLineSegment != null);
        assert(adjacentControlPointLength != null);
      }
    }
  }
}
