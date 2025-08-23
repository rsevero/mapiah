import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPScrapScalePainter extends CustomPainter {
  final double lengthUnits;
  final String scaleText;
  final double lengthUnitsPerScreenPoint;
  final Paint linePaint;
  final Color textColor;

  MPScrapScalePainter({
    required this.lengthUnits,
    required this.scaleText,
    required this.lengthUnitsPerScreenPoint,
    required this.linePaint,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = thGraphicalScalePadding;
    final double right = left + lengthUnits / lengthUnitsPerScreenPoint;
    final double bottom = size.height - thGraphicalScalePadding;

    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), linePaint);
    canvas.drawLine(
      Offset(left, bottom - thGraphicalScaleUptickLength),
      Offset(left, bottom),
      linePaint,
    );
    canvas.drawLine(
      Offset(right, bottom - thGraphicalScaleUptickLength),
      Offset(right, bottom),
      linePaint,
    );

    final TextSpan textSpan = TextSpan(
      text: scaleText,
      style: TextStyle(color: textColor, fontSize: 16),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(right + 10, bottom - textPainter.height + 3),
    );
  }

  @override
  bool shouldRepaint(covariant MPScrapScalePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return lengthUnits != oldDelegate.lengthUnits ||
        scaleText != oldDelegate.scaleText ||
        lengthUnitsPerScreenPoint != oldDelegate.lengthUnitsPerScreenPoint ||
        linePaint != oldDelegate.linePaint ||
        textColor != oldDelegate.textColor;
  }
}
