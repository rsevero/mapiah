import 'package:flutter/material.dart';

class THPointPaint {
  final double radius;
  final Paint? border;
  final Paint? fill;

  THPointPaint({
    required this.radius,
    this.border,
    this.fill,
  })  : assert(radius > 0, "Radius must be greater than 0"),
        assert((border != null) || (fill != null),
            "At least one of border or fill must be provided");
}
