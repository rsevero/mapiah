// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';

/// Builds the Phase 1 Therion UIS area fill pattern tiles.
///
/// Every tile is rasterized once, at a fixed resolution ([tileUnitPixels]
/// pixels per symbol unit `u`), and reused via [MPPatternCache]. At paint
/// time the tile is scaled to the current on-screen `u` through the
/// `ImageShader`'s transform matrix, so a single raster works at every zoom
/// level. Coordinates are transcribed directly from the `beginpattern`
/// blocks in therion-mpost/thArea.mp. Asymmetric patterns must reflect their Y
/// coordinates for Mapiah's canvas, which has the opposite Y-axis direction.
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
    const double cellXUnits = 0.75;
    const double cellYUnits = 0.6;
    const double curveHalfWidthUnits = 0.25;
    const double curveHandleLengthFactor = 0.4;
    const double staggerXUnits = 0.3;
    const double staggerYUnits = 0.3;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * tileUnitPixels;

    ui.Path curve(double dx, double dy) {
      return MPDirectionalCurveAux.buildCurvePath(
        start: ui.Offset(
          (-curveHalfWidthUnits + dx) * tileUnitPixels,
          dy * tileUnitPixels,
        ),
        end: ui.Offset(
          (curveHalfWidthUnits + dx) * tileUnitPixels,
          dy * tileUnitPixels,
        ),
        startDirectionDegrees: -60,
        endDirectionDegrees: 60,
        handleLengthFactor: curveHandleLengthFactor,
      );
    }

    canvas.drawPath(curve(0, 0), paint);
    canvas.drawPath(curve(cellXUnits, 0), paint);
    canvas.drawPath(curve(staggerXUnits, staggerYUnits), paint);
    canvas.drawPath(curve(0, cellYUnits), paint);
    canvas.drawPath(curve(cellXUnits, cellYUnits), paint);

    return recorder.endRecording().toImageSync(
      (cellXUnits * tileUnitPixels).round(),
      (cellYUnits * tileUnitPixels).round(),
    );
  }

  /// Ports `a_sand_UIS`'s `beginpattern`-free, nested-loop dot cloud as a
  /// repeating tile: a 3x3 grid of dots, each jittered within `0.35u` of its
  /// cell center. A fixed (not per-element) seed keeps the pattern stable
  /// across repaints, per the roadmap's Architecture Plan.
  static ui.Image buildSandTile(ui.Color lineColor) {
    const int gridSize = 3;
    const double cellUnits = 1.0;
    const double jitterUnits = 0.35;
    const double dotRadiusUnits = 0.025;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.fill;
    final MPSeededRandom random = MPSeededRandom(mpID: 0, salt: 0);

    for (int gridX = 0; gridX < gridSize; gridX++) {
      for (int gridY = 0; gridY < gridSize; gridY++) {
        final double jitterX = ((random.nextDouble() * 2) - 1) * jitterUnits;
        final double jitterY = ((random.nextDouble() * 2) - 1) * jitterUnits;
        final double x =
            (gridX + 0.5 + jitterX) * cellUnits * tileUnitPixels;
        final double y =
            (gridY + 0.5 + jitterY) * cellUnits * tileUnitPixels;

        canvas.drawCircle(
          ui.Offset(x, y),
          dotRadiusUnits * tileUnitPixels,
          paint,
        );
      }
    }

    final int size = (gridSize * cellUnits * tileUnitPixels).round();

    return recorder.endRecording().toImageSync(size, size);
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

    canvas.drawLine(ui.Offset(0, side), ui.Offset(side, 0), paint);

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
