// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_label_data.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_label_paint.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/types/th_label_size.dart';

/// Draws Phase 2.5 text-mode point labels: plain text with a white
/// background box, and the passage-height decorated containers
/// (`process_uplabel`/`process_downlabel`/`process_updownlabel` in Therion).
abstract final class MPLabelPainter {
  /// Readability floor from the roadmap: font size never shrinks below this
  /// many logical screen pixels, unlike geometric symbols which keep
  /// shrinking with zoom.
  static const double _minFontSizePixels = 8;

  static const double _horizontalMarginFactor = 0.35;
  static const double _verticalMarginFactor = 0.25;
  static const double _lineSpacingFactor = 0.15;

  /// Draws [labelPaint] anchored at [anchor]. The canvas [MPInteractionAux]
  /// hands to point painters is never pre-rotated by a point's own
  /// orientation (unlike the Therion *symbol* path, which wraps its drawing
  /// in `canvas.rotate(pointPaint.rotation)`), so simply not rotating here
  /// already reproduces Therion's `horiz_labels` behaviour: labels always
  /// stay upright regardless of the point's orientation option.
  static void drawTherionLabel({
    required Canvas canvas,
    required MPLabelPaint labelPaint,
    required Offset anchor,
    required MPSymbolUnit symbolUnit,
  }) {
    final double fontSize = _resolveFontSize(labelPaint.size, symbolUnit);

    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);

    switch (labelPaint.data.mode) {
      case MPLabelMode.plain:
        _drawPlain(canvas, labelPaint, fontSize);
      case MPLabelMode.passageHeightPos:
        _drawPassageHeightPos(canvas, labelPaint, fontSize);
      case MPLabelMode.passageHeightNeg:
        _drawPassageHeightNeg(canvas, labelPaint, fontSize);
      case MPLabelMode.passageHeightPosNeg:
        _drawPassageHeightPosNeg(canvas, labelPaint, fontSize);
      case MPLabelMode.passageHeightUnsigned:
        _drawPassageHeightUnsigned(canvas, labelPaint, fontSize);
    }

