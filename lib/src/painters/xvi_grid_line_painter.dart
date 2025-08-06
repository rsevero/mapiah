import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_paints.dart';

class XVIGridLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool vertical;

  XVIGridLinePainter(
      {required this.start, required this.end, this.vertical = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
        start, end, vertical ? THPaint.thPaint0 : THPaint.thPaintXVIGrid);
  }

  @override
  bool shouldRepaint(covariant XVIGridLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return start != oldDelegate.start || end != oldDelegate.end;
  }
}
