import 'package:flutter/material.dart';

class THLinePaint {
  final Paint? primaryPaint;
  final Paint? secondaryPaint;
  final Paint? fillPaint;
  final LinePaintType type;

  THLinePaint({
    this.primaryPaint,
    this.secondaryPaint,
    this.fillPaint,
    this.type = LinePaintType.continuous,
  });
}

enum LinePaintType {
  continuous,
  dashed;
}
