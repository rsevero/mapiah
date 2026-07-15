// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_straight_line_simplification_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Pure capture and conversion helpers for the freehand line drawing tool.
///
/// Kept free of controller/state-machine dependencies so the sampling,
/// simplification and epsilon logic can be unit-tested in isolation from
/// pointer handling and command execution.
class MPFreehandLineAux {
  /// Whether [candidateScreenPosition] is at least
  /// [mpFreehandMinimumSampleSpacingOnScreen] logical pixels away from
  /// [lastAcceptedScreenPosition], and should therefore be accepted as a new
  /// freehand stroke sample. [sampleSpacingOnScreen] lets the caller pass an
  /// enlarged spacing after buffer compaction.
  static bool isSampleFarEnough({
    required Offset candidateScreenPosition,
    required Offset lastAcceptedScreenPosition,
    double sampleSpacingOnScreen = mpFreehandMinimumSampleSpacingOnScreen,
  }) {
    final double dx =
        candidateScreenPosition.dx - lastAcceptedScreenPosition.dx;
    final double dy =
        candidateScreenPosition.dy - lastAcceptedScreenPosition.dy;
    final double distanceSquared = dx * dx + dy * dy;

    return distanceSquared >= sampleSpacingOnScreen * sampleSpacingOnScreen;
  }

  /// Whether the straight-line distance between [firstScreenPosition] and
  /// [lastScreenPosition] reaches
  /// [mpFreehandMinimumCommittedStrokeLengthOnScreen]. A stroke shorter than
  /// this is treated as an accidental tap and creates nothing.
  static bool meetsMinimumCommittedStrokeLength({
    required Offset firstScreenPosition,
    required Offset lastScreenPosition,
  }) {
    final double dx = lastScreenPosition.dx - firstScreenPosition.dx;
    final double dy = lastScreenPosition.dy - firstScreenPosition.dy;
    final double distanceSquared = dx * dx + dy * dy;

    return distanceSquared >=
        mpFreehandMinimumCommittedStrokeLengthOnScreen *
            mpFreehandMinimumCommittedStrokeLengthOnScreen;
  }

  /// Compacts a sample buffer that reached [mpFreehandMaximumSampleCount]
  /// points, keeping the first point, every second interior point, and the
  /// latest point. The caller is responsible for doubling its active sample
  /// spacing afterwards. Buffers with two or fewer points are returned
  /// unchanged since there is nothing to compact.
  static List<Offset> compactSampleBuffer(List<Offset> samples) {
    if (samples.length <= 2) {
      return List<Offset>.of(samples);
    }

    final List<Offset> compacted = <Offset>[samples.first];

    for (int i = 1; i < samples.length - 1; i += 2) {
      compacted.add(samples[i]);
    }

    compacted.add(samples.last);

    return compacted;
  }

  /// Removes consecutive duplicate points from [points], preserving order.
  /// Covers both duplicate pointer samples and duplicates introduced by
  /// snapping the first/final points.
  static List<Offset> removeConsecutiveDuplicatePoints(List<Offset> points) {
    final List<Offset> result = <Offset>[];

    for (final Offset point in points) {
      if (result.isEmpty || result.last != point) {
        result.add(point);
      }
    }

    return result;
  }

  /// SexyTopo-style Douglas-Peucker epsilon, proportional to
  /// [rawBoundingBox]'s largest dimension with an absolute floor of
  /// [mpFreehandMinimumSimplificationEpsilon]. [rawBoundingBox] must be the
  /// raw, unsimplified stroke's bounding box maintained incrementally during
  /// capture, before any buffer compaction removes a point that established
  /// an extreme, so compaction cannot silently change the epsilon.
  ///
  /// Deliberately independent of zoom and pointer-event density; the
  /// divisor and floor constants intentionally match SexyTopo's
  /// `Space2DUtils`.
  static double computeSimplificationEpsilon(Rect rawBoundingBox) {
    final double maxDimension = math.max(
      rawBoundingBox.width,
      rawBoundingBox.height,
    );

    return math.max(
      maxDimension / mpFreehandSimplificationExtentDivisor,
      mpFreehandMinimumSimplificationEpsilon,
    );
  }

  /// Builds temporary [THStraightLineSegment] values for [canvasPoints]
  /// under [lineMPID], one per point (including the Therion move-to/start
  /// segment as element zero), using [decimalPositions] for every generated
  /// [THPositionPart].
  static List<THStraightLineSegment> buildStraightLineSegments({
    required List<Offset> canvasPoints,
    required int lineMPID,
    required int decimalPositions,
  }) {
    return canvasPoints
        .map(
          (Offset point) => THStraightLineSegment(
            parentMPID: lineMPID,
            endPoint: THPositionPart(
              coordinates: point,
              decimalPositions: decimalPositions,
            ),
          ),
        )
        .toList();
  }

  /// Converts a raw captured freehand stroke into a simplified series of
  /// [THStraightLineSegment] values ready to become a [THLine]'s children
  /// (the trailing [THEndline] is not added here).
  ///
  /// Returns `null` when, after removing consecutive duplicates,
  /// [rawCanvasPoints] has fewer than two distinct points.
  static List<THStraightLineSegment>? simplifyStrokeToStraightLineSegments({
    required List<Offset> rawCanvasPoints,
    required Rect rawBoundingBox,
    required int lineMPID,
    required int decimalPositions,
  }) {
    final List<Offset> distinctPoints = removeConsecutiveDuplicatePoints(
      rawCanvasPoints,
    );

    if (distinctPoints.length < 2) {
      return null;
    }

    final List<THStraightLineSegment> straightLineSegments =
        buildStraightLineSegments(
          canvasPoints: distinctPoints,
          lineMPID: lineMPID,
          decimalPositions: decimalPositions,
        );
    final double epsilon = computeSimplificationEpsilon(rawBoundingBox);
    final List<THStraightLineSegment> simplified =
        MPStraightLineSimplificationAux.raumerDouglasPeuckerIterative(
          originalStraightLineSegments: straightLineSegments,
          accuracy: epsilon,
        );

    assert(
      simplified.first.endPoint.coordinates == distinctPoints.first,
      'Freehand simplification must retain the first stroke point.',
    );
    assert(
      simplified.last.endPoint.coordinates == distinctPoints.last,
      'Freehand simplification must retain the final stroke point.',
    );

    return simplified;
  }
}
