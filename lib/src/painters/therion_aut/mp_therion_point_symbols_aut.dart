// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/helpers/mp_thclean.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Faithful Dart ports of Therion's `p_*_AUT` MetaPost point symbols
/// (Phase 4C). Same conventions as [MPTherionPointSymbolsSKBB]/
/// [MPTherionPointSymbolsUIS]: unit space, canvas pre-translated/rotated/
/// scaled, MetaPost Y-up coordinates negated.
///
/// `p_stalactite_AUT`/`p_stalagmite_AUT`/`p_pillar_AUT` (and their
/// `icestalactite`/`icestalagmite`/`icepillar` aliases) each branch on
/// `ATTR__elevation` in Therion — a side-view icicle shape when the active
/// scrap is in `elevation`/`extended` projection, otherwise a plain
/// circle. Mapiah's point draw methods have no way to plumb the scrap's
/// projection mode through today (the same gap `MPTherionPointSymbolsUIS`
/// already lives with for its own stalactite/stalagmite/pillar family), so
/// only the plan-view (`else`) branch is ported here.
///
/// `p_entrance_AUT` fills ~100 individual MetaPost triangle slices with a
/// hand-computed grey ramp to approximate a shaded cross-section; that's
/// ported here as a single linear-gradient fill over the same outer
/// triangle instead of literally replicating each slice.
///
/// `p_sand_AUT`/`p_pebbles_AUT`/`p_debris_AUT`/`p_blocks_AUT` all place
/// their sub-shapes with MetaPost's `randomized`/`uniformdeviate`, which
/// has no reproducible Dart equivalent; each is ported with the same fixed
/// literal layout convention already used for `p_sand_UIS`/`p_pebbles_UIS`/
/// `p_debris_UIS`/`p_blocks_UIS` instead of literal randomness.
abstract final class MPTherionPointSymbolsAUT {
  static const Map<
    MPTherionPointSymbol,
    void Function(Canvas, Offset, double, MPTherionSymbolPaint)
  >
  drawMethods = {
    MPTherionPointSymbol.airDraughtAUT: _drawAirDraughtAUT,
    MPTherionPointSymbol.blocksAUT: _drawBlocksAUT,
    MPTherionPointSymbol.breakdownChokeAUT: _drawBreakdownChokeAUT,
    MPTherionPointSymbol.clayAUT: _drawSandAUT,
    MPTherionPointSymbol.clayChokeAUT: _drawClayChokeAUT,
    MPTherionPointSymbol.clayTreeAUT: _drawClayTreeAUT,
    MPTherionPointSymbol.crystalAUT: _drawCrystalAUT,
    MPTherionPointSymbol.debrisAUT: _drawDebrisAUT,
    MPTherionPointSymbol.entranceAUT: _drawEntranceAUT,
    MPTherionPointSymbol.gradientAUT: _drawGradientAUT,
    MPTherionPointSymbol.iceAUT: _drawIceAUT,
    MPTherionPointSymbol.icePillarAUT: _drawPillarAUT,
    MPTherionPointSymbol.iceStalactiteAUT: _drawStalactiteAUT,
    MPTherionPointSymbol.iceStalagmiteAUT: _drawStalagmiteAUT,
    MPTherionPointSymbol.pebblesAUT: _drawPebblesAUT,
    MPTherionPointSymbol.pillarAUT: _drawPillarAUT,
    MPTherionPointSymbol.sandAUT: _drawSandAUT,
    MPTherionPointSymbol.sinkAUT: _drawSinkAUT,
    MPTherionPointSymbol.springAUT: _drawSpringAUT,
    MPTherionPointSymbol.stalactiteAUT: _drawStalactiteAUT,
    MPTherionPointSymbol.stalagmiteAUT: _drawStalagmiteAUT,
    MPTherionPointSymbol.stationTemporaryAUT: _drawStationTemporaryAUT,
    MPTherionPointSymbol.waterAUT: _drawWaterAUT,
  };

  static Paint _withPenWidth(Paint paint, double penFactor) =>
      Paint.from(paint)..strokeWidth = penFactor;

