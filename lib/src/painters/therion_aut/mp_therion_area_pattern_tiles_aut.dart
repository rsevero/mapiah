// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';

/// Builds the Phase 4C Therion AUT area fill pattern tiles, following the
/// same fixed-resolution, cached-and-scaled tile strategy as
/// [MPTherionAreaPatternTilesUIS]/[MPTherionAreaPatternTilesSKBB].
/// `pattern_water_AUT`/`pattern_sump_AUT`/`pattern_flowstone_AUT`/
/// `pattern_ice_AUT` are real `beginpattern` MetaPost blocks, ported here as
/// literal repeating tiles ([_hatchTile]/[_gridTile]/[_brickTile] and
/// [buildIceTile]'s bespoke `.9u x .5u` tick grid); `a_sand_AUT`
/// (`a_clay_AUT`'s alias)/`a_pebbles_AUT`/`a_debris_AUT`/`a_blocks_AUT`/
/// `a_snow_AUT` are all literal random-scatter loops (not `beginpattern`
/// blocks), so each is approximated as a small motif repeated on a
/// fixed-seed-jittered grid via [_scatterTile], the same simplification
/// [MPTherionAreaPatternTilesSKBB] already makes.
abstract final class MPTherionAreaPatternTilesAUT {
  /// `pattern_water_AUT`: `draw origin--10up withpen pensquare scaled
  /// .02u; patternxstep(.18u);` then `patterntransform(identity rotated
  /// 90)` — horizontal lines every `.18u`. Repeated a little tighter than
  /// the literal `.18u` so the hatch reads as dense as the reference PDF.
  static ui.Image buildWaterTile(ui.Color color) => _hatchTile(
    color: color,
    spacingUnits: 0.14,
    penUnits: 0.025,
    horizontal: true,
  );

  /// `pattern_sump_AUT`: a short vertical and a short horizontal segment
  /// from the origin, each `.25u` — a repeating grid of right-angle
  /// corners, i.e. a `.25u` graph-paper grid. Drawn a little tighter than
  /// the literal `.25u` so the grid reads as dense as the reference PDF.
  static ui.Image buildSumpTile(ui.Color color) =>
      _gridTile(color: color, cellUnits: 0.18, penUnits: 0.025);

