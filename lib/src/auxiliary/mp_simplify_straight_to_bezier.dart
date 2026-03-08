import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_bezier_to_bezier.dart';
import 'package:mapiah/src/auxiliary/mp_straight_line_simplification_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Converts straight line segments to smooth Bézier curves.
///
/// Pipeline:
/// 1. Compute adaptive tolerance from data geometry
/// 2. Douglas-Peucker to reduce polyline points within tolerance
/// 3. Catmull-Rom tangent estimation → cubic Bézier control points
///
/// The curve passes through all kept anchor points. Removed points are
/// guaranteed by Douglas-Peucker to be within tolerance of the simplified
/// polyline.
List<THLineSegment> mpConvertTHStraightToTHBezierLineSegments({
  required List<THLineSegment> originalStraightLineSegmentsList,
  required double accuracy,
  required int decimalPositions,
}) {
  if (originalStraightLineSegmentsList.length < 2) {
    return originalStraightLineSegmentsList;
  }

  final double fittingAccuracy = _computeFittingAccuracy(
    originalStraightLineSegmentsList,
    accuracy,
  );

  // 1. Reduce points via Douglas-Peucker.
  final List<THStraightLineSegment> reducedSegments =
      MPStraightLineSimplificationAux.raumerDouglasPeuckerIterative(
        originalStraightLineSegments: originalStraightLineSegmentsList,
        accuracy: fittingAccuracy,
      );

  // 2. Build anchor list from reduced points.
  final List<MPFitPoint> anchors = reducedSegments
      .map(
        (THStraightLineSegment seg) => MPFitPoint(
          seg.endPoint.coordinates.dx,
          seg.endPoint.coordinates.dy,
          lineSegment: seg,
        ),
      )
      .toList();

  if (anchors.length < 2) {
    return originalStraightLineSegmentsList;
  }

  // 3. Catmull-Rom tangents → cubic Bézier control points.
  final List<MPCubicBez> cubicBezs = _mpBuildCatmullRomBeziers(anchors);

  final List<THLineSegment> lineSegmentsList =
      mpConvertCubicBezToTHBezierLineSegments(
        cubicBezs: cubicBezs,
        originalLineSegmentsList: originalStraightLineSegmentsList,
        decimalPositionsForCalculatedValues: decimalPositions,
      );

  return lineSegmentsList;
}

/// Build cubic Bézier segments from anchor points using Catmull-Rom tangent
/// estimation for smooth, naturally curved control points.
List<MPCubicBez> _mpBuildCatmullRomBeziers(List<MPFitPoint> anchors) {
  final List<MPVec2> tangents = List.generate(
    anchors.length,
    (int i) => _catmullRomTangent(anchors, i),
  );

  final List<MPCubicBez> cubicBezs = <MPCubicBez>[];

  for (int i = 0; i < anchors.length - 1; i++) {
    final MPFitPoint p0 = anchors[i];
    final MPFitPoint p3 = anchors[i + 1];

    final MPFitPoint cp1 =
        p0 + (tangents[i] * mpCatmullRomToBezierHandleFactor);
    final MPFitPoint cp2 =
        p3 + (-(tangents[i + 1] * mpCatmullRomToBezierHandleFactor));

    cubicBezs.add(MPCubicBez(p0, cp1, cp2, p3, lineSegment: p3.lineSegment));
  }

  return cubicBezs;
}

/// Compute a Catmull-Rom tangent vector at the anchor point with the given
/// [index].
///
/// For interior anchors: the symmetric central difference scaled by 0.5.
/// For the first/last anchor: one-sided difference.
MPVec2 _catmullRomTangent(List<MPFitPoint> anchors, int index) {
  final int last = anchors.length - 1;

  if (anchors.length <= 1) {
    return const MPVec2(0, 0);
  }

  if (index == 0) {
    return anchors[1] - anchors[0];
  }

  if (index == last) {
    return anchors[last] - anchors[last - 1];
  }

  return (anchors[index + 1] - anchors[index - 1]) *
      mpCatmullRomInteriorTangentFactor;
}

/// Compute the effective fitting accuracy for the straight-to-Bézier
/// conversion. Uses the larger of [baseAccuracy] (screen-based) and a
/// fraction of the average segment length, so the tolerance scales with the
/// data's coordinate magnitude.
double _computeFittingAccuracy(
  List<THLineSegment> segments,
  double baseAccuracy,
) {
  if (segments.length < 2) {
    return baseAccuracy;
  }

  double totalArcLength = 0.0;

  for (int i = 1; i < segments.length; i++) {
    final Offset a = segments[i - 1].endPoint.coordinates;
    final Offset b = segments[i].endPoint.coordinates;
    final double dx = b.dx - a.dx;
    final double dy = b.dy - a.dy;

    totalArcLength += math.sqrt(dx * dx + dy * dy);
  }

  final double averageSegmentLength = totalArcLength / (segments.length - 1);
  final double adaptiveTolerance =
      averageSegmentLength * mpStraightToBezierFittingToleranceFraction;

  return math.max(baseAccuracy, adaptiveTolerance);
}
