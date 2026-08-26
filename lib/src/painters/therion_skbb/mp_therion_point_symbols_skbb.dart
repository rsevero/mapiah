// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/helpers/mp_thclean.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Faithful Dart ports of Therion's `p_*_SKBB` MetaPost point symbols
/// (Phase 4B). Same conventions as [MPTherionPointSymbolsUIS]: unit space,
/// canvas pre-translated/rotated/scaled, MetaPost Y-up coordinates negated.
///
/// `p_station_SKBB`'s mark-based dispatcher itself (and its `entrance`/
/// `sink`/`spring`/... text-flag overlays) is intentionally not ported: it
/// needs infrastructure Phase 4B doesn't add (station text integration), so
/// `station-name` keeps falling back to UIS/placeholder under
/// `therionSKBB`. But under an active `symbol-set SKBB`, Therion's
/// `mapsymbol` mechanism (`therion.mp`) overrides bare `p_station_temporary`
/// with `p_station_temporary_SKBB`, which `thPoint.mp` aliases to
/// `p_station_painted_SKBB` (`let p_station_temporary_SKBB =
/// p_station_painted_SKBB;`) — so under SKBB, `station` (no subtype, which
/// carries the "temporary" mark by default per `thpoint.cxx`),
/// `station:temporary`, and `station:painted` all render identically as
/// the plain circle below (verified against
/// `therion_skbb_showcase.pdf`). `station:fixed`/`station:natural` have no
/// SKBB-specific override and keep falling back (`p_station_fixed_ASF`/
/// `p_station_natural_ASF` are unported).
/// `p_handrail_SKBB` (sized from the survey's real-world paper scale, not
/// from the symbol unit `u`) is also intentionally not ported, so
/// `handrail` keeps falling back too.
abstract final class MPTherionPointSymbolsSKBB {
  static const Map<
    MPTherionPointSymbol,
    void Function(Canvas, Offset, double, MPTherionSymbolPaint)
  >
  drawMethods = {
    MPTherionPointSymbol.anchorSKBB: _drawAnchorSKBB,
    MPTherionPointSymbol.boreholeSKBB: _drawBoreholeSKBB,
    MPTherionPointSymbol.bridgeSKBB: _drawBridgeSKBB,
    MPTherionPointSymbol.campSKBB: _drawCampSKBB,
    MPTherionPointSymbol.cavePearlSKBB: _drawCavePearlSKBB,
    MPTherionPointSymbol.claySKBB: _drawClaySKBB,
    MPTherionPointSymbol.fixedLadderSKBB: _drawFixedLadderSKBB,
    MPTherionPointSymbol.gradientSKBB: _drawGradientSKBB,
    MPTherionPointSymbol.noEquipmentSKBB: _drawNoEquipmentSKBB,
    MPTherionPointSymbol.ropeLadderSKBB: _drawRopeLadderSKBB,
    MPTherionPointSymbol.ropeSKBB: _drawRopeSKBB,
    MPTherionPointSymbol.sinkSKBB: _drawSinkSKBB,
    MPTherionPointSymbol.snowSKBB: _drawSnowSKBB,
    MPTherionPointSymbol.springSKBB: _drawSpringSKBB,
    MPTherionPointSymbol.stationPaintedSKBB: _drawStationPaintedSKBB,
    MPTherionPointSymbol.stepsSKBB: _drawStepsSKBB,
    MPTherionPointSymbol.traverseSKBB: _drawTraverseSKBB,
    MPTherionPointSymbol.viaFerrataSKBB: _drawViaFerrataSKBB,
  };

  static Paint _withPenWidth(Paint paint, double penFactor) =>
      Paint.from(paint)..strokeWidth = penFactor;

  /// `unitsquare scaled .8u shifted (-.4u,-.4u)`: the `PenD` equipment-box
  /// outline shared by most `_SKBB` equipment point macros.
  static Path _equipmentBox() => Path()
    ..moveTo(-0.4, -0.4)
    ..lineTo(0.4, -0.4)
    ..lineTo(0.4, 0.4)
    ..lineTo(-0.4, 0.4)
    ..close();

  static void _drawEquipmentBox(
    Canvas canvas,
    Paint border,
    void Function() drawDetails,
  ) {
    canvas.drawPath(_equipmentBox(), _withPenWidth(border, mpTherionPenD));
    drawDetails();
  }

