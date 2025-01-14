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
  late final THPointPositionPart controlPoint1;
  late final THPointPositionPart controlPoint2;

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

  @override
  bool isSameClass(THElement element) {
    return element is THBezierCurveLineSegment;
  }

  double get controlPoint1X {
    return controlPoint1.position.dx;
  }

  double get controlPoint1Y {
    return controlPoint1.position.dy;
  }

  int get controlPoint1DecimalPositions {
    return controlPoint1.decimalPositions;
  }

  set controlPoint1DecimalPositions(int decimalPositions) {
    controlPoint1.decimalPositions = decimalPositions;
  }

  double get controlPoint2X {
    return controlPoint2.position.dx;
  }

  double get controlPoint2Y {
    return controlPoint2.position.dy;
  }

  int get controlPoint2DecimalPositions {
    return controlPoint2.decimalPositions;
  }

  set controlPoint2DecimalPositions(int decimalPositions) {
    controlPoint2.decimalPositions = decimalPositions;
  }
}
