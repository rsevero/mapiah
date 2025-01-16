import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_line_segment.mapper.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
@MappableClass()
abstract class THLineSegment extends THElement
    with THLineSegmentMappable
    implements THPointInterface, THHasOptions {
  late final THPositionPart endPoint;

  // Used by dart_mappable.
  THLineSegment.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    this.endPoint,
    LinkedHashMap<String, THCommandOption> optionsMap,
  ) : super.notAddToParent() {
    addOptionsMap(optionsMap);
  }

  THLineSegment.withEndPoint(super.parentMapiahID, this.endPoint) : super();

  THLineSegment(super.parentMapiahID) : super();

  @override
  String get elementType {
    return 'linesegment';
  }

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

  set endPointDecimalPositions(int decimalPositions) {
    endPoint.decimalPositions = decimalPositions;
  }
}
