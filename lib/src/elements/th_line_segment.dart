import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/elements/th_line.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
mixin THLineSegment on THElement implements THHasPLAType, THPointInterface {
  late THPointPositionPart endPointPosition;

  @override
  set plaType(String lineType) {
    (parent as THLine).plaType = lineType;
  }

  @override
  String get plaType {
    return (parent as THLine).plaType;
  }

  @override
  String get elementType {
    return 'linesegment';
  }

  @override
  double get x {
    return endPointPosition.xDoublePart.value;
  }

  @override
  double get y {
    return endPointPosition.yDoublePart.value;
  }

  @override
  set x(double x) {
    endPointPosition.xDoublePart.value = x;
  }

  @override
  set y(double y) {
    endPointPosition.yDoublePart.value = y;
  }

  @override
  THDoublePart get xDoublePart {
    return endPointPosition.xDoublePart;
  }

  @override
  THDoublePart get yDoublePart {
    return endPointPosition.yDoublePart;
  }

  @override
  set xDoublePart(THDoublePart doublePart) {
    endPointPosition.xDoublePart = doublePart;
  }

  @override
  set yDoublePart(THDoublePart doublePart) {
    endPointPosition.yDoublePart = doublePart;
  }

  int get endPointXDecimalPositions {
    return endPointPosition.xDoublePart.decimalPositions;
  }

  int get endPointYDecimalPositions {
    return endPointPosition.yDoublePart.decimalPositions;
  }

  set endPointXDecimalPositions(int decimalPositions) {
    endPointPosition.xDoublePart.decimalPositions = decimalPositions;
  }

  set endPointYDecimalPositions(int decimalPositions) {
    endPointPosition.yDoublePart.decimalPositions = decimalPositions;
  }
}
