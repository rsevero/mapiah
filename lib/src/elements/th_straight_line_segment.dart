import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

part 'th_straight_line_segment.mapper.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
@MappableClass()
class THStraightLineSegment extends THLineSegment
    with THStraightLineSegmentMappable, THHasOptions {
  // Used by dart_mappable.
  THStraightLineSegment.withExplicitParameters(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    super.endPoint,
    super.optionsMap,
  ) : super.notAddToParent();

  THStraightLineSegment(super.parent, super.endPoint) : super.addToParent();

  THStraightLineSegment.fromString(super.parent, List<dynamic> aPointDataList)
      : super() {
    endPoint = THPositionPart.fromStringList(aPointDataList);
  }

  @override
  bool isSameClass(THElement element) {
    return element is THStraightLineSegment;
  }
}
