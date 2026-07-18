// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter/widgets.dart';

/// Builds and applies the common position, rotation, and scale symbol transform.
abstract final class MPSymbolTransform {
  static Matrix4 matrix({
    required Offset position,
    required double rotation,
    required double scale,
  }) {
    assert(scale > 0);

    final Matrix4 matrix = Matrix4.identity();

    matrix.translateByDouble(position.dx, position.dy, 0, 1);
    matrix.rotateZ(rotation);
    matrix.scaleByDouble(scale, scale, 1, 1);

    return matrix;
  }

  static Path path({
    required Path unitPath,
    required Offset position,
    required double rotation,
    required double scale,
  }) {
    final Matrix4 transform = matrix(
      position: position,
      rotation: rotation,
      scale: scale,
    );

    return unitPath.transform(transform.storage);
  }

  static void draw({
    required Canvas canvas,
    required Offset position,
    required double rotation,
    required double scale,
    required VoidCallback drawUnitSymbol,
  }) {
    assert(scale > 0);

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);
    drawUnitSymbol();
    canvas.restore();
  }
}
