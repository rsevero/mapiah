// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';

/// Builds the Phase 4C Therion AUT area fill pattern tiles, following the
/// same fixed-resolution, cached-and-scaled tile strategy as
/// [MPTherionAreaPatternTilesUIS]/[MPTherionAreaPatternTilesSKBB].
/// `pattern_water_AUT`/`pattern_sump_AUT`/`pattern_flowstone_AUT` are real
/// `beginpattern` MetaPost blocks, ported here as literal repeating line
/// grids ([_hatchTile]/[_gridTile]/[_brickTile]); `a_sand_AUT`
/// (`a_clay_AUT`'s alias)/`a_pebbles_AUT`/`a_debris_AUT`/`a_blocks_AUT`/
/// `a_ice_AUT`/`a_snow_AUT` are all literal random-scatter loops (not
/// `beginpattern` blocks), so each is approximated as a small motif
/// repeated on a fixed-seed-jittered grid via [_scatterTile], the same
/// simplification [MPTherionAreaPatternTilesSKBB] already makes.
abstract final class MPTherionAreaPatternTilesAUT {
  /// `pattern_water_AUT`: `draw origin--10up withpen pensquare scaled
  /// .02u; patternxstep(.18u);` then `patterntransform(identity rotated
  /// 90)` — vertical lines every `.18u`, rotated 90 degrees, i.e.
  /// horizontal lines every `.18u`.
  static ui.Image buildWaterTile(ui.Color color) =>
      _hatchTile(color: color, spacingUnits: 0.18, horizontal: true);

  /// `pattern_sump_AUT`: a short vertical and a short horizontal segment
  /// from the origin, each `.25u` — a repeating grid of right-angle
  /// corners, i.e. a `.25u` graph-paper grid.
  static ui.Image buildSumpTile(ui.Color color) =>
      _gridTile(color: color, cellUnits: 0.25);

  /// `pattern_sand_AUT`/`a_sand_AUT`, and `a_clay_AUT` (a bare `let` alias
  /// of `a_sand_AUT`): a dense scatter of tiny, randomly rotated dashes.
  static ui.Image buildSandTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 0.6,
      gridSize: 5,
      jitterFactor: 0.5,
      salt: 1,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.06 * u
          ..strokeCap = ui.StrokeCap.round;

