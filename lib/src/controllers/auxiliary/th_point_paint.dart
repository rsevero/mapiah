import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/types/mp_point_shape_type.dart';

class THPointPaint {
  final double radius;
  final MPPointShapeType type;
  final Paint? border;
  final Paint? fill;

  THPointPaint({
    this.radius = thDefaultPointRadius,
    this.type = MPPointShapeType.circle,
    this.border,
    this.fill,
  })  : assert(radius > 0, "Radius must be greater than 0"),
        assert((border != null) || (fill != null),
            "At least one of border or fill must be provided");

  THPointPaint copyWith({
    double? radius,
    MPPointShapeType? type,
    Paint? border,
    Paint? fill,
    bool makeBorderPaintNull = false,
    bool makeFillPaintNull = false,
  }) {
    return THPointPaint(
      radius: radius ?? this.radius,
      type: type ?? this.type,
      border: makeBorderPaintNull ? null : (border ?? this.border),
      fill: makeFillPaintNull ? null : (fill ?? this.fill),
    );
  }
}
