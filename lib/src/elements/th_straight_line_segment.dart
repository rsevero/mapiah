part of 'th_element.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
class THStraightLineSegment extends THLineSegment with THHasOptionsMixin {
  THStraightLineSegment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required super.endPoint,
    required super.optionsMap,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THStraightLineSegment({
    required super.parentMapiahID,
    super.sameLineComment,
    required super.endPoint,
    super.originalLineInTH2File = '',
  }) : super.withEndPoint();

  @override
  THElementType get elementType => THElementType.straightLineSegment;

  THStraightLineSegment.fromString({
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> pointDataList,
    super.originalLineInTH2File = '',
  }) : super.withoutEndPoint() {
    endPoint = THPositionPart.fromStringList(list: pointDataList);
  }

  factory THStraightLineSegment.fromMap(Map<String, dynamic> map) {
    return THStraightLineSegment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      endPoint: THPositionPart.fromMap(map['endPoint']),
      optionsMap: LinkedHashMap<THCommandOptionType, THCommandOption>.from(
        map['optionsMap'].map(
          (key, value) => MapEntry(
            THCommandOptionType.values.byName(key),
            THCommandOption.fromMap(value),
          ),
        ),
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
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    THPositionPart? endPoint,
    LinkedHashMap<THCommandOptionType, THCommandOption>? optionsMap,
  }) {
    return THStraightLineSegment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
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