        canvas.drawLine(ui.Offset.zero, ui.Offset(0.06 * u, 0.06 * u), paint);
      },
    );
  }

  /// `pattern_pebbles_AUT`: a scatter of small superellipse lenses,
  /// approximated as ovals (same simplification
  /// [MPTherionAreaPatternTilesSKBB.buildPebblesTile] already makes).
  static ui.Image buildPebblesTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 4,
      jitterFactor: 0.3,
      salt: 2,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;

        canvas.drawOval(
          ui.Rect.fromCenter(center: ui.Offset.zero, width: 0.4 * u, height: 0.2 * u),
          paint,
        );
      },
    );
  }

  /// `a_debris_AUT`: a scatter of small `punked` pentagon block outlines.
  static ui.Image buildDebrisTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 4,
      jitterFactor: 0.7,
      salt: 3,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) => _drawPentagon(canvas, u, color, 0.3),
    );
  }

  /// `a_blocks_AUT`: the same pentagon motif as [buildDebrisTile], scaled
  /// up to `a_blocks_AUT`'s bigger blocks.
  static ui.Image buildBlocksTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.3,
      gridSize: 4,
      jitterFactor: 0.6,
      salt: 4,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) => _drawPentagon(canvas, u, color, 0.5),
    );
  }

  /// `pattern_ice_AUT`/`a_ice_AUT`: a small `+`-shaped tick, scattered.
  static ui.Image buildIceTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 3,
      jitterFactor: 0.4,
      salt: 5,
      randomizeRotation: false,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;

        canvas.drawLine(ui.Offset(-0.15 * u, 0), ui.Offset(0.15 * u, 0), paint);
        canvas.drawLine(ui.Offset(0, -0.15 * u), ui.Offset(0, 0.15 * u), paint);
      },
    );
  }

  /// `a_snow_AUT`: a scatter of small six-ray snowflakes, approximated the
  /// same way as [MPTherionAreaPatternTilesSKBB.buildSnowTile].
  static ui.Image buildSnowTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.3,
      gridSize: 3,
      jitterFactor: 0.35,
      salt: 6,
      randomizeRotation: false,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;
        final ui.Path radial = ui.Path()
          ..moveTo(0, 0)
          ..lineTo(0, -0.2 * u);

        for (int k = 0; k < 6; k++) {
          canvas.save();
          canvas.rotate(k * math.pi / 3);
          canvas.drawPath(radial, paint);
          canvas.restore();
        }
      },
    );
  }

  /// `pattern_flowstone_AUT`: two short horizontal segments staggered
  /// diagonally within each `.66u` cell.
  static ui.Image buildFlowstoneTile(ui.Color color) =>
      _brickTile(color: color, cellUnits: 0.66);

  static void _drawPentagon(
    ui.Canvas canvas,
    double u,
    ui.Color color,
    double half,
  ) {
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * u;
    final double halfPixels = half * u;
    final ui.Path pentagon = ui.Path()
      ..moveTo(-halfPixels, halfPixels)
      ..lineTo(halfPixels, halfPixels)
      ..lineTo(2 * halfPixels, -0.01 * u)
      ..lineTo(halfPixels, -halfPixels)
      ..lineTo(-halfPixels, -halfPixels)
      ..close();

    canvas.drawPath(pentagon, paint);
  }

  static ui.Image _hatchTile({
    required ui.Color color,
    required double spacingUnits,
    required bool horizontal,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels * spacingUnits * 4;
    final double step = mpTherionAreaPatternTileUnitPixels * spacingUnits;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.02 * mpTherionAreaPatternTileUnitPixels;

    for (double offset = 0; offset <= side; offset += step) {
      if (horizontal) {
        canvas.drawLine(ui.Offset(0, offset), ui.Offset(side, offset), paint);
      } else {
        canvas.drawLine(ui.Offset(offset, 0), ui.Offset(offset, side), paint);
      }
    }

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }

  static ui.Image _gridTile({required ui.Color color, required double cellUnits}) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels * cellUnits;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.02 * mpTherionAreaPatternTileUnitPixels;

    canvas.drawLine(ui.Offset(0, 0), ui.Offset(side, 0), paint);
    canvas.drawLine(ui.Offset(0, 0), ui.Offset(0, side), paint);

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }

  static ui.Image _brickTile({
    required ui.Color color,
    required double cellUnits,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels * cellUnits;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.02 * mpTherionAreaPatternTileUnitPixels;

    canvas.drawLine(
      ui.Offset(0, 0.01 * side),
      ui.Offset(0.5 * side, 0.01 * side),
      paint,
    );
    canvas.drawLine(
      ui.Offset(0.5 * side, 0.5 * side),
      ui.Offset(side, 0.5 * side),
      paint,
    );

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }

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
    final double cellPixels = cellUnits * mpTherionAreaPatternTileUnitPixels;
    final double tileSize = gridSize * cellPixels;
    final MPSeededRandom random = MPSeededRandom(mpID: 0, salt: salt);

    for (int gridX = 0; gridX < gridSize; gridX++) {
      for (int gridY = 0; gridY < gridSize; gridY++) {
        final double jitterX = ((random.nextDouble() * 2) - 1) * jitterFactor;
        final double jitterY = ((random.nextDouble() * 2) - 1) * jitterFactor;
        final double x = (gridX + 0.5 + jitterX) * cellPixels;
        final double y = (gridY + 0.5 + jitterY) * cellPixels;
        final double rotation = randomizeRotation
            ? random.nextDouble() * 2 * math.pi
            : 0.0;
        final ui.PictureRecorder motifRecorder = ui.PictureRecorder();
        final ui.Canvas motifCanvas = ui.Canvas(motifRecorder);

        drawMotif(motifCanvas, mpTherionAreaPatternTileUnitPixels, random);

        final ui.Picture motif = motifRecorder.endRecording();

        for (final double wrapX in [-tileSize, 0, tileSize]) {
          for (final double wrapY in [-tileSize, 0, tileSize]) {
            canvas.save();
            canvas.translate(x + wrapX, y + wrapY);

            if (rotation != 0.0) {
              canvas.rotate(rotation);
            }

            canvas.drawPicture(motif);
            canvas.restore();
          }
        }

        motif.dispose();
      }
    }

    final int size = tileSize.round();

    return recorder.endRecording().toImageSync(size, size);
  }
}
