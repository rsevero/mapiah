import 'dart:collection';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
abstract class THLineSegment extends THElement
    implements THPointInterface, THHasOptions {
  late final THPositionPart endPoint;

  THLineSegment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
    required LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
  }) : super.forCWJM() {
    addOptionsMap(optionsMap);
  }

  THLineSegment.withEndPoint({
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
  }) : super.addToParent();

  THLineSegment.withoutEndPoint({
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super.addToParent();

  @override
  String get elementType => thLineSegmentID;

  @override
  double get x {
    return endPoint.coordinates.dx;
  }

  @override
  double get y {
    return endPoint.coordinates.dy;
  }

  int get endPointDecimalPositions {
    return endPoint.decimalPositions;
  }
}