  static void _drawCavePearlSKBB(
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
        for (int k = 0; k < 3; k++) {
          canvas.save();
          canvas.rotate(k * 2 * math.pi / 3);
          canvas.drawCircle(const Offset(0, -0.16), 0.125, pen);
          canvas.restore();
        }
      },
    );
  }

  static void _drawClaySKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = MPDirectionalCurveAux.buildCurvePath(
      start: const Offset(-0.3, 0),
      end: const Offset(0, 0),
      startDirectionDegrees: -90,
      endDirectionDegrees: 90,
    );

    path.addPath(
      MPDirectionalCurveAux.buildCurvePath(
        start: const Offset(0, 0),
        end: const Offset(0.3, 0),
        startDirectionDegrees: -90,
        endDirectionDegrees: 90,
      ),
      Offset.zero,
    );

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(path, _withPenWidth(paint.border!, mpTherionPenC));
      },
    );
  }

  static void _drawSnowSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint pen = _withPenWidth(paint.border!, mpTherionPenC);
    final Path radial = Path()
      ..moveTo(0, 0)
      ..lineTo(0, -0.25);
    final Path chevron = Path()
      ..moveTo(-0.0707, -0.3207)
      ..lineTo(0, -0.25)
      ..lineTo(0.0707, -0.3207);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        for (int k = 0; k < 6; k++) {
          canvas.save();
          canvas.rotate(k * math.pi / 3);
          canvas.drawPath(radial, pen);
          canvas.drawPath(chevron, pen);
          canvas.restore();
        }
      },
    );
  }

  static void _drawSpringSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.3, -0.2)
      ..quadraticBezierTo(0, 0.6, 0.3, -0.2);

    _drawSimplePath(canvas, position, u, path, paint.border!);
  }

  static void _drawSinkSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Path path = Path()
      ..moveTo(-0.3, 0.2)
      ..quadraticBezierTo(0, -0.6, 0.3, 0.2);

    _drawSimplePath(canvas, position, u, path, paint.border!);
  }

  static void _drawStepsSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path stairs = Path()
      ..moveTo(-0.3, -0.3)
      ..lineTo(-0.3, -0.1)
      ..lineTo(-0.1, -0.1)
      ..lineTo(-0.1, 0.1)
      ..lineTo(0.1, 0.1)
      ..lineTo(0.1, 0.3)
      ..lineTo(0.3, 0.3);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawPath(stairs, _withPenWidth(border, mpTherionPenC));
        });
      },
    );
  }

  static void _drawBoreholeSKBB(
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
          canvas.drawCircle(Offset.zero, 0.315, fill);
        }

        canvas.drawCircle(
          Offset.zero,
          0.4,
          _withPenWidth(paint.border!, mpTherionPenD),
        );
      },
    );
  }

  /// `p_station_painted_SKBB`: `thclean fullcircle scaled 0.25u; thdraw
  /// fullcircle scaled 0.25u;` — a plain circle outline, background-cleared
  /// so it stays hollow over whatever it sits on.
  static void _drawStationPaintedSKBB(
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
          path: Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 0.125)),
          backgroundColor: THPaint.thPaintWhiteBackground.color,
        );
        canvas.drawOval(
          Rect.fromCircle(center: Offset.zero, radius: 0.125),
          _withPenWidth(paint.border!, mpTherionPenC),
        );
      },
    );
  }

  static void _drawFixedLadderSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path rungs = Path()
      ..moveTo(-0.15, -0.4)
      ..lineTo(-0.15, 0.4)
      ..moveTo(0.15, -0.4)
      ..lineTo(0.15, 0.4)
      ..moveTo(-0.15, 0)
      ..lineTo(0.15, 0)
      ..moveTo(-0.15, -0.2)
      ..lineTo(0.15, -0.2)
      ..moveTo(-0.15, 0.2)
      ..lineTo(0.15, 0.2);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawPath(rungs, _withPenWidth(border, mpTherionPenC));
        });
      },
    );
  }

  static void _drawRopeLadderSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path rails =
        MPDirectionalCurveAux.buildCurvePath(
          start: const Offset(0.1, 0.4),
          end: const Offset(0.2, 0.2),
          startDirectionDegrees: -60,
          endDirectionDegrees: -60,
        )
        ..addPath(
          MPDirectionalCurveAux.buildCurvePath(
            start: const Offset(0.2, 0.2),
            end: const Offset(0.1, -0.2),
            startDirectionDegrees: -120,
            endDirectionDegrees: -120,
          ),
          Offset.zero,
        )
        ..addPath(
          MPDirectionalCurveAux.buildCurvePath(
            start: const Offset(0.1, -0.2),
            end: const Offset(0.2, -0.4),
            startDirectionDegrees: -60,
            endDirectionDegrees: -60,
          ),
          Offset.zero,
        );
    final Path rails2 =
        MPDirectionalCurveAux.buildCurvePath(
          start: const Offset(-0.2, 0.4),
          end: const Offset(-0.1, 0.2),
          startDirectionDegrees: -60,
          endDirectionDegrees: -60,
        )
        ..addPath(
          MPDirectionalCurveAux.buildCurvePath(
            start: const Offset(-0.1, 0.2),
            end: const Offset(-0.2, -0.2),
            startDirectionDegrees: -120,
            endDirectionDegrees: -120,
          ),
          Offset.zero,
        )
        ..addPath(
          MPDirectionalCurveAux.buildCurvePath(
            start: const Offset(-0.2, -0.2),
            end: const Offset(-0.1, -0.4),
            startDirectionDegrees: -60,
            endDirectionDegrees: -60,
          ),
          Offset.zero,
        );
    final Path rungs = Path()
      ..moveTo(-0.2, -0.2)
      ..lineTo(0.1, -0.2)
      ..moveTo(-0.15, 0)
      ..lineTo(0.15, 0)
      ..moveTo(-0.1, 0.2)
      ..lineTo(0.2, 0.2);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          final Paint pen = _withPenWidth(border, mpTherionPenC);

          canvas.drawPath(rails, pen);
          canvas.drawPath(rails2, pen);
          canvas.drawPath(rungs, pen);
        });
      },
    );
  }

  static void _drawBridgeSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path deck = Path()
      ..moveTo(-0.3, -0.2)
      ..lineTo(-0.2, -0.1)
      ..lineTo(0.2, -0.1)
      ..lineTo(0.3, -0.2)
      ..moveTo(-0.3, 0.2)
      ..lineTo(-0.2, 0.1)
      ..lineTo(0.2, 0.1)
      ..lineTo(0.3, 0.2);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawPath(deck, _withPenWidth(border, mpTherionPenC));
        });
      },
    );
  }

  static void _drawNoEquipmentSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path triangle = Path()
      ..moveTo(0, 0.1)
      ..lineTo(-0.05, -0.3)
      ..lineTo(0.05, -0.3)
      ..close();

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          final Paint? fill = paint.fill;

          if (fill != null) {
            canvas.drawPath(triangle, fill);
          }

          canvas.drawCircle(
            const Offset(0, 0.2),
            mpTherionPenX / 2,
            Paint.from(border)..style = PaintingStyle.fill,
          );
        });
      },
    );
  }

  static void _drawAnchorSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawCircle(
            const Offset(0.2, 0),
            0.1,
            _withPenWidth(border, mpTherionPenC),
          );
          canvas.drawLine(
            const Offset(-0.3, 0),
            const Offset(0.1, 0),
            _withPenWidth(border, mpTherionPenA)..strokeCap = StrokeCap.butt,
          );
          canvas.drawLine(
            const Offset(0.1, -0.4),
            const Offset(0.1, 0.4),
            _withPenWidth(border, mpTherionPenD),
          );
        });
      },
    );
  }

  static void _drawTraverseSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path curve = Path()
      ..moveTo(-0.25, -0.05)
      ..quadraticBezierTo(0, 0.21, 0.25, -0.05);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawPath(curve, _withPenWidth(border, mpTherionPenC));

          final Paint dot = Paint.from(border)
            ..strokeWidth = 0.18
            ..strokeCap = StrokeCap.round;

          canvas.drawPoints(PointMode.points, const [
            Offset(-0.25, -0.05),
            Offset(0.25, -0.05),
          ], dot);
        });
      },
    );
  }

  static void _drawRopeSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path curve = Path()
      ..moveTo(-0.2, -0.2)
      ..quadraticBezierTo(0.05, 0.15, 0.1, -0.1)
      ..lineTo(0.1, 0.4);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawPath(curve, _withPenWidth(border, mpTherionPenC));

          final Paint dot = Paint.from(border)
            ..strokeWidth = 0.18
            ..strokeCap = StrokeCap.round;

          canvas.drawPoints(PointMode.points, const [
            Offset(-0.2, -0.2),
            Offset(0.1, -0.1),
          ], dot);
        });
      },
    );
  }

  static void _drawCampSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path tent = Path()
      ..moveTo(-0.4, 0.4)
      ..lineTo(0, -0.5)
      ..lineTo(0.4, 0.4)
      ..close();

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(tent, _withPenWidth(border, mpTherionPenC));
        canvas.drawLine(
          const Offset(0, 0.4),
          const Offset(0, -0.5),
          _withPenWidth(border, mpTherionPenD),
        );
      },
    );
  }

  static void _drawViaFerrataSKBB(
    Canvas canvas,
    Offset position,
    double u,
    MPTherionSymbolPaint paint,
  ) {
    final Paint border = paint.border!;
    final Path rungs = Path()
      ..moveTo(-0.15, -0.15)
      ..lineTo(-0.15, -0.1)
      ..lineTo(0.15, -0.1)
      ..lineTo(0.15, -0.15)
      ..moveTo(-0.15, 0.05)
      ..lineTo(-0.15, 0.1)
      ..lineTo(0.15, 0.1)
      ..lineTo(0.15, 0.05);

    MPSymbolTransform.draw(
      canvas: canvas,
      position: position,
      rotation: 0.0,
      scale: u,
      drawUnitSymbol: () {
        _drawEquipmentBox(canvas, border, () {
          canvas.drawPath(rungs, _withPenWidth(border, mpTherionPenC));
        });
      },
    );
  }

  static void _drawGradientSKBB(
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
        canvas.drawLine(const Offset(-0.3, -0.6), const Offset(-0.3, 0.6), pen);
        canvas.drawLine(const Offset(0, 0.6), const Offset(0, 0.2), pen);
        canvas.drawLine(const Offset(0.3, -0.6), const Offset(0.3, 0.6), pen);
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
