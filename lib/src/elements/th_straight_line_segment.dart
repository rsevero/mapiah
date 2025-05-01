part of 'th_element.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
class THStraightLineSegment extends THLineSegment with THHasOptionsMixin {
  THStraightLineSegment.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.endPoint,
    required super.optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THStraightLineSegment({
    required super.parentMPID,
    super.sameLineComment,
    required super.endPoint,
    super.originalLineInTH2File = '',
  }) : super.withEndPoint();

  @override
  THElementType get elementType => THElementType.straightLineSegment;

  THStraightLineSegment.fromString({
    required super.parentMPID,
    super.sameLineComment,
    required List<dynamic> pointDataList,
    super.originalLineInTH2File = '',
  }) : super.withoutEndPoint() {
    endPoint = THPositionPart.fromStringList(list: pointDataList);
  }

  factory THStraightLineSegment.fromMap(Map<String, dynamic> map) {
    return THStraightLineSegment.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      endPoint: THPositionPart.fromMap(map['endPoint']),
      optionsMap: THHasOptionsMixin.optionsMapFromMap(map['optionsMap']),
    );
  }

  factory THStraightLineSegment.fromJson(String jsonString) {
    return THStraightLineSegment.fromMap(jsonDecode(jsonString));
  }

  @override
  THStraightLineSegment copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THPositionPart? endPoint,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
  }) {
    return THStraightLineSegment.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      endPoint: endPoint ?? this.endPoint,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THStraightLineSegment) return false;

    return equalsBase(other);
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        endPoint,
        optionsMap,
      );

  @override
  bool isSameClass(Object object) {
    return object is THStraightLineSegment;
  }

  @override
  Rect _calculateBoundingBox(Offset startPoint) {
    return MPNumericAux.orderedRectFromPoints(
      point1: startPoint,
      point2: endPoint.coordinates,
    );
  }
}
