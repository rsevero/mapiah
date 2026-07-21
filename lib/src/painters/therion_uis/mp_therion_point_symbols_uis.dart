// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Faithful Dart ports of Therion's `p_*_UIS` MetaPost point symbols.
///
/// Every draw method works in unit space (coordinates expressed as
/// multiples of one symbol unit `u`, matching the `.mp` source literally)
/// with the canvas already translated/rotated/scaled by [MPSymbolTransform].
/// MetaPost is Y-up while the canvas is Y-down, so every coordinate
/// transcribed from `thPoint.mp` has its Y negated.
abstract final class MPTherionPointSymbolsUIS {
  static const Map<
    MPTherionPointSymbol,
    void Function(Canvas, Offset, double, Paint)
  >
  drawMethods = {
    MPTherionPointSymbol.continuationUIS: _drawContinuationUIS,
    MPTherionPointSymbol.crystalUIS: _drawCrystalUIS,
    MPTherionPointSymbol.digUIS: _drawDigUIS,
    MPTherionPointSymbol.entranceUIS: _drawEntranceUIS,
    MPTherionPointSymbol.flowstoneUIS: _drawFlowstoneUIS,
    MPTherionPointSymbol.fluteUIS: _drawFluteUIS,
    MPTherionPointSymbol.iceUIS: _drawIceUIS,
    MPTherionPointSymbol.karrenUIS: _drawKarrenUIS,
    MPTherionPointSymbol.lowEndUIS: _drawLowEndUIS,
    MPTherionPointSymbol.narrowEndUIS: _drawNarrowEndUIS,
    MPTherionPointSymbol.pillarUIS: _drawPillarUIS,
    MPTherionPointSymbol.sandUIS: _drawSandUIS,
    MPTherionPointSymbol.sodaStrawUIS: _drawSodaStrawUIS,
    MPTherionPointSymbol.stalactiteUIS: _drawStalactiteUIS,
    MPTherionPointSymbol.stalagmiteUIS: _drawStalagmiteUIS,
    MPTherionPointSymbol.wallCalciteUIS: _drawWallCalciteUIS,
  };

  static Paint _withPenWidth(Paint paint, double penFactor) {
    if (paint.style == PaintingStyle.fill) {
      return paint;
    }

    return Paint.from(paint)..strokeWidth = penFactor;
  }

  static void _drawStalactiteUIS(
    Canvas canvas,
    Offset position,
    double u,
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint topPen = _withPenWidth(paint, mpTherionPenC);
    final Paint strawPen = _withPenWidth(paint, mpTherionPenD);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenB);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        final Path path = Path();

        for (final double angleDeg in const <double>[0, 120, 240]) {
          final double angle = angleDeg * (math.pi / 180);
          final double cosA = math.cos(angle);
          final double sinA = math.sin(angle);

          path
            ..moveTo(0, 0)
            ..lineTo(-0.2 * sinA, -0.2 * cosA);
        }

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawIceUIS(
    Canvas canvas,
    Offset position,
    double u,
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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

        canvas.drawPath(path, pen);
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
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);

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

        canvas.drawPath(path, pen);
      },
    );
  }

  static void _drawContinuationUIS(
    Canvas canvas,
    Offset position,
    double u,
    Paint paint,
  ) {
    final Paint pen = _withPenWidth(paint, mpTherionPenC);
    final Paint dotPen = _withPenWidth(paint, mpTherionPenX)
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
}
