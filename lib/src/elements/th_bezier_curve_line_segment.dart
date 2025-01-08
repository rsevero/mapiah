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
      THPointPositionPart endPoint)
      : super.withParent();

  THBezierCurveLineSegment.fromString(
      super.parent,
      List<dynamic> aControlPoint1List,
      List<dynamic> aControlPoint2List,
      List<dynamic> aEndPointList)
      : super.withParent() {
    controlPoint1 = THPointPositionPart.fromStringList(aControlPoint1List);
    controlPoint2 = THPointPositionPart.fromStringList(aControlPoint2List);
    endPoint = THPointPositionPart.fromStringList(aEndPointList);
  }

  double get controlPoint1X {
    return controlPoint1.x.value;
  }

  double get controlPoint1Y {
    return controlPoint1.y.value;
  }

  set controlPoint1X(double aValue) {
    controlPoint1.x.value = aValue;
  }

  set controlPoint1Y(double aValue) {
    controlPoint1.y.value = aValue;
  }

  int get controlPoint1XDecimalPositions {
    return controlPoint1.x.decimalPositions;
  }

  int get controlPoint1YDecimalPositions {
    return controlPoint1.y.decimalPositions;
  }

  set controlPoint1XDecimalPositions(int aDecimalPositions) {
    controlPoint1.x.decimalPositions = aDecimalPositions;
  }

  set controlPoint1YDecimalPositions(int aDecimalPositions) {
    controlPoint1.y.decimalPositions = aDecimalPositions;
  }

  double get controlPoint2X {
    return controlPoint2.x.value;
  }

  double get controlPoint2Y {
    return controlPoint2.y.value;
  }

  set controlPoint2X(double aValue) {
    controlPoint2.x.value = aValue;
  }

  set controlPoint2Y(double aValue) {
    controlPoint2.y.value = aValue;
  }

  int get controlPoint2XDecimalPositions {
    return controlPoint2.x.decimalPositions;
  }

  int get controlPoint2YDecimalPositions {
    return controlPoint2.y.decimalPositions;
  }

  set controlPoint2XDecimalPositions(int aDecimalPositions) {
    controlPoint2.x.decimalPositions = aDecimalPositions;
  }

  set controlPoint2YDecimalPositions(int aDecimalPositions) {
    endPoint.y.decimalPositions = aDecimalPositions;
  }
}
