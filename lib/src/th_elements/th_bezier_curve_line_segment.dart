import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_line_segment.dart';
import 'package:mapiah/src/th_elements/th_parts/th_point_part.dart';

// [[LINE DATA] specify the coordinates of a Bézier curve arc:
// <c1x> <c1y> <c2x> <c2y> <x> <y>, where c indicates the control point.
class THBezierCurveLineSegment extends THElement
    with THHasOptions, THLineSegment {
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
}
