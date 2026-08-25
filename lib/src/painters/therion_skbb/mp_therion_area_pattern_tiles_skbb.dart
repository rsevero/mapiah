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
    // `layers: 2` overlays a second, independently-seeded scatter of the
    // same grid/jitter on top of the first instead of tightening
    // `cellUnits` or `gridSize`: either of those reduces the spacing (or
    // physical size, relative to a fixed-size motif) between individual
    // marks, which is what "too condensed" feedback was about. Layering
    // keeps each pass's own mark-to-mark spacing exactly as tuned, while
    // the second pass's marks fall in different (independently random)
    // spots, filling gaps the first pass happened to leave empty.
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 3,
      jitterFactor: 0.85,
      salt: 1,
      layers: 2,
      randomizeRotation: false,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;
        // Therion's `a_clay_SKBB` motif is
        // `(-.25u,0){up}..origin{down}..{up}(0.25u,0)`: the first segment
        // leaves the left point heading up and arrives at the origin
        // heading down (an upward-bulging hump), while the second segment
        // leaves the origin heading down and arrives at the right point
        // heading up (a downward-bulging hump) — the two mirrored humps
        // are what make the motif read as an S, not the two identical
        // humps drawn here previously.
        // A high `handleLengthFactor` pulls each curve's control points
        // well past the endpoints along their up/down direction, turning
        // the shallow arcs the default 1/3 factor produced into a deep,
        // rounded U per half — closer to the S's actual loopy look.
        const double handleLengthFactor = 1.1;
        final ui.Path curve = MPDirectionalCurveAux.buildCurvePath(
          start: ui.Offset(-0.15 * u, 0),
          end: ui.Offset(0, 0),
          startDirectionDegrees: 90,
          endDirectionDegrees: -90,
          handleLengthFactor: handleLengthFactor,
        );

        curve.addPath(
          MPDirectionalCurveAux.buildCurvePath(
            start: ui.Offset(0, 0),
            end: ui.Offset(0.15 * u, 0),
            startDirectionDegrees: -90,
            endDirectionDegrees: 90,
            handleLengthFactor: handleLengthFactor,
          ),
          ui.Offset.zero,
        );

        canvas.drawPath(curve, paint);
      },
    );
  }

  static ui.Image buildIceTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 3,
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
      cellUnits: 1.3,
      gridSize: 3,
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

  /// `a_blocks_SKBB` draws `punked (unitsquare-ish, side `uu`, `randomized
  /// (uu/2)` per corner) rotated uniformdeviate(360) shifted ((i,j)
  /// randomized 1.6uu)` on a `2uu` grid: a fully random rotation and a
  /// position jitter comparable to the grid step itself. `half`/
  /// `cornerJitter` below are tuned by eye rather than transcribed
  /// 1:1 from `uu`/`uu/2` — matching those literally (side = grid step)
  /// rendered blocks that looked oversized next to the reference PDF, and
  /// `cornerJitter` anywhere near `half` let a corner jitter past a
  /// neighboring one, self-intersecting the quad into a bowtie that reads
  /// as "not closing" even though the path always closes back to its
  /// start point.
  static ui.Image buildBlocksTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.2,
      gridSize: 4,
      jitterFactor: 0.6,
      salt: 4,
      randomizeRotation: true,
      drawMotif: (canvas, u, random) {
        final ui.Paint paint = ui.Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.05 * u;
        final double half = 0.3 * u;
        // Kept well below `half` so a jittered corner can never cross into
        // a neighboring quadrant — that crossing is what previously made
        // some quads self-intersect (a bowtie edge crossing itself reads
        // as "not closing properly", even though the path always
        // physically closes back to its start point).
        final double cornerJitter = 0.1 * u;

        ui.Offset corner(double dx, double dy) {
          final ui.Offset jitter = _randomOffset(random, cornerJitter);

          return ui.Offset(dx * half + jitter.dx, dy * half + jitter.dy);
        }

        final ui.Offset p0 = corner(-1, -1);
        final ui.Offset p1 = corner(1, -1);
        final ui.Offset p2 = corner(1, 1);
        final ui.Offset p3 = corner(-1, 1);
        final ui.Path quad = ui.Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..close();

        canvas.drawPath(quad, paint);
      },
    );
  }

  /// Approximates MetaPost's `randomized d`: displaces by a distance
  /// uniformly distributed in `[0, d]`, in a uniformly random direction.
  static ui.Offset _randomOffset(MPSeededRandom random, double magnitude) {
    final double distance = random.nextDouble() * magnitude;
    final double angle = random.nextDouble() * 2 * math.pi;

    return ui.Offset(distance * math.cos(angle), distance * math.sin(angle));
  }

  static ui.Image buildPebblesTile(ui.Color color) {
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 4,
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
    // See [buildClayTile]: `layers: 2` overlays a second, independently
    // seeded scatter pass to fill in empty gaps instead of tightening
    // `cellUnits`/`gridSize`, which would just push marks closer
    // together.
    return _scatterTile(
      cellUnits: 1.0,
      gridSize: 4,
      jitterFactor: 0.85,
      salt: 6,
      layers: 2,
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
  ///
  /// [ImageShader] tiles the returned image with [ui.TileMode.repeated],
  /// which repeats the fixed raster as-is — it does not "wrap" a motif
  /// that was recorded past the tile's edge back onto the opposite edge.
  /// A jittered motif near an edge would otherwise be permanently
  /// truncated by [ui.PictureRecorder.toImageSync]'s clip, and that same
  /// cut motif would then repeat at every tile boundary. To keep every
  /// motif whole, each is recorded up to 9 times, offset by every
  /// combination of `-tileSize`/`0`/`+tileSize` in x and y, so whichever
  /// copy actually lands within the tile bounds is complete.
  static ui.Image _scatterTile({
    required double cellUnits,
    required int gridSize,
    required double jitterFactor,
    required int salt,
    required bool randomizeRotation,
    required void Function(ui.Canvas canvas, double u, MPSeededRandom random)
    drawMotif,
    int layers = 1,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final double cellPixels = cellUnits * mpTherionAreaPatternTileUnitPixels;
    final double tileSize = gridSize * cellPixels;

    // Each layer gets its own seed (offset from the others by a large,
    // arbitrary constant so their draw sequences don't just shift by a
    // few calls and stay correlated) and is scattered independently onto
    // the same canvas, so extra layers add marks in different spots
    // rather than changing the spacing within any one layer.
    for (int layer = 0; layer < layers; layer++) {
      final MPSeededRandom random = MPSeededRandom(
        mpID: 0,
        salt: salt + layer * 7919,
      );

      for (int gridX = 0; gridX < gridSize; gridX++) {
        for (int gridY = 0; gridY < gridSize; gridY++) {
          final double jitterX =
              ((random.nextDouble() * 2) - 1) * jitterFactor;
          final double jitterY =
              ((random.nextDouble() * 2) - 1) * jitterFactor;
          final double x = (gridX + 0.5 + jitterX) * cellPixels;
          final double y = (gridY + 0.5 + jitterY) * cellPixels;
          final double rotation = randomizeRotation
              ? random.nextDouble() * 2 * math.pi
              : 0.0;

          // Record the motif's own (possibly randomized) geometry exactly
          // once per cell, then stamp that identical picture at every wrap
          // offset — calling drawMotif again per offset would consume more
          // random draws each time, giving each wrapped copy different
          // geometry instead of the one motif reappearing whole.
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
    }

    final int size = tileSize.round();

    return recorder.endRecording().toImageSync(size, size);
  }
}
