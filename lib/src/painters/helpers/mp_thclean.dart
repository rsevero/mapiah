// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

/// Implements Therion's `thclean` by painting the active map background.
abstract final class MPThClean {
  /// [opacity] mirrors `thclean`'s `transparency` branch (`thfill c withcolor
  /// background withalpha -1`), which fades the erased background instead of
  /// fully replacing it; defaults to a full, opaque erase.
  static void drawPath({
    required Canvas canvas,
    required Path path,
    required Color backgroundColor,
    double opacity = 1.0,
  }) {
    final Paint cleanPaint = Paint()
      ..color = backgroundColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, cleanPaint);
  }
}
