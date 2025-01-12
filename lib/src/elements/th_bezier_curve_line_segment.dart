import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';

part 'th_bezier_curve_line_segment.mapper.dart';

// [[LINE DATA] specify the coordinates of a Bézier curve arc:
// <c1x> <c1y> <c2x> <c2y> <x> <y>, where c indicates the control point.
@MappableClass()
class THBezierCurveLineSegment extends THElement
    with THBezierCurveLineSegmentMappable, THHasOptions, THLineSegment {
  late THPointPositionPart controlPoint1;
  late THPointPositionPart controlPoint2;

  THBezierCurveLineSegment(super.parent, this.controlPoint1, this.controlPoint2,
      THPointPositionPart endPointPosition)
      : super.addToParent();

  THBezierCurveLineSegment.fromString(super.parent, List<dynamic> controlPoint1,
      List<dynamic> controlPoint2, List<dynamic> endPointPosition)
      : super.addToParent() {
    this.controlPoint1 = THPointPositionPart.fromStringList(controlPoint1);
    this.controlPoint2 = THPointPositionPart.fromStringList(controlPoint2);
    this.endPointPosition =
        THPointPositionPart.fromStringList(endPointPosition);
  }

  double get controlPoint1X {
    return controlPoint1.xDoublePart.value;
  }

  double get controlPoint1Y {
    return controlPoint1.yDoublePart.value;
  }

  set controlPoint1X(double x) {
    controlPoint1.xDoublePart.value = x;
  }

  set controlPoint1Y(double y) {
    controlPoint1.yDoublePart.value = y;
  }

  int get controlPoint1XDecimalPositions {
    return controlPoint1.xDoublePart.decimalPositions;
  }

  int get controlPoint1YDecimalPositions {
    return controlPoint1.yDoublePart.decimalPositions;
  }

  set controlPoint1XDecimalPositions(int decimalPositions) {
    controlPoint1.xDoublePart.decimalPositions = decimalPositions;
  }

  set controlPoint1YDecimalPositions(int decimalPositions) {
    controlPoint1.yDoublePart.decimalPositions = decimalPositions;
  }

  double get controlPoint2X {
    return controlPoint2.xDoublePart.value;
  }

  double get controlPoint2Y {
    return controlPoint2.yDoublePart.value;
  }

  set controlPoint2X(double x) {
    controlPoint2.xDoublePart.value = x;
  }

  set controlPoint2Y(double y) {
    controlPoint2.yDoublePart.value = y;
  }

  int get controlPoint2XDecimalPositions {
    return controlPoint2.xDoublePart.decimalPositions;
  }

  int get controlPoint2YDecimalPositions {
    return controlPoint2.yDoublePart.decimalPositions;
  }

  set controlPoint2XDecimalPositions(int decimalPositions) {
    controlPoint2.xDoublePart.decimalPositions = decimalPositions;
  }

  set controlPoint2YDecimalPositions(int decimalPositions) {
    controlPoint2.yDoublePart.decimalPositions = decimalPositions;
  }
}