  /// `pattern_sand_AUT`/`a_sand_AUT`, and `a_clay_AUT` (a bare `let` alias
  /// of `a_sand_AUT`): `for i=0.0u step 0.2u until 2.4u` nested over the
  /// same range — a tiny `PenC` dash placed every `0.2u` on a `2.4u`
  /// tile, `randomized 0.09u` and `rotated uniformdeviate(360)`. Ported
  /// literally as a `0.2u` grid (was `0.6u`, three times too sparse per
  /// axis / roughly nine times too sparse by area).
  static ui.Image buildSandTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 0.2,
      gridSize: 12,
      jitterFactor: 0.45,
      salt: 1,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        canvas.drawCircle(
          ui.Offset.zero,
          0.035 * u,
          ui.Paint()
            ..color = color
            ..style = ui.PaintingStyle.fill,
        );
      },
    );
  }

  /// `pattern_pebbles_AUT`: `for i=0.0u step 0.3u until 5.1u` nested over
  /// the same range — a `PenC` superellipse lens (`~.2u` by `.1u`) placed
  /// every `0.3u` on a `5.1u` tile, individually `scaled
  /// (uniformdeviate(0.4)+.55)` (a random factor in `[0.55, 0.95]`),
  /// `randomized (u/45)` and `rotated uniformdeviate(360)`. Ported as a
  /// `0.3u` grid of ovals (was `1.0u`, more than three times too sparse
  /// per axis) with the matching per-instance random scale.
  static ui.Image buildPebblesTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 0.3,
      gridSize: 13,
      jitterFactor: 0.5,
      salt: 2,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final double scale = 0.55 + (random.nextDouble() * 0.4);
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;

        canvas.drawOval(
          ui.Rect.fromCenter(
            center: ui.Offset.zero,
            width: 0.2 * u * scale,
            height: 0.1 * u * scale,
          ),
          paint,
        );
      },
    );
  }

  /// `a_debris_AUT`: a scatter of small `punked` pentagon block outlines,
  /// each instance individually scaled by `uniformdeviate(0.4)+0.3` (i.e.
  /// a random factor in `[0.3, 0.7]`) applied to the base `.5u` pentagon.
  static ui.Image buildDebrisTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 4,
      jitterFactor: 0.7,
      salt: 3,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final double scale = 0.3 + (random.nextDouble() * 0.4);

        _drawPentagon(canvas, u, color, 0.5 * scale);
      },
    );
  }

  /// `a_blocks_AUT`: the same pentagon motif as [buildDebrisTile], each
  /// instance individually scaled by `uniformdeviate(0.7)+0.8` (i.e. a
  /// random factor in `[0.8, 1.5]`) applied to the base `.5u` pentagon.
  static ui.Image buildBlocksTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.3,
      gridSize: 4,
      jitterFactor: 0.6,
      salt: 4,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final double scale = 0.8 + (random.nextDouble() * 0.7);

        _drawPentagon(canvas, u, color, 0.5 * scale);
      },
    );
  }

  /// `pattern_ice_AUT`/`a_ice_AUT`: a real `beginpattern` block, not a
  /// random-scatter loop. Each `patternxstep(.9u) patternystep(.5u)` cell
  /// draws four `PenC` (`.05u`) `.3u` ticks — `p := (-.15u,0)--(.15u,0)`
  /// then `draw p; draw p shifted (.25u,0) rotated 90; draw p shifted
  /// (.45u,.25u); draw p shifted (0,.45u) rotated 90;` — i.e. a horizontal
  /// tick at the cell corner, a vertical tick on the mid-height left edge,
  /// a horizontal tick at the cell centre, and a vertical tick at the
  /// mid-width corner. Ported as that repeating rectangular tile (was a
  /// sparse 3u-grid `+` scatter, far lighter than the reference PDF), with
  /// the cell and tick geometry scaled to [_iceScale] of the literal
  /// `.9u x .5u` / `.3u` so the repeat reads at the same size as the
  /// reference PDF; the `.05u` pen keeps its literal weight, matching how
  /// the sibling `water`/`sump`/`flowstone` tiles are tightened.
  static const double _iceScale = 0.8;

  static ui.Image buildIceTile(ui.Color color) {
    final double u = mpTherionAreaPatternTileUnitPixels;
    final double cellWidth = 0.9 * _iceScale * u;
    final double cellHeight = 0.5 * _iceScale * u;
    final double tickHalf = 0.15 * _iceScale * u;
    final double tickInset = 0.25 * _iceScale * u;
    final double tickCentre = 0.45 * _iceScale * u;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 0.05 * u
      ..strokeCap = ui.StrokeCap.round;

    void horizontalTick(double cx, double cy) => canvas.drawLine(
      ui.Offset(cx - tickHalf, cy),
      ui.Offset(cx + tickHalf, cy),
      paint,
    );
    void verticalTick(double cx, double cy) => canvas.drawLine(
      ui.Offset(cx, cy - tickHalf),
      ui.Offset(cx, cy + tickHalf),
      paint,
    );

    // Draw the four ticks plus their wrapped copies so the ticks that sit on
    // the cell edges/corners join seamlessly under `TileMode.repeated`.
    for (final double dx in <double>[-cellWidth, 0, cellWidth]) {
      for (final double dy in <double>[-cellHeight, 0, cellHeight]) {
        horizontalTick(dx, dy);
        verticalTick(dx, dy + tickInset);
        horizontalTick(dx + tickCentre, dy + tickInset);
        verticalTick(dx + tickCentre, dy);
      }
    }

    return recorder.endRecording().toImageSync(
      cellWidth.round(),
      cellHeight.round(),
    );
  }

  /// `a_snow_AUT`: `for i/j = ... step 1.0u ...` scattering a small six-ray
  /// `PenC` snowflake every `1.0u`, `randomized 0.5u`. Approximated the same
  /// way as [MPTherionAreaPatternTilesSKBB.buildSnowTile], but packed far
  /// denser than uAUT.mp's `1.0u` step so the fill reads as heavy as the
  /// reference PDF: a `0.4875u` 8x8 grid (was a `1.3u` 3x3 grid) on a
  /// same-size `3.9u` tile — 64 repeats instead of 9, no bigger raster
  /// and the same motif size.
  static ui.Image buildSnowTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 0.4875,
      gridSize: 8,
      jitterFactor: 0.5,
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

  /// `pattern_flowstone_AUT`: `pickup PenC; draw (0,.01u)--(.33u,.01u);
  /// draw (.33u,.33u)--(.66u,.33u); patternbbox(0,0,.66u,.66u)` — two
  /// `PenC` (`.05u`) dashes staggered diagonally within each `.66u` cell.
  /// The pen was `.02u` here (Therion's is `PenC` = `.05u`), which made
  /// the dashes read as much lighter than the reference.
  static ui.Image buildFlowstoneTile(ui.Color color) =>
      _brickTile(color: color, cellUnits: 0.5, penUnits: 0.05);

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
    required double penUnits,
    required bool horizontal,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels * spacingUnits * 4;
    final double step = mpTherionAreaPatternTileUnitPixels * spacingUnits;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = penUnits * mpTherionAreaPatternTileUnitPixels;

    for (double offset = 0; offset < side; offset += step) {
      if (horizontal) {
        canvas.drawLine(ui.Offset(0, offset), ui.Offset(side, offset), paint);
      } else {
        canvas.drawLine(ui.Offset(offset, 0), ui.Offset(offset, side), paint);
      }
    }

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }

  static ui.Image _gridTile({
    required ui.Color color,
    required double cellUnits,
    required double penUnits,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels * cellUnits;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = penUnits * mpTherionAreaPatternTileUnitPixels;

    canvas.drawLine(ui.Offset(0, 0), ui.Offset(side, 0), paint);
    canvas.drawLine(ui.Offset(0, 0), ui.Offset(0, side), paint);

    final int size = side.round();

    return recorder.endRecording().toImageSync(size, size);
  }

  static ui.Image _brickTile({
    required ui.Color color,
    required double cellUnits,
    required double penUnits,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double side = mpTherionAreaPatternTileUnitPixels * cellUnits;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = penUnits * mpTherionAreaPatternTileUnitPixels;

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
