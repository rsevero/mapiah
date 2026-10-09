// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';

import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/helpers/mp_thclean.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

/// Paints an already assembled line or area path: its base fill and stroke
/// (continuous or dashed), then its Therion decoration.
///
/// It reads no controller: the symbol unit, the dash scale and the stroke
/// widths already set on [linePaint] are explicit inputs, so the canvas
/// painter and the element-type previews share it. Painting runs in two
/// passes, [paintBase] then [paintDecoration], so a caller can draw between
/// them (the canvas draws line direction ticks there).
class MPLinePathPainter {
  final Path path;

  /// The path's knots, in order, as the decorator's `buildBasePath` reads
  /// them.
  final List<Offset> vertices;

  /// The path's segments with their line point metadata, as the decorator's
  /// `decorate` reads them.
  final List<THLinePainterLineSegment> lineSegments;

  final THLinePaint linePaint;
  final MPLineDecorator? lineDecorator;
  final Paint? lineDecoratorColor;
  final MPSymbolUnit symbolUnit;

  /// Canvas length of one dash-pattern length unit (one physical pixel at
  /// the canvas's zoom).
  final double dashScale;

  final bool isReversed;

  /// Seeds the decorator's procedural randomness.
  final int mpID;

  final bool showBorder;
  final THOptionChoicesArrowPositionType arrowHead;

  MPLinePathPainter({
    required this.path,
    required this.vertices,
    required this.lineSegments,
    required this.linePaint,
    required this.lineDecorator,
    required this.lineDecoratorColor,
    required this.symbolUnit,
    required this.dashScale,
    required this.isReversed,
    required this.mpID,
    required this.showBorder,
    required this.arrowHead,
  }) : assert(dashScale > 0),
       assert((lineDecorator == null) || (lineDecoratorColor != null));

  static final Map<MPLinePaintType, List<int>> linePaintTypeToDashLengths =
      <MPLinePaintType, List<int>>{
        MPLinePaintType.dot: <int>[2, -6],
        MPLinePaintType.long2Dots: <int>[18, -6, 2, -6, 2, -6],
        MPLinePaintType.long3Dots: <int>[18, -6, 2, -6, 2, -6, 2, -6],
        MPLinePaintType.long: <int>[18, -6],
        MPLinePaintType.longDot: <int>[18, -6, 2, -6],
        MPLinePaintType.medium2Dots: <int>[12, -6, 2, -6, 2, -6],
        MPLinePaintType.medium3Dots: <int>[12, -6, 2, -6, 2, -6, 2, -6],
        MPLinePaintType.medium: <int>[12, -6],
        MPLinePaintType.mediumDot: <int>[12, -6, 2, -6],
        MPLinePaintType.mediumEven: <int>[12, -12],
        MPLinePaintType.mediumLongMedium: <int>[12, -6, 18, -6, 12, -12],
        MPLinePaintType.short2Dots: <int>[6, -6, 2, -6, 2, -6],
        MPLinePaintType.short3Dots: <int>[6, -6, 2, -6, 2, -6, 2, -6],
        MPLinePaintType.short: <int>[6, -6],
        MPLinePaintType.shortDot: <int>[6, -6, 2, -6],
        MPLinePaintType.shortLongShort: <int>[6, -6, 18, -6, 6, -12],
        MPLinePaintType.shortMediumShort: <int>[6, -6, 12, -6, 6, -12],
      };

  /// The path the base and the decoration are drawn along.
  Path buildBasePath() {
    return lineDecorator?.buildBasePath(
          path: path,
          vertices: vertices,
          symbolUnit: symbolUnit,
        ) ??
        path;
  }

