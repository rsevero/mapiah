import 'dart:math' as math;
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';
import 'package:mapiah/src/auxiliary/mp_fit_cubic_schneider.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_bezier_to_bezier.dart';
import 'package:mapiah/src/elements/th_element.dart';

List<THLineSegment> mpConvertTHStraightToTHBezierLineSegments({
  required List<THLineSegment> originalStraightLineSegmentsList,
  required double accuracy,
  required int decimalPositions,
}) {
  final List<MPFitPoint> points = originalStraightLineSegmentsList
      .map(
        (seg) => MPFitPoint(
          seg.endPoint.coordinates.dx,
          seg.endPoint.coordinates.dy,
          lineSegment: seg,
        ),
      )
      .toList();

  if (points.isEmpty) {
    return [];
  }

  List<MPCubicBez> cubicBezs = mpFitCubicSchneider(
    points,
    errorSquared: accuracy * accuracy,
  );

  cubicBezs = _mpClampStraightToBezierTangents(cubicBezs);

  final List<THLineSegment> lineSegmentsList =
      mpConvertCubicBezToTHBezierLineSegments(
        cubicBezs: cubicBezs,
        originalLineSegmentsList: originalStraightLineSegmentsList,
        decimalPositionsForCalculatedValues: decimalPositions,
      );

  return lineSegmentsList;
}

/// Adjust control handles for a chain of cubic Beziers derived from a
/// polyline so that the resulting Béziers follow the polyline without
/// introducing large, misaligned handles that create spurious S-shaped
/// curvature.
///
/// Behaviour summary:
/// - Keeps all anchor points (each cubic's `p0` and `p3`) unchanged.
/// - Recomputes each cubic's interior control points (`p1` and `p2`) from a
///   stabilized tangent field estimated at the anchors (Catmull–Rom style).
/// - Clamps the tangent projection along the chord and limits perpendicular
///   magnitude to avoid overshoot.
///
/// Parameters:
/// - `cubics`: input list of cubic segments (must share anchors end-to-end).
/// - `tension`: Catmull–Rom tension factor (0..1) used when estimating
///   tangents from neighbouring anchors.
/// - `maxHandleFactor`: maximum allowed handle length as a fraction of the
///   chord length (e.g. 0.75 means handle ≤ 0.75 * chordLen).
/// - `maxPerpendicularRatio`: fraction of the along-chord handle allowed for
///   the perpendicular component (keeps handles aligned with the chord).
List<MPCubicBez> _mpClampStraightToBezierTangents(
  List<MPCubicBez> cubics, {
  double tension = 0.75,
  double maxHandleFactor = 0.75,
  double maxPerpendicularRatio = 0.5,
}) {
  if (cubics.length <= 1) {
    return cubics;
  }

  final List<MPFitPoint> anchors = <MPFitPoint>[
    cubics.first.p0,
    ...cubics.map((c) => c.p3),
  ];

  final List<MPVec2> tangents = List.generate(
    anchors.length,
    (int i) => _catmullRomTangent(anchors, i, tension),
  );

  final List<MPCubicBez> adjusted = <MPCubicBez>[];

  for (int i = 0; i < cubics.length; i++) {
    final MPCubicBez cubic = cubics[i];
    final MPFitPoint p0 = cubic.p0;
    final MPFitPoint p3 = cubic.p3;
    final MPVec2 chord = p3 - p0;
    final double chordLen = chord.hypot();

    if (chordLen <= 0) {
      adjusted.add(cubic);
      continue;
    }

    final MPVec2 chordDir = chord / chordLen;
    final MPVec2 startTan = _clampTangentToChord(
      tangents[i],
      chordDir,
      chordLen,
      maxHandleFactor,
      maxPerpendicularRatio,
    );
    final MPVec2 endForward = _clampTangentToChord(
      tangents[i + 1],
      chordDir,
      chordLen,
      maxHandleFactor,
      maxPerpendicularRatio,
    );
    final MPVec2 endTan = -endForward;

    final MPFitPoint cp1 = p0 + (startTan / 3.0);
    final MPFitPoint cp2 = p3 + (endTan / 3.0);

    adjusted.add(cubic.copyWith(p1: cp1, p2: cp2, isCalculated: true));
  }

  return adjusted;
}

/// Compute a Catmull–Rom-style tangent vector for the anchor at `index`.
///
/// For interior anchors we use the symmetric difference
///   0.5 * (anchors[i+1] - anchors[i-1]) * tension
/// For the first/last anchor we use a one-sided difference scaled by
/// `tension`. Returns a vector in world units (same units as anchors).
MPVec2 _catmullRomTangent(List<MPFitPoint> anchors, int index, double tension) {
  final int last = anchors.length - 1;

  if (anchors.length <= 1) {
    return const MPVec2(0, 0);
  }

  if (index == 0) {
    return (anchors[1] - anchors[0]) * tension;
  }

  if (index == last) {
    return (anchors[last] - anchors[last - 1]) * tension;
  }

  final MPVec2 forward = anchors[index + 1] - anchors[index - 1];

  return forward * 0.5 * tension;
}

/// Clamp a tangent vector to the local chord basis to avoid overshoot.
///
/// The function projects `tangent` onto `chordDir` and clamps the along-chord
/// magnitude to at most `chordLen * maxHandleFactor`. The perpendicular
/// component is limited to `clampedAlong * maxPerpendicularRatio` so handles
/// remain reasonably aligned with the chord. If the along-chord projection is
/// non-positive the result is the zero vector (prevents handle reversal).
MPVec2 _clampTangentToChord(
  MPVec2 tangent,
  MPVec2 chordDir,
  double chordLen,
  double maxHandleFactor,
  double maxPerpendicularRatio,
) {
  if (chordLen <= 0 || tangent.hypot2() == 0 || chordDir.hypot2() == 0) {
    return const MPVec2(0, 0);
  }

  final double along = tangent.dot(chordDir);

  if (along <= 0) {
    return const MPVec2(0, 0);
  }

  final double maxAlong = chordLen * maxHandleFactor;
  final double clampedAlong = math.min(along, maxAlong);
  final MPVec2 alongVec = chordDir * clampedAlong;

  final MPVec2 perpVec = tangent - (chordDir * along);
  final double perpLen = perpVec.hypot();
  final double maxPerp = clampedAlong * maxPerpendicularRatio;

  MPVec2 finalPerp = const MPVec2(0, 0);

  if ((perpLen > 1e-9) && (maxPerp > 0)) {
    final double scale = math.min(1.0, maxPerp / perpLen);
    finalPerp = perpVec * scale;
  }

  return alongVec + finalPerp;
}
