// Adapter: a source curve made of consecutive cubic Beziers
import 'dart:collection';
import 'dart:math' as math;
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// How to use the example
/// Build a list of connected cubics and call:
/// final result = simplifyCubicChain(myCubics, accuracy: 0.5);
/// Or, if you prefer the near-optimal approach, swap the call inside the function to fitToBezPathOpt.
class MPSimplificationCubicChainSource
    implements MPSimplificationParamCurveFit {
  final List<MPSimplificationCubicBez> curves;

  MPSimplificationCubicChainSource(this.curves) {
    if (curves.isEmpty) {
      throw ArgumentError('curves must not be empty');
    }
  }

  int get _n => curves.length;

  // Map global t∈[0,1] to segment index and local u∈[0,1]
  (int, double) _segForT(double t) {
    final double tt = t.clamp(0.0, 1.0);

    int i = (tt * _n).floor();
    if (i >= _n) {
      i = _n - 1;
    }

    final double u = tt * _n - i;

    return (i, u);
  }

  @override
  (MPSimplificationPoint, MPSimplificationVec2) samplePtDeriv(double t) {
    final (int i, double u) = _segForT(t);
    final MPSimplificationCubicBez c = curves[i];
    final MPSimplificationPoint p = c.eval(u);
    // Chain rule: dt over concatenated segments (equal share per segment)
    final MPSimplificationVec2 d = c.deriv(u) * _n.toDouble();

    return (p, d);
  }

  @override
  MPSimplificationCurveFitSample samplePtTangent(double t, double sign) {
    final (MPSimplificationPoint p, MPSimplificationVec2 d0) = samplePtDeriv(t);

    MPSimplificationVec2 d = d0;
    // If near a cusp or join, peek slightly to the chosen side
    if (d.x * d.x + d.y * d.y < 1e-18) {
      final double eps = (sign >= 0 ? 1 : -1) * (1e-5 / _n);
      final double tp = (t + eps).clamp(0.0, 1.0);

      d = samplePtDeriv(tp).$2;
    }

    return MPSimplificationCurveFitSample(p, d);
  }

  @override
  double? breakCusp(MPSimplificationRange range) {
    // Always break only at actual cusps (sharp direction change), not at every join.
    for (int i = 1; i < _n; i++) {
      final double b = i / _n;

      if (b <= range.start || b >= range.end) {
        continue;
      }
      if (_isCuspAtJoin(i)) {
        return b;
      }
    }

    return null;
  }

  // Heuristic cusp detector at the join between curves[i-1] and curves[i].
  // Returns true when the tangent direction changes acutely (angle > threshold).
  bool _isCuspAtJoin(int i) {
    final MPSimplificationCubicBez prev = curves[i - 1];
    final MPSimplificationCubicBez next = curves[i];

    // Tangents at the boundary
    MPSimplificationVec2 t1 = prev.deriv(1.0);
    MPSimplificationVec2 t2 = next.deriv(0.0);

    const double eps = 1e-12;
    // If derivative nearly zero at the junction (rare), peek slightly inside
    if (t1.hypot() < eps) {
      t1 = prev.deriv(1.0 - 1e-5);
    }
    if (t2.hypot() < eps) {
      t2 = next.deriv(1e-5);
    }

    final double n1 = t1.hypot();
    final double n2 = t2.hypot();

    if ((n1 < eps) || (n2 < eps)) {
      return false; // can't classify, assume no cusp
    }

    final double dot = (t1.dot(t2)) / (n1 * n2);
    final double clamped = dot.clamp(-1.0, 1.0);
    final double angle = math.acos(clamped);

    // Threshold: treat as cusp when turn exceeds 60 degrees.
    const double cuspAngleThreshold = mp60DegreeInRad;

    return angle > cuspAngleThreshold;
  }

  // Provide moment integrals (area and first moments) using quadrature,
  // matching the default in ParamCurveFit.
  @override
  (double, double, double) momentIntegrals(MPSimplificationRange range) {
    final double t0 = 0.5 * (range.start + range.end);
    final dt = 0.5 * (range.end - range.start);

    double a = 0, x = 0, y = 0;

    for (final (double w, double xi) in gaussLegendre16) {
      final double t = t0 + xi * dt;
      final (MPSimplificationPoint p, MPSimplificationVec2 d) = samplePtDeriv(
        t,
      );
      final double ai = w * d.x * p.y;

      a += ai;
      x += p.x * ai;
      y += p.y * ai;
    }

    return (a * dt, x * dt, y * dt);
  }
}

