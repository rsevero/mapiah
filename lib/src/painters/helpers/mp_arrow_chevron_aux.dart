// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';

/// Shared by `l_arrow_SKBB`'s two callers (`MPArrowSKBBLineDecorator`
/// directly, `MPMapConnectionSKBBLineDecorator` via its hardcoded `Q=3`):
/// stamps an open chevron mark, in unit-symbol space, at either or both
/// ends of a path, pointing outward past that endpoint.
abstract final class MPArrowChevronAux {
  static void drawAtEnds({
    required Canvas canvas,
    required PathMetric metric,
    required double length,
    required double scale,
    required Path chevron,
    required Paint chevronPaint,
    required bool drawStart,
    required bool drawEnd,
  }) {
    if (drawStart) {
      final Tangent? startTangent = metric.getTangentForOffset(0);

      if (startTangent != null) {
        final double rotation =
            math.atan2(-startTangent.vector.dy, -startTangent.vector.dx) +
            (math.pi / 2);

        MPSymbolTransform.draw(
          canvas: canvas,
          position: startTangent.position,
          rotation: rotation,
          scale: scale,
          drawUnitSymbol: () => canvas.drawPath(chevron, chevronPaint),
        );
      }
    }

    if (drawEnd) {
      final Tangent? endTangent = metric.getTangentForOffset(length);

      if (endTangent != null) {
        final double rotation =
            math.atan2(endTangent.vector.dy, endTangent.vector.dx) +
            (math.pi / 2);

        MPSymbolTransform.draw(
          canvas: canvas,
          position: endTangent.position,
          rotation: rotation,
          scale: scale,
          drawUnitSymbol: () => canvas.drawPath(chevron, chevronPaint),
        );
      }
    }
  }
}
