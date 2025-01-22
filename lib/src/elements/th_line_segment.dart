import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/auxiliary/th_point_interface.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
abstract class THLineSegment extends THElement
    implements THPointInterface, THHasOptions {
  late final THPositionPart endPoint;

  THLineSegment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
    required LinkedHashMap<String, THCommandOption> optionsMap,
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
  THElementType get elementType => THElementType.lineSegment;

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

  static THLineSegment fromMap(Map<String, dynamic> map) {
    final THElementType elementType =
        THElementType.values.byName(map['element']['elementType']);

    switch (elementType) {
      case THElementType.straightLineSegment:
        return THStraightLineSegment.fromMap(map['element']);
      case THElementType.bezierCurveLineSegment:
        return THBezierCurveLineSegment.fromMap(map['element']);
      default:
        throw Exception('Invalid THElementType: $elementType');
    }
  }

  @override
  THLineSegment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    THPositionPart? endPoint,
    LinkedHashMap<String, THCommandOption>? optionsMap,
    bool makeSameLineCommentNull = false,
  });
}