List<MPSimplificationCubicBez> mpSimplifyCubicChain(
  List<MPSimplificationCubicBez> chain, {
  double accuracy = mpLineSimplifyEpsilonOnScreen,
}) {
  // Merge-only simplification: never split original segments; only merge
  // consecutive segments when a single cubic fits the span within accuracy.
  // This guarantees the output segment count is <= input.
  if (chain.length <= 1) {
    return List<MPSimplificationCubicBez>.from(chain);
  }

  final MPSimplificationCubicChainSource source =
      MPSimplificationCubicChainSource(chain);
  final int n = chain.length;

  // Precompute cusp boundaries (indices between segments where merging is forbidden).
  final Set<int> cuspBoundaries = <int>{};

  for (int i = 1; i < n; i++) {
    if (source._isCuspAtJoin(i)) {
      cuspBoundaries.add(i);
    }
  }

  final List<MPSimplificationCubicBez> out = <MPSimplificationCubicBez>[];

  int i = 0;

  while (i < n) {
    // We can try to merge from segment i up to just before the next cusp boundary.
    int hardEnd = n;

    for (int k = i + 1; k < n; k++) {
      if (cuspBoundaries.contains(k)) {
        hardEnd = k; // can't cross this boundary
        break;
      }
    }

    // Prefer longest-possible merge first: try [i, j) from hardEnd down to i+2.
    // This remains merge-only (never splits) and improves reduction odds vs. early break.
    MPSimplificationCubicBez? merged;
    int nextI = i + 1; // default advance if no merge found

    for (int j = hardEnd; j >= i + 2; j--) {
      final double t0 = i / n;
      final double t1 = j / n;
      final (MPSimplificationCubicBez, double)? fit =
          mpSimplificationFitToCubic(
            source,
            MPSimplificationRange(t0, t1),
            accuracy,
          );

      if (fit != null) {
        merged = fit.$1.copyWith(lineSegment: chain[j - 1].lineSegment);
        nextI = j; // consume [i, j)
        break; // take the longest successful span
      }
    }

    if (merged != null) {
      out.add(merged);
      i = nextI;
    } else {
      // No merge possible; keep the original segment exactly.
      out.add(chain[i]);
      i += 1;
    }
  }

  return out;
}

// Note: cusp detection is implemented once in CubicChainSource._isCuspAtJoin.

List<THLineSegment>
mpSimplifyTHBezierCurveLineSegmentsToTHBezierCurveLineSegments(
  List<THLineSegment> originalLineSegmentsList, {
  double accuracy = mpLineSimplifyEpsilonOnScreen,
  required int decimalPositions,
}) {
  final List<MPSimplificationCubicBez> asCubicBez =
      mpConvertTHBeziersToCubicsBez(originalLineSegmentsList);
  final List<MPSimplificationCubicBez> fittedCubics = mpSimplifyCubicChain(
    asCubicBez,
    accuracy: accuracy,
  );

  // print("Original segments: ${originalLineSegmentsList.length}");
  // print("asCubicBez segments: ${asCubicBez.length}");
  // print("Fitted cubics: ${fittedCubics.length}");

  // Invariant: merge-only simplifier guarantees non-increase.
  assert(
    fittedCubics.length <= asCubicBez.length,
    'Simplifier must not increase segment count',
  );
  if (fittedCubics.length == asCubicBez.length) {
    // No effective simplification; keep original for stability.
    return originalLineSegmentsList;
  }

  if (fittedCubics.isEmpty) {
    throw Exception(
      'Error: fittedCubics.isEmpty at TH2FileEditElementEditController.simplifySelectedLines(). Length: ${fittedCubics.length}',
    );
  }

  final List<THLineSegment> simplifiedLineSegmentsList =
      mpConvertCubicBezsToTHBezierCurveLineSegments(
        cubicBezs: fittedCubics,
        originalLineSegmentsList: originalLineSegmentsList,
        decimalPositionsForCalculatedValues: decimalPositions,
      );

  return simplifiedLineSegmentsList;
}

