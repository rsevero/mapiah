import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';

part 'th_straight_line_segment.mapper.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
@MappableClass()
class THStraightLineSegment extends THElement
    with THStraightLineSegmentMappable, THLineSegment, THHasOptions {
  THStraightLineSegment(super.parent, THPointPositionPart endPointPosition)
      : super.addToParent() {
    this.endPointPosition = endPointPosition;
  }

  THStraightLineSegment.fromString(super.parent, List<dynamic> aPointDataList)
      : super.addToParent() {
    endPointPosition = THPointPositionPart.fromStringList(aPointDataList);
  }

  @override
  bool isSameClass(THElement element) {
    return element is THStraightLineSegment;
  }
}
