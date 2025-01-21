import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
@serializable
class THStraightLineSegment extends THLineSegment
    with Dataclass<THStraightLineSegment>, THHasOptions {
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
  Map<String, dynamic> toMap() {
    return dogs.toNative<THStraightLineSegment>(this);
  }

  factory THStraightLineSegment.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THStraightLineSegment>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THStraightLineSegment>(this);
  }

  factory THStraightLineSegment.fromJson(String jsonString) {
    return dogs.fromJson<THStraightLineSegment>(jsonString);
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

  @override
  bool isSameClass(Object object) {
    return object is THStraightLineSegment;
  }
}
