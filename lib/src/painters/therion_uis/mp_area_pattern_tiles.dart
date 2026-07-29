// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';

/// Builds the Phase 1 Therion UIS area fill pattern tiles.
///
/// Every tile is rasterized once, at a fixed resolution
/// ([mpTherionAreaPatternTileUnitPixels] pixels per symbol unit `u`), and
/// reused via [MPPatternCache]. At paint time the tile is scaled to the
/// current on-screen `u` through the `ImageShader`'s transform matrix, so a
/// single raster works at every zoom level. Coordinates are transcribed
/// directly from the `beginpattern` blocks in therion-mpost/thArea.mp.
/// Asymmetric patterns must reflect their Y coordinates for Mapiah's canvas,
/// which has the opposite Y-axis direction.
abstract final class MPTherionAreaPatternTilesUIS {
  static ui.Image buildWaterTile(ui.Color lineColor) {
    return _diagonalHatchTile(
      cellUnits: mpTherionUISWaterCellUnits,
      penUnits: mpTherionUISWaterPenUnits,
      color: lineColor,
    );
  }

  static ui.Image buildSumpTile(ui.Color lineColor) {
    return _crossHatchTile(
      cellUnits: mpTherionUISWaterCellUnits,
      penUnits: mpTherionUISWaterPenUnits,
      color: lineColor,
    );
  }

