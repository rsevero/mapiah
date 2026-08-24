// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';

/// Builds the Phase 4B Therion SKBB area fill pattern tiles, following the
/// same fixed-resolution, cached-and-scaled tile strategy as
/// [MPTherionAreaPatternTilesUIS]. `a_clay_SKBB`/`a_ice_SKBB`/
/// `a_snow_SKBB`/`a_blocks_SKBB`/`a_pebbles_SKBB`/`a_debris_SKBB` are all
/// literal random-scatter loops in `thArea.mp` (not `beginpattern` blocks),
/// so each is approximated here as a small motif repeated on a
/// fixed-seed-jittered grid, mirroring [MPTherionAreaPatternTilesUIS.
/// buildSandTile]'s approach for `a_sand_UIS`.
abstract final class MPTherionAreaPatternTilesSKBB {
  static ui.Image buildWaterTile(ui.Color color) => _solidTile(color);

  static ui.Image buildSumpTile(ui.Color color) => _solidTile(color);

  static ui.Image _solidTile(ui.Color color) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels;

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, side, side),
      ui.Paint()
        ..color = color
        ..style = ui.PaintingStyle.fill,
    );

    return recorder.endRecording().toImageSync(side.round(), side.round());
  }

  static ui.Image buildClayTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.5,
      gridSize: 2,
      jitterFactor: 0.3,
      salt: 1,
      randomizeRotation: false,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;
        final ui.Path curve = MPDirectionalCurveAux.buildCurvePath(
          start: ui.Offset(-0.2 * u, 0),
          end: ui.Offset(0, 0),
          startDirectionDegrees: -90,
          endDirectionDegrees: 90,
        );

        curve.addPath(
          MPDirectionalCurveAux.buildCurvePath(
            start: ui.Offset(0, 0),
            end: ui.Offset(0.2 * u, 0),
            startDirectionDegrees: -90,
            endDirectionDegrees: 90,
          ),
          ui.Offset.zero,
        );
        canvas.drawPath(curve, paint);
      },
    );
  }

  static ui.Image buildIceTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.5,
      gridSize: 2,
      jitterFactor: 0.4,
      salt: 2,
      randomizeRotation: false,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;

        canvas.drawLine(
          ui.Offset(-0.2 * u, 0),
          ui.Offset(0.2 * u, 0),
          paint,
        );
        canvas.drawLine(
          ui.Offset(0, -0.2 * u),
          ui.Offset(0, 0.2 * u),
          paint,
        );
      },
    );
  }

  static ui.Image buildSnowTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 2.0,
      gridSize: 2,
      jitterFactor: 0.35,
      salt: 3,
      randomizeRotation: false,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;
        final ui.Path radial = ui.Path()
          ..moveTo(0, 0)
          ..lineTo(0, -0.2 * u);
        final ui.Path chevron = ui.Path()
          ..moveTo(-0.06 * u, -0.26 * u)
          ..lineTo(0, -0.2 * u)
          ..lineTo(0.06 * u, -0.26 * u);

        for (int k = 0; k < 6; k++) {
          canvas.save();
          canvas.rotate(k * math.pi / 3);
          canvas.drawPath(radial, paint);
          canvas.drawPath(chevron, paint);
          canvas.restore();
        }
      },
    );
  }

  static ui.Image buildBlocksTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 2.0,
      gridSize: 2,
      jitterFactor: 0.35,
      salt: 4,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;
        final double half = 0.25 * u;
        final ui.Path quad = ui.Path()
          ..moveTo(
            -half + (random.nextDouble() - 0.5) * 0.1 * u,
            -half + (random.nextDouble() - 0.5) * 0.1 * u,
          )
          ..lineTo(
            half + (random.nextDouble() - 0.5) * 0.1 * u,
            -half + (random.nextDouble() - 0.5) * 0.1 * u,
          )
          ..lineTo(
            half + (random.nextDouble() - 0.5) * 0.1 * u,
            half + (random.nextDouble() - 0.5) * 0.1 * u,
          )
          ..lineTo(
            -half + (random.nextDouble() - 0.5) * 0.1 * u,
            half + (random.nextDouble() - 0.5) * 0.1 * u,
          )
          ..close();

        canvas.drawPath(quad, paint);
      },
    );
  }

  static ui.Image buildPebblesTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.5,
      gridSize: 3,
      jitterFactor: 0.3,
      salt: 5,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;

        canvas.drawOval(
          ui.Rect.fromCenter(
            center: ui.Offset.zero,
            width: 0.4 * u,
            height: 0.2 * u,
          ),
          paint,
        );
      },
    );
  }

  static ui.Image buildDebrisTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.5,
      gridSize: 3,
      jitterFactor: 0.3,
      salt: 6,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;

        canvas.drawLine(
          ui.Offset(-0.2 * u, 0),
          ui.Offset(0.2 * u, 0),
          paint,
        );
      },
    );
  }

  /// Repeats [drawMotif] (called once per grid cell, canvas already
  /// translated to the cell's jittered center and, when
  /// [randomizeRotation] is set, rotated by a random angle) across a
  /// [gridSize] x [gridSize] grid of [cellUnits]-wide cells, using a
  /// fixed-seed [MPSeededRandom] so the tile is stable across repaints.
  static ui.Image _scatterTile({
    required double cellUnits,
    required int gridSize,
    required double jitterFactor,
    required int salt,
    required bool randomizeRotation,
    required void Function(ui.Canvas canvas, double u, MPSeededRandom random)
    drawMotif,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final MPSeededRandom random = MPSeededRandom(mpID: 0, salt: salt);
    final double cellPixels = cellUnits * mpTherionAreaPatternTileUnitPixels;

    for (int gridX = 0; gridX < gridSize; gridX++) {
      for (int gridY = 0; gridY < gridSize; gridY++) {
        final double jitterX = ((random.nextDouble() * 2) - 1) * jitterFactor;
        final double jitterY = ((random.nextDouble() * 2) - 1) * jitterFactor;
        final double x = (gridX + 0.5 + jitterX) * cellPixels;
        final double y = (gridY + 0.5 + jitterY) * cellPixels;

        canvas.save();
        canvas.translate(x, y);

        if (randomizeRotation) {
          canvas.rotate(random.nextDouble() * 2 * math.pi);
        }

        drawMotif(canvas, mpTherionAreaPatternTileUnitPixels, random);
        canvas.restore();
      }
    }

    final int size = (gridSize * cellPixels).round();

    return recorder.endRecording().toImageSync(size, size);
  }
}
