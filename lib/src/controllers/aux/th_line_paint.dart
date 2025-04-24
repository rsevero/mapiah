import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

class THLinePaint {
  final Paint? primaryPaint;
  final Paint? secondaryPaint;
  final Paint? fillPaint;
  final MPLinePaintType type;

  THLinePaint({
    this.primaryPaint,
    this.secondaryPaint,
    this.fillPaint,
    this.type = MPLinePaintType.continuous,
  });
}
