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

/// Faithful Dart ports of Therion's `p_*_UIS` MetaPost point symbols.
///
/// Every draw method works in unit space (coordinates expressed as
/// multiples of one symbol unit `u`, matching the `.mp` source literally)
/// with the canvas already translated/rotated/scaled by [MPSymbolTransform].
/// MetaPost is Y-up while the canvas is Y-down, so every coordinate
/// transcribed from `thPoint.mp` has its Y negated.
///
/// Each draw method is called exactly once per point, with the
/// [MPTherionSymbolPaint] declared for it in [mpTherionSymbolPaints]:
/// [MPTherionSymbolPaint.fill] and [MPTherionSymbolPaint.border] are
/// non-null exactly when that symbol's macro `thfill`s/`thdraw`s, so a
/// method never has to inspect a paint's style to know what to do with it.
abstract final class MPTherionPointSymbolsUIS {
  static const Map<
    MPTherionPointSymbol,
    void Function(Canvas, Offset, double, MPTherionSymbolPaint)
  >
  drawMethods = {
    MPTherionPointSymbol.airDraughtSummerUIS: _drawAirDraughtSummerUIS,
    MPTherionPointSymbol.airDraughtUIS: _drawAirDraughtUIS,
    MPTherionPointSymbol.airDraughtWinterUIS: _drawAirDraughtWinterUIS,
    MPTherionPointSymbol.anastomosisUIS: _drawAnastomosisUIS,
    MPTherionPointSymbol.archeoMaterialUIS: _drawArcheoMaterialUIS,
    MPTherionPointSymbol.blocksUIS: _drawBlocksUIS,
    MPTherionPointSymbol.campUIS: _drawCampUIS,
    MPTherionPointSymbol.continuationUIS: _drawContinuationUIS,
    MPTherionPointSymbol.crystalUIS: _drawCrystalUIS,
    MPTherionPointSymbol.curtainUIS: _drawCurtainUIS,
    MPTherionPointSymbol.diskUIS: _drawDiskUIS,
    MPTherionPointSymbol.digUIS: _drawDigUIS,
    MPTherionPointSymbol.entranceUIS: _drawEntranceUIS,
    MPTherionPointSymbol.flowstoneUIS: _drawFlowstoneUIS,
    MPTherionPointSymbol.fluteUIS: _drawFluteUIS,
    MPTherionPointSymbol.gradientUIS: _drawGradientUIS,
    MPTherionPointSymbol.guanoUIS: _drawGuanoUIS,
    MPTherionPointSymbol.helictiteUIS: _drawHelictiteUIS,
    MPTherionPointSymbol.iceUIS: _drawIceUIS,
    MPTherionPointSymbol.karrenUIS: _drawKarrenUIS,
    MPTherionPointSymbol.lowEndUIS: _drawLowEndUIS,
    MPTherionPointSymbol.moonmilkUIS: _drawMoonmilkUIS,
    MPTherionPointSymbol.narrowEndUIS: _drawNarrowEndUIS,
    MPTherionPointSymbol.paleoMaterialUIS: _drawPaleoMaterialUIS,
    MPTherionPointSymbol.pebblesUIS: _drawPebblesUIS,
    MPTherionPointSymbol.pillarUIS: _drawPillarUIS,
    MPTherionPointSymbol.pillarsUIS: _drawPillarsUIS,
    MPTherionPointSymbol.popcornUIS: _drawPopcornUIS,
    MPTherionPointSymbol.sandUIS: _drawSandUIS,
    MPTherionPointSymbol.scallopUIS: _drawScallopUIS,
    MPTherionPointSymbol.sodaStrawUIS: _drawSodaStrawUIS,
    MPTherionPointSymbol.stalactiteUIS: _drawStalactiteUIS,
    MPTherionPointSymbol.stalactitesUIS: _drawStalactitesUIS,
    MPTherionPointSymbol.stalagmiteUIS: _drawStalagmiteUIS,
    MPTherionPointSymbol.stalagmitesUIS: _drawStalagmitesUIS,
    MPTherionPointSymbol.wallCalciteUIS: _drawWallCalciteUIS,
    MPTherionPointSymbol.waterFlowIntermittentUIS:
        _drawWaterFlowIntermittentUIS,
    MPTherionPointSymbol.waterFlowPaleoUIS: _drawWaterFlowPaleoUIS,
    MPTherionPointSymbol.waterFlowPermanentUIS: _drawWaterFlowPermanentUIS,
    MPTherionPointSymbol.waterUIS: _drawWaterUIS,
  };

