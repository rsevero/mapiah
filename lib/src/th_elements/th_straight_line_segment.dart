import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_line_segment.dart';
import 'package:mapiah/src/th_elements/parts/th_point_part.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
class THStraightLineSegment extends THElement with THHasOptions, THLineSegment {
  THStraightLineSegment(super.parent, THPointPart aEndPoint)
      : super.withParent() {
    endPoint = aEndPoint;
  }

  THStraightLineSegment.fromString(super.parent, List<dynamic> aPointDataList)
      : super.withParent() {
    endPoint = THPointPart.fromStringList(aPointDataList);
  }
}
