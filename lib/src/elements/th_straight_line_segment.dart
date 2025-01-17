import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
class THStraightLineSegment extends THLineSegment with THHasOptions {
  THStraightLineSegment({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required super.endPoint,
    required super.optionsMap,
  }) : super();

  THStraightLineSegment.addToParent({
    required super.parentMapiahID,
    super.sameLineComment,
    required super.endPoint,
  }) : super.withEndPoint();

  THStraightLineSegment.fromString({
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> pointDataList,
  }) : super.withoutEndPoint() {
    endPoint = THPositionPart.fromStringList(list: pointDataList);
  }

  @override
  THStraightLineSegment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    THPositionPart? endPoint,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THStraightLineSegment(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: sameLineComment ?? this.sameLineComment,
      endPoint: endPoint ?? this.endPoint,
      optionsMap: optionsMap ??
          LinkedHashMap<String, THCommandOption>.from(this.optionsMap),
    );
  }

  /// THStraightLineSegment does not need a toMap() method as all it's
  /// properties are already mapeed by THLineSegment.toMap();

  @override
  bool operator ==(covariant THStraightLineSegment other) {
    if (identical(this, other)) return true;

    return super == other &&
        endPoint == other.endPoint &&
        const MapEquality<String, THCommandOption>()
            .equals(optionsMap, other.optionsMap);
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        endPoint,
        Object.hashAll(optionsMap.entries),
      );

  @override
  bool isSameClass(Object object) {
    return object is THStraightLineSegment;
  }
}
