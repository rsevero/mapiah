import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_has_platype.dart';
import 'package:mapiah/src/th_elements/th_line_segment.dart';
import 'package:mapiah/src/th_elements/parts/th_point_part.dart';

// [[LINE DATA] specify the coordinates of a Bézier curve arc:
// <c1x> <c1y> <c2x> <c2y> <x> <y>, where c indicates the control point.
class THBezierCurveLineSegment extends THElement
    with THHasOptions, THLineSegment
    implements THHasPLAType {
  late THPointPart controlPoint1;
  late THPointPart controlPoint2;

  THBezierCurveLineSegment(super.parent, this.controlPoint1, this.controlPoint2,
      THPointPart aEndPoint)
      : super.withParent() {
    endPoint = aEndPoint;
  }

  THBezierCurveLineSegment.fromString(
      super.parent,
      List<dynamic> aControlPoint1List,
      List<dynamic> aControlPoint2List,
      List<dynamic> aEndPointList)
      : super.withParent() {
    controlPoint1 = THPointPart.fromStringList(aControlPoint1List);
    controlPoint2 = THPointPart.fromStringList(aControlPoint2List);
    endPoint = THPointPart.fromStringList(aEndPointList);
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