  /// Draws the fill (cleaning first when [THLinePaint.cleanBeforeFill]) and
  /// the continuous or dashed stroke. Draws nothing when a decorator is set:
  /// the decorator then draws the whole line.
  ///
  /// Widens each of [THLinePaint.highlightBorders] in place while drawing,
  /// as the canvas always did.
  void paintBase(Canvas canvas, Path basePath) {
    if (lineDecorator != null) {
      return;
    }

    if (linePaint.fillPaint != null) {
      if (linePaint.cleanBeforeFill) {
        MPThClean.drawPath(
          canvas: canvas,
          path: basePath,
          backgroundColor: THPaint.thPaintWhiteBackground.color,
        );
      }

      canvas.drawPath(basePath, linePaint.fillPaint!);
    }

    if (linePaint.type == MPLinePaintType.continuous) {
      _drawContinuousPath(canvas, basePath);
    } else {
      _drawDashedPath(canvas, basePath);
    }
  }

  /// Draws the decorator's symbols along [basePath], if there is one.
  void paintDecoration(Canvas canvas, Path basePath) {
    lineDecorator?.decorate(
      canvas: canvas,
      path: basePath,
      color: lineDecoratorColor!,
      symbolUnit: symbolUnit,
      isReversed: isReversed,
      mpID: mpID,
      lineSegments: lineSegments,
      showBorder: showBorder,
      arrowHead: arrowHead,
    );
  }

  void _drawContinuousPath(Canvas canvas, Path basePath) {
    _drawHighlightBorders(canvas, basePath);

    if (linePaint.primaryPaint != null) {
      canvas.drawPath(basePath, linePaint.primaryPaint!);
    } else if (linePaint.secondaryPaint != null) {
      canvas.drawPath(basePath, linePaint.secondaryPaint!);
    }
  }

  void _drawHighlightBorders(Canvas canvas, Path path) {
    if (linePaint.highlightBorders.isEmpty) {
      return;
    }

    int highlightBorderCount = linePaint.highlightBorders.length;

    for (final Paint highlightBorder in linePaint.highlightBorders.reversed) {
      final double highlightBorderStrokeFactor =
          ((highlightBorderCount * 2) + 1);

      canvas.drawPath(
        path,
        highlightBorder
          ..strokeWidth =
              highlightBorder.strokeWidth * highlightBorderStrokeFactor,
      );

      highlightBorderCount--;
    }
  }

  /// Dash code inspired by https://stackoverflow.com/a/71099304/11754455
  void _drawDashedPath(Canvas canvas, Path path) {
    final List<int> dashLengths = linePaintTypeToDashLengths[linePaint.type]!;
    final List<double> dashLengthsOnCanvas = <double>[
      for (final int length in dashLengths) length.toDouble() * dashScale,
    ];
    final MPDashedPathProperties dashedPathProperties = MPDashedPathProperties(
      dashLengths: dashLengthsOnCanvas,
    );
    final Path dashedPath = _getDashedPath(path, dashedPathProperties);

    _drawHighlightBorders(canvas, dashedPath);

    if (linePaint.secondaryPaint != null) {
      final MPDashedPathProperties invertedDashedPathProperties =
          MPDashedPathProperties(
            dashLengths: dashLengthsOnCanvas,
            invert: true,
          );
      final Path invertedDashedPath = _getDashedPath(
        path,
        invertedDashedPathProperties,
      );

      canvas.drawPath(invertedDashedPath, linePaint.secondaryPaint!);
    }

    if (linePaint.primaryPaint != null) {
      canvas.drawPath(dashedPath, linePaint.primaryPaint!);
    }
  }

  Path _getDashedPath(
    Path originalPath,
    MPDashedPathProperties dashedPathProperties,
  ) {
    final Iterator<PathMetric> metricsIterator = originalPath
        .computeMetrics()
        .iterator;

    while (metricsIterator.moveNext()) {
      final PathMetric metric = metricsIterator.current;

      dashedPathProperties.extractedPathLength = 0.0;
      while (dashedPathProperties.extractedPathLength < metric.length) {
        dashedPathProperties.addNext(metric);
      }
    }

    return dashedPathProperties.path;
  }
}
