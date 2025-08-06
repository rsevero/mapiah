import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';

class XVISketchLinePainter extends CustomPainter {
  final List<Offset> coordinates;
  final THLinePaint linePaint;
  final THPointPaint pointPaint;

  XVISketchLinePainter({
    required this.coordinates,
    required this.linePaint,
    required this.pointPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (linePaint.fillPaint != null) {
      paintLine(canvas, linePaint.fillPaint!);
    }

    if (linePaint.secondaryPaint != null) {
      paintLine(canvas, linePaint.secondaryPaint!);
    }

    if (linePaint.primaryPaint != null) {
      paintLine(canvas, linePaint.primaryPaint!);
    }
  }

  void paintLine(Canvas canvas, Paint paint) {
    if (coordinates.isEmpty) {
      return;
    }

    if (coordinates.length == 1) {
      MPInteractionAux.drawPoint(
        canvas: canvas,
        position: coordinates.first,
        pointPaint: pointPaint,
      );

      return;
    }

    for (int i = 1; i < coordinates.length; i++) {
      canvas.drawLine(coordinates[i - 1], coordinates[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant XVISketchLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    final listEquals = const ListEquality<Offset>().equals;

    if (!listEquals(coordinates, oldDelegate.coordinates)) return true;

    return linePaint != oldDelegate.linePaint;
  }
}
