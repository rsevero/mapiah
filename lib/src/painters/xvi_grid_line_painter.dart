import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';

class XVIGridLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final THLinePaint linePaint;

  XVIGridLinePainter(
      {required this.start, required this.end, required this.linePaint});

  @override
  void paint(Canvas canvas, Size size) {
    if (linePaint.fillPaint != null) {
      canvas.drawLine(start, end, linePaint.fillPaint!);
    }

    if (linePaint.secondaryPaint != null) {
      canvas.drawLine(start, end, linePaint.secondaryPaint!);
    }

    if (linePaint.primaryPaint != null) {
      canvas.drawLine(start, end, linePaint.primaryPaint!);
    }
  }

  @override
  bool shouldRepaint(covariant XVIGridLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return start != oldDelegate.start || end != oldDelegate.end;
  }
}