  /// `p_stalactite_AUT`/`p_icestalactite_AUT` plan view: `thclean fullcircle
  /// scaled 0.35u; thdraw fullcircle scaled 0.35u;` — a plain circle
  /// outline, radius `.175u`.
  static void _drawStalactiteAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawCircle(
          Offset.zero,
          0.175,
          _withPenWidth(paint.border!, mpTherionPenC),
        );
      },
    );
  }

  /// `p_stalagmite_AUT`/`p_icestalagmite_AUT` plan view: `thfill fullcircle
  /// scaled 0.3u;` — a plain filled circle, radius `.15u`, no border.
  static void _drawStalagmiteAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawCircle(Offset.zero, 0.15, paint.fill!);
      },
    );
  }

  /// `p_pillar_AUT`/`p_icepillar_AUT` plan view: `thclean fullcircle scaled
  /// .45u; thdraw fullcircle scaled .45u; thfill fullcircle scaled .3u;` —
  /// an outer circle outline (radius `.225u`) plus an inner filled circle
  /// (radius `.15u`).
  static void _drawPillarAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawCircle(
          Offset.zero,
          0.225,
          _withPenWidth(paint.border!, mpTherionPenC),
        );
        canvas.drawCircle(Offset.zero, 0.15, paint.fill!);
      },
    );
  }

  /// `p_crystal_AUT`: `p:=(-.35u,0)--(.35u,0); thdraw p; thdraw p rotated
  /// 45; thdraw p rotated 90; thdraw p rotated 135;` — a horizontal line and
  /// three rotated copies, an eight-ray asterisk.
  static void _drawCrystalAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    final Path ray = Path()
      ..moveTo(-0.35, 0)
      ..lineTo(0.35, 0);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        for (int k = 0; k < 4; k++) {
          canvas.save();
          canvas.rotate(k * math.pi / 4);
          canvas.drawPath(ray, pen);
          canvas.restore();
        }
      },
    );
  }

  /// `p_spring_AUT`: `thdraw (-.3u,.1u)..(0,-.1u)..(.3u,.1u);` — a shallow
  /// dip (the same "smile" family as `p_spring_SKBB`, but with half the
  /// amplitude); ported as a quadratic bezier with a proportionally
  /// exaggerated control point, matching the approximation
  /// [MPTherionPointSymbolsSKBB]'s `_drawSpringSKBB` already uses for the
  /// same MetaPost curve shape.
  static void _drawSpringAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.3, -0.1)
      ..quadraticBezierTo(0, 0.3, 0.3, -0.1);

    _drawSimplePath(canvas, position, u, path, paint.border!);
  }

  /// `p_sink_AUT`: `thdraw (-.3u,-.1u)..(0,.1u)..(.3u,-.1u);` — the mirror
  /// of [_drawSpringAUT].
  static void _drawSinkAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.3, 0.1)
      ..quadraticBezierTo(0, -0.3, 0.3, 0.1);

    _drawSimplePath(canvas, position, u, path, paint.border!);
  }

  /// `p_breakdownchoke_AUT`: a `.8u`-wide square outline plus a downward
  /// chevron `(-.21u,.305u)--(.0u,-.305u)--(.21u,.305u)`.
  static void _drawBreakdownChokeAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    final Path square = Path()
      ..moveTo(-0.4, -0.4)
      ..lineTo(0.4, -0.4)
      ..lineTo(0.4, 0.4)
      ..lineTo(-0.4, 0.4)
      ..close();
    final Path chevron = Path()
      ..moveTo(-0.21, -0.305)
      ..lineTo(0, 0.305)
      ..lineTo(0.21, -0.305);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(square, pen);
        canvas.drawPath(chevron, pen);
      },
    );
  }

  /// `p_claychoke_AUT`: the same `.8u`-wide square outline as
  /// [_drawBreakdownChokeAUT], with an "L"-shaped mark
  /// `(-.15u,.3u)--(-.15u,-.25u)--(.15u,-.25u)` instead of the chevron.
  static void _drawClayChokeAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    final Path square = Path()
      ..moveTo(-0.4, -0.4)
      ..lineTo(0.4, -0.4)
      ..lineTo(0.4, 0.4)
      ..lineTo(-0.4, 0.4)
      ..close();
    final Path mark = Path()
      ..moveTo(-0.15, -0.3)
      ..lineTo(-0.15, 0.25)
      ..lineTo(0.15, 0.25);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(square, pen);
        canvas.drawPath(mark, pen);
      },
    );
  }

  /// `p_claytree_AUT`: one small "tree" chevron
  /// `(-.15u,.15u)--(.0u,.6u)--(.15u,.15u)` plus two shifted copies.
  static void _drawClayTreeAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    Path tree(double dx, double dy) => Path()
      ..moveTo(-0.15 + dx, -0.15 + dy)
      ..lineTo(0 + dx, -0.6 + dy)
      ..lineTo(0.15 + dx, -0.15 + dy);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(tree(0, 0), pen);
        canvas.drawPath(tree(-0.4, 0.3), pen);
        canvas.drawPath(tree(0.4, 0.2), pen);
      },
    );
  }

  /// `p_sand_AUT`/`p_clay_AUT` (the latter a bare `let` alias): a 2×2 grid
  /// of dots at `(±.1u,±.1u)` (the fixed-layout approximation of
  /// MetaPost's `randomized` placement — see the class doc comment).
  static void _drawSandAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint dot = Paint()
      ..color = paint.border!.color
      ..style = PaintingStyle.fill;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        for (final double dx in const <double>[-0.1, 0.1]) {
          for (final double dy in const <double>[-0.1, 0.1]) {
            canvas.drawCircle(Offset(dx, dy), mpTherionPenB / 2, dot);
          }
        }
      },
    );
  }

  /// `p_pebbles_AUT`: a 2×2 grid of small `.2u`×`.1u` pebble ovals at
  /// `(±.15u,±.15u)`, each with a slight rotation (fixed-layout
  /// approximation, see the class doc comment).
  static void _drawPebblesAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    const List<(Offset, double)> pebbles = <(Offset, double)>[
      (Offset(-0.15, -0.15), -15),
      (Offset(0.15, -0.15), 20),
      (Offset(-0.15, 0.15), 40),
      (Offset(0.15, 0.15), -30),
    ];

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        for (final (Offset center, double degrees) in pebbles) {
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(degrees * math.pi / 180);
          canvas.drawOval(const Rect.fromLTRB(-0.1, -0.05, 0.1, 0.05), pen);
          canvas.restore();
        }
      },
    );
  }

  /// `p_debris_AUT`: `block := (-.15u,-.15u)--(.15u,-.15u)--(.3u,0.01u)--
  /// (.15u,.15u)--(-.15u,.15u)--cycle`, `thclean`ed and `thdraw`n at three
  /// fixed offsets (see the class doc comment for the randomness caveat).
  static void _drawDebrisAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    _drawBlockCluster(
      canvas: canvas,
      position: position,
      u: u,
      border: paint.border!,
      block: _pentagonBlock(0.15, 0.3),
      offsets: const <Offset>[
        Offset(0, -0.15),
        Offset(-0.15, 0.15),
        Offset(0.15, 0.15),
      ],
    );
  }

  /// `p_blocks_AUT`: the same shape family as [_drawDebrisAUT], scaled to
  /// `block := (-.25u,-.25u)--(.25u,-.25u)--(.5u,0.01u)--(.25u,.25u)--
  /// (-.25u,.25u)--cycle`.
  static void _drawBlocksAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    _drawBlockCluster(
      canvas: canvas,
      position: position,
      u: u,
      border: paint.border!,
      block: _pentagonBlock(0.25, 0.5),
      offsets: const <Offset>[
        Offset(0, -0.25),
        Offset(-0.25, 0.25),
        Offset(0.25, 0.25),
      ],
    );
  }

  static Path _pentagonBlock(double half, double tip) => Path()
    ..moveTo(-half, half)
    ..lineTo(half, half)
    ..lineTo(tip, -0.01)
    ..lineTo(half, -half)
    ..lineTo(-half, -half)
    ..close();

  static void _drawBlockCluster({
    required Canvas canvas,
    required Offset position,
    required double u,
    required Paint border,
    required Path block,
    required List<Offset> offsets,
  }) {
    final Paint pen = _withPenWidth(border, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        for (final Offset offset in offsets) {
          canvas.save();
          canvas.translate(offset.dx, offset.dy);
          canvas.drawPath(block, pen);
          canvas.restore();
        }
      },
    );
  }

  /// `p_water_AUT`: `fullcircle xscaled .85u yscaled .6u`, filled with
  /// `col_water_bg` and `pattern_water_AUT` (evenly spaced horizontal
  /// lines, `.18u` apart, after the pattern's own 90-degree
  /// `patterntransform`), then `thdraw`n.
  static void _drawWaterAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    const Rect ellipseRect = Rect.fromLTRB(-0.425, -0.3, 0.425, 0.3);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Paint? fill = paint.fill;

        if (fill != null) {
          final Paint hatchPen = Paint()
            ..color = fill.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = mpTherionPenD;

          canvas.save();
          canvas.clipPath(Path()..addOval(ellipseRect));
          for (double y = -0.3; y <= 0.3; y += 0.18) {
            canvas.drawLine(Offset(-0.5, y), Offset(0.5, y), hatchPen);
          }
          canvas.restore();
        }

        final Paint? border = paint.border;

        if (border != null) {
          canvas.drawOval(ellipseRect, _withPenWidth(border, mpTherionPenD));
        }
      },
    );
  }

  /// `p_ice_AUT`: six `.3u` tick marks, alternating horizontal/vertical, in
  /// two staggered rows.
  static void _drawIceAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    final Path path = Path()
      ..moveTo(0, 0.15)
      ..lineTo(0, -0.15)
      ..moveTo(0.3, 0)
      ..lineTo(0.6, 0)
      ..moveTo(-0.6, 0)
      ..lineTo(-0.3, 0)
      ..moveTo(-0.45, -0.1)
      ..lineTo(-0.45, -0.4)
      ..moveTo(-0.15, -0.25)
      ..lineTo(0.15, -0.25)
      ..moveTo(0.45, -0.1)
      ..lineTo(0.45, -0.4);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(path, pen);
      },
    );
  }

  /// `p_entrance_AUT`: a `.6u`-wide, `1.5u`-tall triangle (apex at the top,
  /// base at the bottom), filled with ~100 individually shaded MetaPost
  /// slices to approximate a lit cross-section — see the class doc comment
  /// for why this is ported as a single linear gradient instead.
  static void _drawEntranceAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path triangle = Path()
      ..moveTo(-0.3, 0.75)
      ..lineTo(0, -0.75)
      ..lineTo(0.3, 0.75)
      ..close();

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Paint? fill = paint.fill;

        if (fill != null) {
          final Paint gradientFill = Paint()
            ..shader = Gradient.linear(
              const Offset(0, -0.75),
              const Offset(0, 0.75),
              <Color>[
                fill.color.withValues(alpha: 0.35),
                fill.color,
              ],
            );

          canvas.drawPath(triangle, gradientFill);
        }

        final Paint? border = paint.border;

        if (border != null) {
          canvas.drawPath(triangle, _withPenWidth(border, mpTherionPenC));
        }
      },
    );
  }

  /// `p_gradient_AUT`: a vertical `1u`-long stem topped by a small filled
  /// triangle (arrowhead), the same shape family as
  /// [MPTherionPointSymbolsSKBB]'s `_drawGradientSKBB` but with a solid
  /// arrowhead instead of tick marks.
  static void _drawGradientAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path triangle = Path()
      ..moveTo(-0.15, -0.3)
      ..lineTo(0, -0.7)
      ..lineTo(0.15, -0.3)
      ..close();

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawLine(
          const Offset(0, 0.5),
          const Offset(0, -0.5),
          _withPenWidth(paint.border!, mpTherionPenC),
        );

        final Paint? fill = paint.fill;

        if (fill != null) {
          canvas.drawPath(triangle, fill);
        }

        canvas.drawPath(triangle, _withPenWidth(paint.border!, mpTherionPenC));
      },
    );
  }

  /// `p_airdraught_AUT`: a vertical stem, a filled arrowhead, and three
  /// chevron "fletching" pairs below it. The MetaPost macro sizes the
  /// fletching count from the point's scale parameter `sc`
  /// (`round(3+2*mlog(sc)/mlog 2)`); Mapiah's draw signature has no access
  /// to `sc`, so this always draws the `sc = 1` count (three pairs).
  static void _drawAirDraughtAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    final Path triangle = Path()
      ..moveTo(-0.2, -0.2)
      ..lineTo(0, -0.55)
      ..lineTo(0.2, -0.2)
      ..close();
    final Path chevrons = Path()
      ..moveTo(0, 0.8)
      ..lineTo(0.2, 1.0)
      ..moveTo(0, 0.8)
      ..lineTo(-0.2, 1.0)
      ..moveTo(0, 0.6)
      ..lineTo(0.2, 0.8)
      ..moveTo(0, 0.6)
      ..lineTo(-0.2, 0.8)
      ..moveTo(0, 0.4)
      ..lineTo(0.2, 0.6)
      ..moveTo(0, 0.4)
      ..lineTo(-0.2, 0.6);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawLine(const Offset(0, -0.5), const Offset(0, 0.8), pen);

        final Paint? fill = paint.fill;

        if (fill != null) {
          canvas.drawPath(triangle, fill);
        }

        canvas.drawPath(chevrons, pen);
      },
    );
  }

  /// `p_station_temporary_AUT`: `thclean fullcircle scaled 0.15u; thdraw
  /// fullcircle scaled 0.15u;` — a plain, background-cleared circle
  /// outline, radius `.075u`, `PenD` width. Under `symbol-set AUT`,
  /// `station`/`station:temporary` both render this way (`station` carries
  /// the "temporary" mark by default — see `MPTherionPointSymbolsSKBB`'s
  /// station doc comment for the same rule); `station:painted`/`:fixed`/
  /// `:natural` alias `p_station_fixed_ASF`, unported, and keep falling
  /// through to `thTrans.mp`'s own default (SKBB/ASF).
  static void _drawStationTemporaryAUT(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        MPThClean.drawPath(
          canvas: canvas,
          path: Path()
            ..addOval(Rect.fromCircle(center: Offset.zero, radius: 0.075)),
          backgroundColor: THPaint.thPaintWhiteBackground.color,
        );
        canvas.drawCircle(
          Offset.zero,
          0.075,
          _withPenWidth(paint.border!, mpTherionPenD),
        );
      },
    );
  }

  static void _drawSimplePath(
    Canvas canvas,
    Offset position,
    double u,
    Path path,
    Paint border,
  ) {
    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(path, _withPenWidth(border, mpTherionPenC));
      },
    );
  }
}
