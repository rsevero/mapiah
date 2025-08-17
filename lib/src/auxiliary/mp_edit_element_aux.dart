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

  static THBezierCurveLineSegment? moveMirrorControlPoint({
    required THBezierCurveLineSegment referenceLineSegment,
    required MPEndControlPointType controlPointType,
    THLineSegment? previousLineSegment,
  }) {
    return null;
  }

  static Offset moveControlPointInLine(
    MPMoveControlPointSmoothInfo moveControlPointSmoothInfo,
    Offset point,
  ) {
    final Offset start = moveControlPointSmoothInfo.straightStart!;
    final Offset end = moveControlPointSmoothInfo.straightEnd!;
    final Offset line = moveControlPointSmoothInfo.straightLine!;
    final Offset toPoint = point - start;
    final double t =
        (toPoint.dx * line.dx + toPoint.dy * line.dy) /
        (line.dx * line.dx + line.dy * line.dy);

    // If t > 1, the projection is beyond the end point; otherwise, place it at the end and extend in the line direction
    if (t > 1.0) {
      return start + line * t;
    } else {
      // Place the point beyond the end by the distance from end to point, in the line direction
      final double extend = (point - end).distance;
      final Offset direction = (line / line.distance);

      return end + direction * extend;
    }
  }
}

class MPMoveControlPointSmoothInfo {
  final bool isSmooth;
  final bool? isAdjacentStraight;
  final THBezierCurveLineSegment? adjacentLineSegment;
  final THBezierCurveLineSegment lineSegment;
  final MPEndControlPointType controlPointType;
  final Offset? straightLine;
  final Offset? straightStart;
  final Offset? straightEnd;

  MPMoveControlPointSmoothInfo({
    required this.isSmooth,
    this.isAdjacentStraight,
    this.adjacentLineSegment,
    required this.lineSegment,
    required this.controlPointType,
    this.straightLine,
    this.straightStart,
    this.straightEnd,
  }) {
    if (isSmooth) {
      assert(isAdjacentStraight != null);
      if (isAdjacentStraight!) {
        assert(straightLine != null);
        assert(straightStart != null);
        assert(straightEnd != null);
      } else {
        assert(adjacentLineSegment != null);
      }
    }
  }
}
