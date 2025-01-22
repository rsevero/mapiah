import 'dart:collection';
import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
class THStraightLineSegment extends THLineSegment with THHasOptions {
  THStraightLineSegment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required super.endPoint,
    required super.optionsMap,
  }) : super.forCWJM();

  THStraightLineSegment({
    required super.parentMapiahID,
    super.sameLineComment,
    required super.endPoint,
  }) : super.withEndPoint();

  @override
  THElementType get elementType => THElementType.straightLineSegment;

  THStraightLineSegment.fromString({
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> pointDataList,
  }) : super.withoutEndPoint() {
    endPoint = THPositionPart.fromStringList(list: pointDataList);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'endPoint': endPoint.toMap(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THStraightLineSegment.fromMap(Map<String, dynamic> map) {
    return THStraightLineSegment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      endPoint: THPositionPart.fromMap(map['endPoint']),
      optionsMap: LinkedHashMap<THCommandOptionType, THCommandOption>.from(
        map['optionsMap']
            .map((key, value) => MapEntry(key, THCommandOption.fromMap(value))),
      ),
    );
  }

  factory THStraightLineSegment.fromJson(String jsonString) {
    return THStraightLineSegment.fromMap(jsonDecode(jsonString));
  }

  @override
  THStraightLineSegment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    THPositionPart? endPoint,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
    bool makeSameLineCommentNull = false,
  }) {
    return THStraightLineSegment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      endPoint: endPoint ?? this.endPoint,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THStraightLineSegment other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.endPoint == endPoint &&
        other.optionsMap == optionsMap;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        endPoint,
        optionsMap,
      );

  @override
  bool isSameClass(Object object) {
    return object is THStraightLineSegment;
  }
}