  static ui.Image buildDebrisTile(ui.Color lineColor) {
    const double cellUnits = 2.0;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * mpTherionAreaPatternTileUnitPixels;

    for (final (double angleDeg, double dx, double dy) tick
        in mpTherionUISDebrisTicks) {
      canvas.save();
      canvas.translate(
        tick.$2 * mpTherionAreaPatternTileUnitPixels,
        tick.$3 * mpTherionAreaPatternTileUnitPixels,
      );
      canvas.rotate(tick.$1 * (3.14159265358979 / 180));
      canvas.drawLine(
        ui.Offset(-0.15 * mpTherionAreaPatternTileUnitPixels, 0),
        ui.Offset(0.15 * mpTherionAreaPatternTileUnitPixels, 0),
        paint,
      );
      canvas.restore();
    }

    return recorder.endRecording().toImageSync(
      (cellUnits * mpTherionAreaPatternTileUnitPixels).round(),
      (cellUnits * mpTherionAreaPatternTileUnitPixels).round(),
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
      ..strokeWidth = 0.05 * mpTherionAreaPatternTileUnitPixels;

    ui.Path curve(double dx, double dy) {
      return MPDirectionalCurveAux.buildCurvePath(
        start: ui.Offset(
          (-curveHalfWidthUnits + dx) * mpTherionAreaPatternTileUnitPixels,
          dy * mpTherionAreaPatternTileUnitPixels,
        ),
        end: ui.Offset(
          (curveHalfWidthUnits + dx) * mpTherionAreaPatternTileUnitPixels,
          dy * mpTherionAreaPatternTileUnitPixels,
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
      (cellXUnits * mpTherionAreaPatternTileUnitPixels).round(),
      (cellYUnits * mpTherionAreaPatternTileUnitPixels).round(),
    );
  }

  /// Ports `a_sand_UIS`'s `beginpattern`-free, nested-loop dot cloud as a
  /// repeating tile: a 3x3 grid of dots, each jittered within `0.35` of its
  /// cell width around the center. A fixed (not per-element) seed keeps the
  /// pattern stable across repaints, per the roadmap's Architecture Plan.
  static ui.Image buildSandTile(ui.Color lineColor) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.fill;
    final MPSeededRandom random = MPSeededRandom(mpID: 0, salt: 0);

    for (int gridX = 0; gridX < mpTherionUISSandGridSize; gridX++) {
      for (int gridY = 0; gridY < mpTherionUISSandGridSize; gridY++) {
        final double jitterX =
            ((random.nextDouble() * 2) - 1) *
            mpTherionUISSandJitterCellFactor;
        final double jitterY =
            ((random.nextDouble() * 2) - 1) *
            mpTherionUISSandJitterCellFactor;
        final double x =
            (gridX + 0.5 + jitterX) *
            mpTherionUISSandCellUnits *
            mpTherionAreaPatternTileUnitPixels;
        final double y =
            (gridY + 0.5 + jitterY) *
            mpTherionUISSandCellUnits *
            mpTherionAreaPatternTileUnitPixels;

        canvas.drawCircle(
          ui.Offset(x, y),
          mpTherionUISSandDotRadiusUnits *
              mpTherionAreaPatternTileUnitPixels,
          paint,
        );
      }
    }

    final int size =
        (mpTherionUISSandGridSize *
                mpTherionUISSandCellUnits *
                mpTherionAreaPatternTileUnitPixels)
            .round();

    return recorder.endRecording().toImageSync(size, size);
  }

  static ui.Image buildMoonmilkTile(ui.Color lineColor) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = lineColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * mpTherionAreaPatternTileUnitPixels;

    canvas.drawPath(
      _buildMoonmilkScallops(
        dx: 0,
        dy: mpTherionUISMoonmilkStaggerYUnits,
      ),
      paint,
    );
    canvas.drawPath(
      _buildMoonmilkScallops(
        dx: mpTherionUISMoonmilkCellXUnits,
        dy: mpTherionUISMoonmilkStaggerYUnits,
      ),
      paint,
    );
    canvas.drawPath(
      _buildMoonmilkScallops(
        dx: mpTherionUISMoonmilkStaggerXUnits,
        dy: mpTherionUISMoonmilkCellYUnits,
      ),
      paint,
    );

    return recorder.endRecording().toImageSync(
      (mpTherionUISMoonmilkCellXUnits *
              mpTherionAreaPatternTileUnitPixels)
          .round(),
      (mpTherionUISMoonmilkCellYUnits *
              mpTherionAreaPatternTileUnitPixels)
          .round(),
    );
  }

  static ui.Path _buildMoonmilkScallops({
    required double dx,
    required double dy,
  }) {
    final ui.Path path = ui.Path()
      ..moveTo(
        (mpTherionUISMoonmilkScallopXUnits.first + dx) *
            mpTherionAreaPatternTileUnitPixels,
        dy * mpTherionAreaPatternTileUnitPixels,
      );

    _addMoonmilkScallop(
      path: path,
      startXUnits: mpTherionUISMoonmilkScallopXUnits[0],
      endXUnits: mpTherionUISMoonmilkScallopXUnits[1],
      dx: dx,
      dy: dy,
    );
    _addMoonmilkScallop(
      path: path,
      startXUnits: mpTherionUISMoonmilkScallopXUnits[1],
      endXUnits: mpTherionUISMoonmilkScallopXUnits[2],
      dx: dx,
      dy: dy,
    );
    _addMoonmilkScallop(
      path: path,
      startXUnits: mpTherionUISMoonmilkScallopXUnits[2],
      endXUnits: mpTherionUISMoonmilkScallopXUnits[3],
      dx: dx,
      dy: dy,
    );

    return path;
  }

  static void _addMoonmilkScallop({
    required ui.Path path,
    required double startXUnits,
    required double endXUnits,
    required double dx,
    required double dy,
  }) {
    final double controlLengthUnits =
        (endXUnits - startXUnits) *
        mpTherionUISMoonmilkControlLengthFactor;
    final double controlY =
        (dy - controlLengthUnits) * mpTherionAreaPatternTileUnitPixels;

    path.cubicTo(
      (startXUnits + dx) * mpTherionAreaPatternTileUnitPixels,
      controlY,
      (endXUnits + dx) * mpTherionAreaPatternTileUnitPixels,
      controlY,
      (endXUnits + dx) * mpTherionAreaPatternTileUnitPixels,
      dy * mpTherionAreaPatternTileUnitPixels,
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
      ..strokeWidth = penUnits * mpTherionAreaPatternTileUnitPixels;
    final double side = cellUnits * mpTherionAreaPatternTileUnitPixels;

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
      ..strokeWidth = penUnits * mpTherionAreaPatternTileUnitPixels;
    final double side = cellUnits * mpTherionAreaPatternTileUnitPixels;

    canvas.drawLine(ui.Offset.zero, ui.Offset(side, side), paint);
    canvas.drawLine(ui.Offset(side, 0), ui.Offset(0, side), paint);

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }
}