List<THLineSegment> mpConvertCubicBezsToTHBezierCurveLineSegments({
  required List<MPSimplificationCubicBez> cubicBezs,
  required List<THLineSegment> originalLineSegmentsList,
  required int decimalPositionsForCalculatedValues,
}) {
  final List<THLineSegment> lineSegmentsList = [];
  final THLineSegment firstOriginalLineSegment = originalLineSegmentsList.first;
  final int parentMPID = firstOriginalLineSegment.parentMPID;
  final THStraightLineSegment firstFittedLineSegment =
      firstOriginalLineSegment is THStraightLineSegment
      ? firstOriginalLineSegment
      : THStraightLineSegment(
          parentMPID: parentMPID,
          endPoint: firstOriginalLineSegment.endPoint,
          optionsMap: firstOriginalLineSegment.optionsMap,
          attrOptionsMap: firstOriginalLineSegment.attrOptionsMap,
        );

  lineSegmentsList.add(firstFittedLineSegment);

  for (final MPSimplificationCubicBez fittedCubic in cubicBezs) {
    final THPositionPart controlPoint1;
    final THPositionPart controlPoint2;
    final THPositionPart endPoint;
    final SplayTreeMap<THCommandOptionType, THCommandOption>? optionsMap;
    final SplayTreeMap<String, THAttrCommandOption>? attrOptionsMap;

    if (fittedCubic.isCalculated ||
        (fittedCubic.p1.lineSegment == null) ||
        (fittedCubic.p1.lineSegment! is! THBezierCurveLineSegment)) {
      controlPoint1 = THPositionPart(
        coordinates: fittedCubic.p1.toOffset(),
        decimalPositions: decimalPositionsForCalculatedValues,
      );
    } else {
      final THBezierCurveLineSegment originalLineSegment =
          fittedCubic.p1.lineSegment! as THBezierCurveLineSegment;

      controlPoint1 = originalLineSegment.controlPoint1;
    }

    if (fittedCubic.isCalculated ||
        (fittedCubic.p2.lineSegment == null) ||
        (fittedCubic.p2.lineSegment! is! THBezierCurveLineSegment)) {
      controlPoint2 = THPositionPart(
        coordinates: fittedCubic.p2.toOffset(),
        decimalPositions: decimalPositionsForCalculatedValues,
      );
    } else {
      final THBezierCurveLineSegment originalLineSegment =
          fittedCubic.p2.lineSegment! as THBezierCurveLineSegment;

      controlPoint2 = originalLineSegment.controlPoint2;
    }

    if (fittedCubic.lineSegment == null) {
      endPoint = THPositionPart(
        coordinates: fittedCubic.p3.toOffset(),
        decimalPositions: decimalPositionsForCalculatedValues,
      );
      optionsMap = null;
      attrOptionsMap = null;
    } else {
      final THLineSegment originalLineSegment = fittedCubic.lineSegment!;

      endPoint = originalLineSegment.endPoint;
      optionsMap = originalLineSegment.optionsMap;
      attrOptionsMap = originalLineSegment.attrOptionsMap;
    }

    final THBezierCurveLineSegment fittedLineSegment = THBezierCurveLineSegment(
      parentMPID: parentMPID,
      controlPoint1: controlPoint1,
      controlPoint2: controlPoint2,
      endPoint: endPoint,
      optionsMap: optionsMap,
      attrOptionsMap: attrOptionsMap,
    );

    lineSegmentsList.add(fittedLineSegment);
  }

  return lineSegmentsList;
}
