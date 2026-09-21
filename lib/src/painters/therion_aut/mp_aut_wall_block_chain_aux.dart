// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_thclean.dart';

/// Shared geometry for `l_wall_debris_AUT` and `l_wall_blocks_AUT`: a
/// continuous chain of irregular, randomly scaled and rotated polygon
/// "blocks" laid along the wall path, each erased from the background
/// (`thclean`) before its outline is stroked so overlapping blocks read
/// as a pile of rubble tracing the wall. Mapiah drops Therion's exact
/// collision-avoidance inner loop (advance until the new block clears the
/// previous one) and instead advances by half the block width each step,
/// which keeps the blocks touching without measurable overlap for the
/// spacings both macros use.
abstract final class MPAUTWallBlockChainAux {
  static void drawBlockChain({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required double u,
    required int mpID,
    required List<Offset> baseShape,
    required double randomizeFactor,
    required double scaleMin,
    required double scaleSpan,
    required double rotationMinDegrees,
    required double rotationSpanDegrees,
    bool closeOutline = true,
    double advanceFactor = 0.5,
  }) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 7);
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;
    final Color backgroundColor = THPaint.thPaintWhiteBackground.color;

    double cur = 0;
    int guard = 0;

    while ((cur <= length) && (guard < 400)) {
      guard++;

      final Tangent? tangent = metric.getTangentForOffset(
        cur.clamp(0, length).toDouble(),
      );

      if (tangent == null) {
        break;
      }

      final double tangentLength = tangent.vector.distance;
      final double pathAngle = (tangentLength == 0)
          ? 0
          : math.atan2(tangent.vector.dy, tangent.vector.dx);
      final double scale = scaleMin + (random.nextDouble() * scaleSpan);
      final double rotation =
          (rotationMinDegrees + (random.nextDouble() * rotationSpanDegrees)) *
          math.pi /
          180;
      final double totalAngle = pathAngle + rotation;
      final double cosA = math.cos(totalAngle);
      final double sinA = math.sin(totalAngle);
      final Path block = Path();

      for (int index = 0; index < baseShape.length; index++) {
        final Offset base = baseShape[index] * u;
        final Offset jitter = random.randomizedOffset(randomizeFactor * u);
        final Offset local = (base + jitter) * scale;
        final Offset placed = Offset(
          tangent.position.dx + (local.dx * cosA) - (local.dy * sinA),
          tangent.position.dy + (local.dx * sinA) + (local.dy * cosA),
        );

        if (index == 0) {
          block.moveTo(placed.dx, placed.dy);
        } else {
          block.lineTo(placed.dx, placed.dy);
        }
      }

      // `thclean` always erases the closed shape; Therion strokes
      // `l_wall_blocks_AUT`'s outline open (no `--cycle`), leaving a gap
      // on the outward side, but strokes `l_wall_debris_AUT`'s closed.
      final Path erasePath = Path.from(block)..close();
      final double blockWidth = erasePath.getBounds().width;

      if (closeOutline) {
        block.close();
      }

      MPThClean.drawPath(
        canvas: canvas,
        path: erasePath,
        backgroundColor: backgroundColor,
      );
      canvas.drawPath(block, strokePaint);

      cur += math.max(blockWidth * advanceFactor, 0.15 * u);
    }
  }
}
