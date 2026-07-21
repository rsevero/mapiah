// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

/// Builds the Phase 1 Therion UIS area fill pattern tiles.
///
/// Every tile is rasterized once, at a fixed resolution ([tileUnitPixels]
/// pixels per symbol unit `u`), and reused via [MPPatternCache]. At paint
/// time the tile is scaled to the current on-screen `u` through the
/// `ImageShader`'s transform matrix, so a single raster works at every zoom
/// level. Coordinates are transcribed directly from the `beginpattern`
/// blocks in therion-mpost/thArea.mp; unlike point symbols, these textures
/// have no meaningful up/down orientation, so no Y-negation is needed.
abstract final class MPTherionAreaPatternTilesUIS {
  static const double tileUnitPixels = 100.0;

  static ui.Image buildWaterTile(ui.Color lineColor) {
    return _diagonalHatchTile(
      cellUnits: 0.18,
      penUnits: 0.02,
      color: lineColor,
    );
  }

  static ui.Image buildSumpTile(ui.Color lineColor) {
    return _crossHatchTile(cellUnits: 0.25, penUnits: 0.02, color: lineColor);
  }

  static ui.Image buildDebrisTile(ui.Color lineColor) {
    const double cellUnits = 2.0;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * tileUnitPixels;

    for (final (double angleDeg, double dx, double dy) tick in const [
      (-40.0, 0.2, 0.3),
      (70.0, 0.9, 1.5),
      (20.0, 1.5, 0.8),
    ]) {
      canvas.save();
      canvas.translate(tick.$2 * tileUnitPixels, tick.$3 * tileUnitPixels);
      canvas.rotate(tick.$1 * (3.14159265358979 / 180));
      canvas.drawLine(
        ui.Offset(-0.15 * tileUnitPixels, 0),
        ui.Offset(0.15 * tileUnitPixels, 0),
        paint,
      );
      canvas.restore();
    }

    return recorder.endRecording().toImageSync(
      (cellUnits * tileUnitPixels).round(),
      (cellUnits * tileUnitPixels).round(),
    );
  }

  static ui.Image buildFlowstoneTile(ui.Color lineColor) {
    const double cellXUnits = 1.0;
    const double cellYUnits = 0.8;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * tileUnitPixels;

    ui.Path curve(double dx, double dy) {
      return ui.Path()
        ..moveTo((-0.35 + dx) * tileUnitPixels, dy * tileUnitPixels)
        ..quadraticBezierTo(
          dx * tileUnitPixels,
          (dy - 0.3) * tileUnitPixels,
          (0.35 + dx) * tileUnitPixels,
          dy * tileUnitPixels,
        );
    }

    canvas.drawPath(curve(0, 0), paint);
    canvas.drawPath(curve(0.35, 0.4), paint);

    return recorder.endRecording().toImageSync(
      (cellXUnits * tileUnitPixels).round(),
      (cellYUnits * tileUnitPixels).round(),
    );
  }

  static ui.Image buildMoonmilkTile(ui.Color lineColor) {
    const double cellXUnits = 1.0;
    const double cellYUnits = 0.6;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * tileUnitPixels;

    ui.Path wave(double dx, double dy) {
      return ui.Path()
        ..moveTo((-0.5 + dx) * tileUnitPixels, dy * tileUnitPixels)
        ..quadraticBezierTo(
          (-0.333 + dx) * tileUnitPixels,
          (dy + 0.12) * tileUnitPixels,
          (-0.1666 + dx) * tileUnitPixels,
          dy * tileUnitPixels,
        )
        ..quadraticBezierTo(
          (0 + dx) * tileUnitPixels,
          (dy - 0.12) * tileUnitPixels,
          (0.1666 + dx) * tileUnitPixels,
          dy * tileUnitPixels,
        )
        ..quadraticBezierTo(
          (0.333 + dx) * tileUnitPixels,
          (dy + 0.12) * tileUnitPixels,
          (0.5 + dx) * tileUnitPixels,
          dy * tileUnitPixels,
        );
    }

    canvas.drawPath(wave(0, 0.3), paint);
    canvas.drawPath(wave(0.5, 0.6), paint);

    return recorder.endRecording().toImageSync(
      (cellXUnits * tileUnitPixels).round(),
      (cellYUnits * tileUnitPixels).round(),
    );
  }

  static ui.Image _diagonalHatchTile({
    required double cellUnits,
    required double penUnits,
    required ui.Color color,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = penUnits * tileUnitPixels;
    final double side = cellUnits * tileUnitPixels;

    canvas.drawLine(ui.Offset.zero, ui.Offset(side, side), paint);

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }

  static ui.Image _crossHatchTile({
    required double cellUnits,
    required double penUnits,
    required ui.Color color,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = penUnits * tileUnitPixels;
    final double side = cellUnits * tileUnitPixels;

    canvas.drawLine(ui.Offset.zero, ui.Offset(side, side), paint);
    canvas.drawLine(ui.Offset(side, 0), ui.Offset(0, side), paint);

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }
}
