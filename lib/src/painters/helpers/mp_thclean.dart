// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

/// Implements Therion's `thclean` by painting the active map background.
abstract final class MPThClean {
  static void drawPath({
    required Canvas canvas,
    required Path path,
    required Color backgroundColor,
  }) {
    final Paint cleanPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, cleanPaint);
  }
}