    canvas.restore();
  }

  static double _resolveFontSize(THLabelSize size, MPSymbolUnit symbolUnit) {
    final double fontSize = symbolUnit.canvasValue * size.multiplier;
    final double minFontSize =
        _minFontSizePixels / (symbolUnit.canvasScale * symbolUnit.devicePixelRatio);

    return fontSize < minFontSize ? minFontSize : fontSize;
  }

  static void _drawPlain(
    Canvas canvas,
    MPLabelPaint labelPaint,
    double fontSize,
  ) {
    final _TextBlock block = _TextBlock.layOut(
      lines: labelPaint.data.lines,
      fontSize: fontSize,
      color: labelPaint.textColor,
    );
    final double marginX = fontSize * _horizontalMarginFactor;
    final double marginY = fontSize * _verticalMarginFactor;
    final Size boxSize = Size(
      block.width + (marginX * 2),
      block.height + (marginY * 2),
    );
    final Offset boxOrigin = _boxOrigin(labelPaint.align, boxSize);
    final Rect box = boxOrigin & boxSize;

    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(marginY)),
      labelPaint.backgroundFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(marginY)),
      labelPaint.backgroundBorder,
    );
    block.paint(canvas, Offset(box.left + marginX, box.top + marginY));
  }

  static void _drawPassageHeightPos(
    Canvas canvas,
    MPLabelPaint labelPaint,
    double fontSize,
  ) {
    final _TextBlock block = _TextBlock.layOut(
      lines: [labelPaint.data.plusText ?? ''],
      fontSize: fontSize,
      color: labelPaint.textColor,
    );
    final Rect box = _containerBox(labelPaint.align, block, fontSize);

    canvas.drawPath(
      _topRoundedContainer(box),
      labelPaint.backgroundFill,
    );
    canvas.drawPath(
      _topRoundedContainer(box),
      labelPaint.backgroundBorder,
    );
    block.paintCentered(canvas, box);
  }

  static void _drawPassageHeightNeg(
    Canvas canvas,
    MPLabelPaint labelPaint,
    double fontSize,
  ) {
    final _TextBlock block = _TextBlock.layOut(
      lines: [labelPaint.data.minusText ?? ''],
      fontSize: fontSize,
      color: labelPaint.textColor,
    );
    final Rect box = _containerBox(labelPaint.align, block, fontSize);

    canvas.drawPath(
      _bottomRoundedContainer(box),
      labelPaint.backgroundFill,
    );
    canvas.drawPath(
      _bottomRoundedContainer(box),
      labelPaint.backgroundBorder,
    );
    block.paintCentered(canvas, box);
  }

  static void _drawPassageHeightPosNeg(
    Canvas canvas,
    MPLabelPaint labelPaint,
    double fontSize,
  ) {
    final _TextBlock plusBlock = _TextBlock.layOut(
      lines: [labelPaint.data.plusText ?? ''],
      fontSize: fontSize,
      color: labelPaint.textColor,
    );
    final _TextBlock minusBlock = _TextBlock.layOut(
      lines: [labelPaint.data.minusText ?? ''],
      fontSize: fontSize,
      color: labelPaint.textColor,
    );
    final double marginX = fontSize * _horizontalMarginFactor;
    final double marginY = fontSize * _verticalMarginFactor;
    final double halfHeight = (plusBlock.height > minusBlock.height
            ? plusBlock.height
            : minusBlock.height) +
        marginY;
    final double width =
        (plusBlock.width > minusBlock.width ? plusBlock.width : minusBlock.width) +
        (marginX * 2);
    final Size boxSize = Size(width, halfHeight * 2);
    final Offset boxOrigin = _boxOrigin(labelPaint.align, boxSize);
    final Rect box = boxOrigin & boxSize;

    canvas.drawOval(box, labelPaint.backgroundFill);
    canvas.drawOval(box, labelPaint.backgroundBorder);
    canvas.drawLine(
      Offset(box.left, box.center.dy),
      Offset(box.right, box.center.dy),
      labelPaint.backgroundBorder,
    );

    plusBlock.paintCentered(canvas, Rect.fromLTRB(box.left, box.top, box.right, box.center.dy));
    minusBlock.paintCentered(
      canvas,
      Rect.fromLTRB(box.left, box.center.dy, box.right, box.bottom),
    );
  }

  static void _drawPassageHeightUnsigned(
    Canvas canvas,
    MPLabelPaint labelPaint,
    double fontSize,
  ) {
    final _TextBlock block = _TextBlock.layOut(
      lines: [labelPaint.data.plusText ?? ''],
      fontSize: fontSize,
      color: labelPaint.textColor,
    );
    final double marginX = fontSize * _horizontalMarginFactor;
    final double marginY = fontSize * _verticalMarginFactor;
    final Size boxSize = Size(
      block.width + (marginX * 2),
      block.height + (marginY * 2),
    );
    final Offset boxOrigin = _boxOrigin(labelPaint.align, boxSize);
    final Rect box = boxOrigin & boxSize;

    canvas.drawRect(box, labelPaint.backgroundFill);
    canvas.drawRect(box, labelPaint.backgroundBorder);
    block.paint(canvas, Offset(box.left + marginX, box.top + marginY));
  }

  static Rect _containerBox(
    THOptionChoicesAlignType align,
    _TextBlock block,
    double fontSize,
  ) {
    final double marginX = fontSize * _horizontalMarginFactor;
    final double marginY = fontSize * _verticalMarginFactor;
    final double radius = (block.width + (marginX * 2)) / 2;
    final Size boxSize = Size(radius * 2, block.height + (marginY * 2) + radius);
    final Offset boxOrigin = _boxOrigin(align, boxSize);

    return boxOrigin & boxSize;
  }

  /// A semicircular bulge on top (radius = half the box width), flat bottom.
  static Path _topRoundedContainer(Rect box) {
    final double radius = box.width / 2;
    final double straightTop = box.top + radius;

    return Path()
      ..moveTo(box.left, box.bottom)
      ..lineTo(box.left, straightTop)
      ..arcToPoint(
        Offset(box.right, straightTop),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(box.right, box.bottom)
      ..close();
  }

  /// A semicircular bulge on the bottom (radius = half the box width), flat
  /// top.
  static Path _bottomRoundedContainer(Rect box) {
    final double radius = box.width / 2;
    final double straightBottom = box.bottom - radius;

    return Path()
      ..moveTo(box.left, box.top)
      ..lineTo(box.left, straightBottom)
      ..arcToPoint(
        Offset(box.right, straightBottom),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(box.right, box.top)
      ..close();
  }

  /// Returns the top-left corner of a box of [boxSize] such that the corner
  /// or edge named by [align] sits at the origin (the anchor point), mirroring
  /// Therion's `.urt`/`.ulft`/etc. label alignment macros: e.g. `topRight`
  /// means the text appears up and to the right of the anchor, so the
  /// anchor is the box's bottom-left corner.
  static Offset _boxOrigin(THOptionChoicesAlignType align, Size boxSize) {
    final double width = boxSize.width;
    final double height = boxSize.height;

    switch (align) {
      case THOptionChoicesAlignType.topLeft:
        return Offset(-width, -height);
      case THOptionChoicesAlignType.top:
        return Offset(-width / 2, -height);
      case THOptionChoicesAlignType.topRight:
        return Offset(0, -height);
      case THOptionChoicesAlignType.left:
        return Offset(-width, -height / 2);
      case THOptionChoicesAlignType.center:
        return Offset(-width / 2, -height / 2);
      case THOptionChoicesAlignType.right:
        return Offset(0, -height / 2);
      case THOptionChoicesAlignType.bottomLeft:
        return Offset(-width, 0);
      case THOptionChoicesAlignType.bottom:
        return Offset(-width / 2, 0);
      case THOptionChoicesAlignType.bottomRight:
        return Offset(0, 0);
    }
  }
}

/// Lays out one [TextPainter] per line and exposes the combined block size.
class _TextBlock {
  final List<TextPainter> painters;
  final double width;
  final double height;

  const _TextBlock._(this.painters, this.width, this.height);

  factory _TextBlock.layOut({
    required List<String> lines,
    required double fontSize,
    required Color color,
  }) {
    final TextStyle style = TextStyle(fontSize: fontSize, color: color);
    final List<TextPainter> painters = lines.map((String line) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: line, style: style),
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      return painter;
    }).toList();

    final double width = painters.fold(
      0.0,
      (double previous, TextPainter painter) =>
          previous > painter.width ? previous : painter.width,
    );
    final double lineSpacing = fontSize * MPLabelPainter._lineSpacingFactor;
    final int lineGapCount = painters.isEmpty ? 0 : painters.length - 1;
    final double height =
        painters.fold(
          0.0,
          (double sum, TextPainter painter) => sum + painter.height,
        ) +
        (lineSpacing * lineGapCount);

    return _TextBlock._(painters, width, height);
  }

  void paint(Canvas canvas, Offset topLeft) {
    double dy = topLeft.dy;
    final double lineSpacing = painters.isEmpty
        ? 0.0
        : painters.first.height * MPLabelPainter._lineSpacingFactor;

    for (final TextPainter painter in painters) {
      painter.paint(canvas, Offset(topLeft.dx + ((width - painter.width) / 2), dy));
      dy += painter.height + lineSpacing;
    }
  }

  void paintCentered(Canvas canvas, Rect box) {
    paint(canvas, Offset(box.center.dx - (width / 2), box.center.dy - (height / 2)));
  }
}
