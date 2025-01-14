import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/elements/th_line.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
mixin THLineSegment on THElement implements THHasPLAType, THPointInterface {
  late final THPositionPart endPointPosition;

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
    return endPointPosition.coordinates.dx;
  }

  @override
  double get y {
    return endPointPosition.coordinates.dy;
  }

  int get endPointDecimalPositions {
    return endPointPosition.decimalPositions;
  }

  set endPointDecimalPositions(int decimalPositions) {
    endPointPosition.decimalPositions = decimalPositions;
  }
}