  static Paint _withPenWidth(Paint paint, double penFactor) =>
      Paint.from(paint)..strokeWidth = penFactor;

  static void _drawUnitPath({
    required Canvas canvas,
    required Offset position,
    required double u,
    required Paint paint,
    required Path path,
    double penFactor = mpTherionPenC,
  }) {
    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(path, _withPenWidth(paint, penFactor));
      },
    );
  }

  static void _drawCurtainUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.15, -0.4)
      ..lineTo(0, -0.15)
      ..lineTo(0.15, -0.4)
      ..moveTo(0, -0.15)
      ..lineTo(0, 0)
      ..cubicTo(-0.08, 0, -0.15, 0.11, -0.12, 0.11)
      ..cubicTo(-0.08, 0.11, -0.04, 0.22, 0, 0.22)
      ..lineTo(0, 0.4);

    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
    );
  }

  static void _drawHelictiteUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(0, -0.4)
      ..lineTo(0, 0.4)
      ..moveTo(-0.2, -0.4)
      ..lineTo(-0.2, -0.1)
      ..cubicTo(-0.2, -0.04, -0.15, -0.02, -0.1, -0.02)
      ..lineTo(0, 0)
      ..moveTo(0.2, 0.4)
      ..lineTo(0.2, 0.1)
      ..cubicTo(0.2, 0.04, 0.15, 0.02, 0.1, 0.02)
      ..lineTo(0, 0);

    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
    );
  }

  static void _drawMoonmilkUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.5, 0.2)
      ..cubicTo(-0.5, 0.02, -0.28, 0.02, -0.18, 0.105)
      ..cubicTo(-0.08, -0.08, 0.08, -0.08, 0.18, 0.105)
      ..cubicTo(0.28, 0.02, 0.5, 0.02, 0.5, 0.2);

    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
      penFactor: mpTherionPenB,
    );
  }

  static void _drawAnastomosisUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.5, 0.3)
      ..cubicTo(-0.49, 0.18, -0.34, 0.18, -0.32, 0.3)
      ..cubicTo(-0.3, 0.15, -0.3, -0.15, -0.28, -0.3)
      ..cubicTo(-0.26, -0.18, -0.14, -0.18, -0.12, -0.3)
      ..cubicTo(-0.1, -0.15, -0.1, 0.15, -0.08, 0.3)
      ..cubicTo(-0.06, 0.18, 0.06, 0.18, 0.08, 0.3)
      ..cubicTo(0.1, 0.15, 0.1, -0.15, 0.12, -0.3)
      ..cubicTo(0.14, -0.18, 0.26, -0.18, 0.28, -0.3)
      ..cubicTo(0.3, -0.15, 0.3, 0.15, 0.32, 0.3)
      ..cubicTo(0.34, 0.18, 0.49, 0.18, 0.5, 0.3);

    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
      penFactor: mpTherionPenB,
    );
  }

  static void _drawScallopUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(0, 0.4)
      ..cubicTo(-0.15, 0.18, -0.2, 0.02, -0.2, -0.1)
      ..cubicTo(-0.2, -0.3, 0.2, -0.3, 0.2, -0.1)
      ..cubicTo(0.2, 0.02, 0.15, 0.18, 0, 0.4);

    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
      penFactor: mpTherionPenB,
    );
  }

  static void _drawPopcornUIS(
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
        final Paint? fill = paint.fill;

        if (fill != null) {
          for (final double x in const <double>[-0.3, 0, 0.3]) {
            canvas.drawCircle(Offset(x, -0.1), 0.1, fill);
          }
        }

        final Paint? border = paint.border;

        if (border != null) {
          final Path path = Path()
            ..moveTo(-0.5, 0.2)
            ..lineTo(0.5, 0.2);
          for (final double x in const <double>[-0.3, 0, 0.3]) {
            path
              ..moveTo(x, 0.2)
              ..lineTo(x, -0.1);
          }
          canvas.drawPath(path, _withPenWidth(border, mpTherionPenC));
        }
      },
    );
  }

  static void _drawDiskUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.2, 0.3)
      ..lineTo(0, 0)
      ..lineTo(0.2, 0.3)
      ..addOval(Rect.fromCircle(center: const Offset(0, -0.15), radius: 0.15));
    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
      penFactor: mpTherionPenB,
    );
  }

  static void _drawPebblesUIS(
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
        final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
        const List<(Offset, double)> pebbles = <(Offset, double)>[
          (Offset(0, -0.25), -20),
          (Offset(0.25, 0.25), 37),
          (Offset(-0.25, 0.25), 62),
        ];
        for (final (Offset center, double degrees) in pebbles) {
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(degrees * math.pi / 180);
          canvas.drawOval(const Rect.fromLTRB(-0.2, -0.1, 0.2, 0.1), pen);
          canvas.restore();
        }
      },
    );
  }

  static void _drawArcheoMaterialUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.5, 0.5)
      ..lineTo(-0.2828, 0.2828)
      ..moveTo(-0.5, -0.5)
      ..lineTo(-0.2828, -0.2828)
      ..moveTo(0, 0)
      ..lineTo(0.4, 0)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 0.4));
    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
      penFactor: mpTherionPenB,
    );
  }

  static void _drawPaleoMaterialUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    // A bone silhouette: a shaft strip plus two pairs of round knuckles, all
    // four knuckles the same size and sitting right on top of the shaft's
    // two ends (so the shaft disappears under them), on one path relying on
    // the default nonZero fill to merge the overlaps — closer to
    // p_paleomaterial_UIS's own shape (each end of its node sequence bulges
    // into two close humps, not one) than either a single smooth knob per
    // end or Therion's raw node sequence hand-ported as one pinched Bezier
    // chain.
    final Path path = Path()
      ..moveTo(-0.2276, 0.2336)
      ..lineTo(-0.3324, 0.1264)
      ..lineTo(0.1276, -0.3236)
      ..lineTo(0.2324, -0.2164)
      ..close()
      ..addOval(
        Rect.fromCircle(center: const Offset(-0.2101, 0.2515), radius: 0.105),
      )
      ..addOval(
        Rect.fromCircle(center: const Offset(-0.3499, 0.1085), radius: 0.105),
      )
      ..addOval(
        Rect.fromCircle(center: const Offset(0.2499, -0.1985), radius: 0.105),
      )
      ..addOval(
        Rect.fromCircle(center: const Offset(0.1101, -0.3415), radius: 0.105),
      );

    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.fill!,
      path: path,
    );
  }

  static void _drawGuanoUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    // p_guano_UIS: (-.4u,.2u){dir 40}..{down}(0,-.35u){up}..{dir-40}(.4u,.2u),
    // with MetaPost's resolved control points (Y-up) negated for the canvas;
    // the vertical tangents at the midpoint give the V bottom.
    final Path path = Path()
      ..moveTo(-0.4, -0.2)
      ..cubicTo(-0.2117, -0.3580, 0, -0.0542, 0, 0.35)
      ..cubicTo(0, -0.0542, 0.2117, -0.3580, 0.4, -0.2);
    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: path,
      penFactor: mpTherionPenB,
    );
  }

  static void _drawArrowPoint(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint, {
    required bool paleo,
  }) {
    final Path arrow = Path()
      ..moveTo(-0.15, -0.6)
      ..lineTo(0, -1)
      ..lineTo(0.15, -0.6)
      ..close();

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Paint? fill = paint.fill;

        if (fill != null) {
          canvas.drawPath(arrow, fill);
        }

        final Paint? border = paint.border;

        if (border != null) {
          final Path stroke = Path()
            ..moveTo(0, 1)
            ..lineTo(0, -1);
          if (paleo) {
            stroke.addArc(
              const Rect.fromLTRB(-0.2, 0.2, 0.2, 0.6),
              math.pi,
              math.pi,
            );
          }
          canvas.drawPath(
            stroke..addPath(arrow, Offset.zero),
            _withPenWidth(border, mpTherionPenC),
          );
        }
      },
    );
  }

  static void _drawWaterFlowPaleoUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    _drawArrowPoint(canvas, position, u, paint, paleo: true);
  }

  static void _drawGradientUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    _drawArrowPoint(canvas, position, u, paint, paleo: false);
  }

  static Path _waterFlowPath() => Path()
    ..moveTo(0, 0.5)
    ..cubicTo(-0.02, 0.4, -0.12, 0.3, -0.12, 0.3)
    ..cubicTo(-0.12, 0.23, 0.15, 0.18, 0.15, 0.15)
    ..cubicTo(0.15, 0.08, -0.13, 0.04, -0.13, 0)
    ..cubicTo(-0.13, -0.08, 0.08, -0.14, 0.08, -0.2)
    ..cubicTo(0.08, -0.32, 0, -0.42, 0, -0.5);

  static void _drawWaterFlowPermanentUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path arrow = Path()
      ..moveTo(-0.09, -0.35)
      ..lineTo(0, -0.5)
      ..lineTo(0.09, -0.35)
      ..close();

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Paint? fill = paint.fill;

        if (fill != null) {
          canvas.drawPath(arrow, fill);
        }

        final Paint? border = paint.border;

        if (border != null) {
          canvas.drawPath(
            _waterFlowPath()..addPath(arrow, Offset.zero),
            _withPenWidth(border, mpTherionPenB),
          );
        }
      },
    );
  }

  static void _drawWaterFlowIntermittentUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint? fill = paint.fill;

    if (fill != null) {
      _drawWaterFlowPermanentUIS(
        canvas,
        position,
        u,
        MPTherionSymbolPaint(fill: fill),
      );
    }

    final Paint? border = paint.border;

    if (border == null) {
      return;
    }

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = _waterFlowPath();
        final PathMetric metric = path.computeMetrics().first;
        final Path dashed = Path();
        const double dash = 0.08;
        const double gap = 0.06;
        double distance = 0;
        while (distance < metric.length) {
          dashed.addPath(
            metric.extractPath(
              distance,
              math.min(distance + dash, metric.length),
            ),
            Offset.zero,
          );
          distance += dash + gap;
        }
        canvas.drawPath(
          dashed,
          _withPenWidth(border, mpTherionPenB)..strokeCap = StrokeCap.butt,
        );
        final Path arrow = Path()
          ..moveTo(-0.09, -0.35)
          ..lineTo(0, -0.5)
          ..lineTo(0.09, -0.35)
          ..close();
        canvas.drawPath(arrow, _withPenWidth(border, mpTherionPenB));
      },
    );
  }

  static void _drawCampUIS(
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
        final Paint? fill = paint.fill;

        if (fill != null) {
          final Path filled = Path()
            ..moveTo(-0.3, 0.4)
            ..lineTo(0, -0.3)
            ..lineTo(0.3, 0.4)
            ..close()
            ..moveTo(0, -0.5)
            ..lineTo(0.35, -0.45)
            ..lineTo(0.07, -0.35)
            ..close();
          canvas.drawPath(filled, fill);
        }

        final Paint? border = paint.border;

        if (border != null) {
          final Path stroked = Path()
            ..moveTo(-0.5, 0.4)
            ..lineTo(0.5, 0.4)
            ..moveTo(-0.4, 0.4)
            ..lineTo(0, -0.5)
            ..lineTo(0.4, 0.4);
          canvas.drawPath(stroked, _withPenWidth(border, mpTherionPenC));
        }
      },
    );
  }

  static void _drawStalactiteUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(0, 0.4)
          ..lineTo(0, -0.15)
          ..lineTo(-0.15, -0.4)
          ..moveTo(0, -0.15)
          ..lineTo(0.15, -0.4);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawStalagmiteUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(0, -0.4)
          ..lineTo(0, 0.15)
          ..lineTo(-0.15, 0.4)
          ..moveTo(0, 0.15)
          ..lineTo(0.15, 0.4);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawPillarUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(0, -0.15)
          ..lineTo(0, 0.15)
          ..moveTo(-0.15, 0.4)
          ..lineTo(0, 0.15)
          ..lineTo(0.15, 0.4)
          ..moveTo(-0.15, -0.4)
          ..lineTo(0, -0.15)
          ..lineTo(0.15, -0.4);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawSodaStrawUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint topPen = _withPenWidth(paint.border!, mpTherionPenC);
    final Paint strawPen = _withPenWidth(paint.border!, mpTherionPenD);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawLine(
          const Offset(-0.5, -0.2),
          const Offset(0.5, -0.2),
          topPen,
        );

        final Path straws = Path()
          ..moveTo(-0.4, -0.2)
          ..lineTo(-0.4, 0)
          ..moveTo(-0.12, -0.2)
          ..lineTo(-0.12, 0.25)
          ..moveTo(0.02, -0.2)
          ..lineTo(0.02, 0.1)
          ..moveTo(0.23, -0.2)
          ..lineTo(0.23, 0.19)
          ..moveTo(0.35, -0.2)
          ..lineTo(0.35, 0.15);

        canvas.drawPath(straws, strawPen);
      },
    );
  }

  static void _drawCrystalUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    // p_crystal_UIS actually uses PenC; bumped to PenB here since PenC's
    // diagonal strokes read as jaggy at typical zoom (a thin line doesn't
    // give antialiasing enough coverage width to smooth a diagonal edge).
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path();

        for (final double angleDeg in const <double>[0, 60, 120]) {
          final double angle = angleDeg * (math.pi / 180);
          final double cosA = math.cos(angle);
          final double sinA = math.sin(angle);

          path
            ..moveTo(-0.35 * cosA, 0.35 * sinA)
            ..lineTo(0.35 * cosA, -0.35 * sinA);
        }

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawFlowstoneUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(0.15, 0.1)
          ..lineTo(0.45, 0.1)
          ..moveTo(-0.45, 0.1)
          ..lineTo(-0.15, 0.1)
          ..moveTo(-0.15, -0.1)
          ..lineTo(0.15, -0.1);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawWallCalciteUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(-0.2, 0.2)
          ..lineTo(0, -0.1)
          ..lineTo(0.2, 0.2);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawKarrenUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        Path buildStroke(double dx) {
          return Path()
            ..moveTo(-0.4 + dx, 0.2)
            ..lineTo(-0.3 + dx, 0.3)
            ..lineTo(0 + dx, -0.3)
            ..lineTo(0.1 + dx, -0.2);
        }

        final Path path = Path()
          ..addPath(buildStroke(0), Offset.zero)
          ..addPath(buildStroke(0.3), Offset.zero);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawFluteUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawLine(const Offset(-0.5, -0.2), const Offset(0.5, -0.2), pen);

        final Path groove = Path()
          ..moveTo(-0.3, -0.2)
          ..quadraticBezierTo(0, 0.05, 0.3, -0.2);

        canvas.drawPath(groove, pen);
      },
    );
  }

  static void _drawNarrowEndUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(-0.1, -0.4)
          ..lineTo(-0.1, 0.4)
          ..moveTo(0.1, -0.4)
          ..lineTo(0.1, 0.4);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawLowEndUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path()
          ..moveTo(-0.4, -0.1)
          ..lineTo(0.4, -0.1)
          ..moveTo(-0.4, 0.1)
          ..lineTo(0.4, 0.1);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawSandUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    // Therion's p_sand_UIS `thdraw`s three zero-length paths with a round
    // pen, i.e. three dots 0.2u from the center at 0/120/240 degrees, not
    // radial lines.
    final Paint dot = Paint()
      ..color = paint.border!.color
      ..style = PaintingStyle.fill;
    final double radius = mpTherionPenB / 2;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        for (final double angleDeg in const <double>[0, 120, 240]) {
          final double angle = angleDeg * (math.pi / 180);
          final double cosA = math.cos(angle);
          final double sinA = math.sin(angle);

          canvas.drawCircle(Offset(-0.2 * sinA, -0.2 * cosA), radius, dot);
        }
      },
    );
  }

  static void _drawIceUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        Path buildCrystal(double dx, double dy) {
          return Path()
            ..moveTo(dx, -0.05 + dy)
            ..lineTo(dx, -0.35 + dy)
            ..moveTo(-0.15 + dx, -0.2 + dy)
            ..lineTo(0.15 + dx, -0.2 + dy);
        }

        final Path path = Path()
          ..addPath(buildCrystal(0, 0), Offset.zero)
          ..addPath(buildCrystal(-0.25, 0.3), Offset.zero)
          ..addPath(buildCrystal(0.25, 0.3), Offset.zero);

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawEntranceUIS(
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
        final Path path = Path()
          ..moveTo(-0.2, 0.5)
          ..lineTo(0, -0.5)
          ..lineTo(0.2, 0.5)
          ..close();

        final Paint? fill = paint.fill;

        if (fill != null) {
          canvas.drawPath(path, fill);
        }

        final Paint? border = paint.border;

        if (border != null) {
          canvas.drawPath(path, _withPenWidth(border, mpTherionPenC));
        }
      },
    );
  }

  /// `p_dig_UIS`'s shape rotated 45 degrees; vertices are precomputed
  /// (rotated in MetaPost's Y-up space, then Y-negated for the canvas) since
  /// the small connecting arc at the top is approximated as a straight line.
  static void _drawDigUIS(
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
        final Path path = Path()
          ..moveTo(0.3005, 0.4066)
          ..lineTo(0.4066, 0.3005)
          ..lineTo(-0.0530, -0.1591)
          ..lineTo(0.1061, -0.3182)
          ..lineTo(-0.1414, -0.5657)
          ..lineTo(-0.5657, -0.1414)
          ..lineTo(-0.3182, 0.1061)
          ..lineTo(-0.1591, -0.0530)
          ..close();

        final Paint? fill = paint.fill;

        if (fill != null) {
          canvas.drawPath(path, fill);
        }

        final Paint? border = paint.border;

        if (border != null) {
          canvas.drawPath(path, _withPenWidth(border, mpTherionPenC));
        }
      },
    );
  }

  static void _drawContinuationUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);
    final Paint dotPen = _withPenWidth(paint.border!, mpTherionPenX)
      ..strokeCap = StrokeCap.round;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path curve = Path()
          ..moveTo(-0.1, -0.2)
          ..quadraticBezierTo(0, -0.35, 0.1, -0.2)
          ..quadraticBezierTo(0.08, -0.08, 0, 0.05);

        canvas.drawPath(curve, pen);
        canvas.drawLine(const Offset(0, 0.2), const Offset(0, 0.2), dotPen);
      },
    );
  }

  static void _drawBlocksUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint outlinePen = _withPenWidth(paint.border!, mpTherionPenC);
    final Paint detailPen = _withPenWidth(paint.border!, mpTherionPenD);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path outline = Path()
          ..moveTo(-0.5, 0.5)
          ..lineTo(0.3, 0.4)
          ..lineTo(-0.17, -0.2)
          ..close()
          ..moveTo(0.25, 0.25)
          ..lineTo(0.5, 0.15)
          ..lineTo(0.3, -0.5)
          ..lineTo(-0.1, -0.5)
          ..close()
          ..moveTo(-0.27, 0)
          ..lineTo(-0.1, -0.3)
          ..lineTo(-0.5, -0.35)
          ..close();
        final Path detail = Path()
          ..moveTo(-0.5, 0.5)
          ..lineTo(-0.1, 0.2)
          ..lineTo(-0.17, -0.2)
          ..moveTo(-0.1, 0.2)
          ..lineTo(0.3, 0.4)
          ..moveTo(0.25, 0.25)
          ..lineTo(0.3, 0)
          ..lineTo(0.2, -0.2)
          ..lineTo(-0.1, -0.5)
          ..moveTo(0.3, -0.5)
          ..lineTo(0.2, -0.2)
          ..moveTo(0.5, 0.15)
          ..lineTo(0.3, 0);

        canvas.drawPath(outline, outlinePen);
        canvas.drawPath(detail, detailPen);
      },
    );
  }

  static void _drawWaterUIS(
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
          for (double offset = -0.8; offset <= 0.8; offset += 0.18) {
            canvas.drawLine(
              Offset(offset - 1, -1),
              Offset(offset + 1, 1),
              hatchPen,
            );
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

  /// Shared geometry for `p_airdraught_UIS` and its winter/summer variants:
  /// a vertical stem, symmetric wing curves, and three ascending hash marks.
  /// The hash-mark count depends on Therion's per-symbol `sc` scale factor
  /// (`round(3 + 2*log2(sc))`); Mapiah has no equivalent per-point scale
  /// knob beyond the global symbol unit, so `sc` is treated as always 1
  /// (matching every other ported symbol), which fixes the count at 3.
  static Path _airDraughtBasePath() {
    // The wings ({dir 20}..{dir 90}, mirrored) leave their base moving
    // mostly horizontally (toward the stem) and only curve up to vertical
    // near the tip, so each hugs the stem for most of its rise and flares
    // out to its base near the bottom — not a uniform semicircular bulge.
    final Path path = Path()
      ..moveTo(0, -1)
      ..lineTo(0, 0.8)
      ..moveTo(-0.2, -0.65)
      ..cubicTo(-0.0737, -0.696, 0, -0.8656, 0, -1)
      ..moveTo(0.2, -0.65)
      ..cubicTo(0.0737, -0.696, 0, -0.8656, 0, -1);

    for (int i = 1; i <= 3; i++) {
      final double y1 = 1 - (0.2 * i);
      final double y2 = 1 - (0.2 * (i - 1));

      path
        ..moveTo(0, y1)
        ..lineTo(0.2, y2);
    }

    return path;
  }

  static void _drawAirDraughtUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    _drawUnitPath(
      canvas: canvas,
      position: position,
      u: u,
      paint: paint.border!,
      path: _airDraughtBasePath(),
    );
  }

  static void _drawAirDraughtWinterUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(_airDraughtBasePath(), pen);
        MPThClean.drawPath(
          canvas: canvas,
          path: Path()
            ..addOval(
              Rect.fromCircle(center: const Offset(0, -0.05), radius: 0.3),
            ),
          backgroundColor: THPaint.thPaintWhiteBackground.color,
        );

        final Path cross = Path()
          ..moveTo(-0.1732, 0.05)
          ..lineTo(0.1732, -0.15)
          ..moveTo(0.1732, 0.05)
          ..lineTo(-0.1732, -0.15)
          ..moveTo(0, 0.15)
          ..lineTo(0, -0.25);

        canvas.drawPath(cross, pen);
      },
    );
  }

  static void _drawAirDraughtSummerUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(_airDraughtBasePath(), pen);
        MPThClean.drawPath(
          canvas: canvas,
          path: Path()
            ..addOval(
              Rect.fromCircle(center: const Offset(0, -0.05), radius: 0.3),
            ),
          backgroundColor: THPaint.thPaintWhiteBackground.color,
        );

        final Path cross = Path()
          ..moveTo(-0.1732, 0.05)
          ..lineTo(0.1732, -0.15)
          ..moveTo(0.1732, 0.05)
          ..lineTo(-0.1732, -0.15)
          ..moveTo(0, 0.15)
          ..lineTo(0, -0.25);

        canvas.drawPath(cross, pen);
        MPThClean.drawPath(
          canvas: canvas,
          path: Path()
            ..addOval(
              Rect.fromCircle(center: const Offset(0, -0.05), radius: 0.15),
            ),
          backgroundColor: THPaint.thPaintWhiteBackground.color,
        );
        canvas.drawOval(
          Rect.fromCircle(center: const Offset(0, -0.05), radius: 0.1),
          pen,
        );
      },
    );
  }

  /// Shared geometry for a group of three `0.7`-scaled sub-symbols spaced
  /// `0.3u` apart, matching `p_stalagmites_UIS`/`p_stalactites_UIS`/
  /// `p_pillars_UIS`'s loops. Therion's `pickup PenC` fixes the pen at an
  /// absolute width unaffected by the sub-symbols' `sc*0.7` scale, so the
  /// sub-shape geometry itself (not the ambient canvas transform) is
  /// pre-scaled by 0.7, keeping the stroke width constant across instances.
  static Path _repeatedSubSymbolsPath(
    void Function(Path path, double dx) buildInstance,
  ) {
    final Path path = Path();

    for (final double index in const <double>[-1, 0, 1]) {
      buildInstance(path, index * 0.3);
    }

    return path;
  }

  static void _drawStalagmitesUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);
    final Path path = _repeatedSubSymbolsPath((Path path, double dx) {
      path
        ..moveTo(dx, -0.28)
        ..lineTo(dx, 0.105)
        ..lineTo(dx - 0.105, 0.28)
        ..moveTo(dx, 0.105)
        ..lineTo(dx + 0.105, 0.28);
    });

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

  static void _drawStalactitesUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);
    final Path path = _repeatedSubSymbolsPath((Path path, double dx) {
      path
        ..moveTo(dx, 0.28)
        ..lineTo(dx, -0.105)
        ..lineTo(dx - 0.105, -0.28)
        ..moveTo(dx, -0.105)
        ..lineTo(dx + 0.105, -0.28);
    });

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

  static void _drawPillarsUIS(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenB);
    final Path path = _repeatedSubSymbolsPath((Path path, double dx) {
      path
        ..moveTo(dx, -0.105)
        ..lineTo(dx, 0.105)
        ..moveTo(dx - 0.105, 0.28)
        ..lineTo(dx, 0.105)
        ..lineTo(dx + 0.105, 0.28)
        ..moveTo(dx - 0.105, -0.28)
        ..lineTo(dx, -0.105)
        ..lineTo(dx + 0.105, -0.28);
    });

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
}
