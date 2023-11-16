import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_platype.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_parts/th_point_part.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
mixin THLineSegment on THElement implements THHasPLAType {
  late THPointPart endPoint;

  @override
  set plaType(String aLineType) {
    (parent as THLine).plaType = aLineType;
  }

  @override
  String get plaType {
    return (parent as THLine).plaType;
  }

  @override
  String get elementType {
    return 'linesegment';
  }

  double get x {
    return endPoint.x.value;
  }

  double get y {
    return endPoint.y.value;
  }

  set x(double aValue) {
    endPoint.x.value = aValue;
  }

  set y(double aValue) {
    endPoint.y.value = aValue;
  }

  int get xDecimalPositions {
    return endPoint.x.decimalPositions;
  }

  int get yDecimalPositions {
    return endPoint.y.decimalPositions;
  }

  set xDecimalPositions(int aDecimalPositions) {
    endPoint.x.decimalPositions = aDecimalPositions;
  }

  set yDecimalPositions(int aDecimalPositions) {
    endPoint.y.decimalPositions = aDecimalPositions;
  }
}
