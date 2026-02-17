import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_segment.dart';

enum MPExtremityType { start, end }

abstract class MPBezierCurve {
  Offset get start;
  Offset get c1;
  Offset get c2;
  Offset get end;

  double length();
}

@immutable
class MPCubicBezierCurve extends MPSegment implements MPBezierCurve {
  const MPCubicBezierCurve({
    required super.start,
    required this.c1,
    required this.c2,
    required super.end,
  });

  @override
  final Offset c1;

  @override
  final Offset c2;

  @override
  double length() {
    return MPNumericAux.bezierArcLength(<Offset>[start, c1, c2, end], 1.0);
  }
}
