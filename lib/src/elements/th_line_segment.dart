import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/elements/th_line.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
mixin THLineSegment on THElement implements THHasPLAType {
  late THPointPositionPart endPoint;

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

  double get endPointX {
    return endPoint.x.value;
  }

  double get endPointY {
    return endPoint.y.value;
  }

  set endPointX(double aValue) {
    endPoint.x.value = aValue;
  }

  set endPointY(double aValue) {
    endPoint.y.value = aValue;
  }

  int get endPointXDecimalPositions {
    return endPoint.x.decimalPositions;
  }

  int get endPointYDecimalPositions {
    return endPoint.y.decimalPositions;
  }

  set endPointXDecimalPositions(int aDecimalPositions) {
    endPoint.x.decimalPositions = aDecimalPositions;
  }

  set endPointYDecimalPositions(int aDecimalPositions) {
    endPoint.y.decimalPositions = aDecimalPositions;
  }
}
