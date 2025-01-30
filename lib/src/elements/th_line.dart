part of 'th_element.dart';

// Description: Line is a command for drawing a line symbol on the map. Each line symbol
// is oriented and its visualization may depend on its orientation (e.g. pitch edge ticks). The
// general rule is that the free space is on the left, rock on the right. Examples: the lower
// side of a pitch, higher side of a chimney and interior of a passage are on the left side of
// pitch, chimney or wall symbols, respectively.
class THLine extends THElement
    with THHasOptionsMixin, THIsParentMixin
    implements THHasPLATypeMixin {
  late final String _lineType;
  Rect? _boundingBox;

  static final _lineTypes = <String>{
    'abyss-entrance',
    'arrow',
    'border',
    'ceiling-meander',
    'ceiling-step',
    'chimney',
    'contour',
    'dripline',
    'fault',
    'fixed-ladder',
    'floor-meander',
    'floor-step',
    'flowstone',
    'gradient',
    'handrail',
    'joint',
    'label',
    'low-ceiling',
    'map-connection',
    'moonmilk',
    'overhang',
    'pit',
    'pit-chimney',
    'pitch',
    'rimstone-dam',
    'rimstone-pool',
    'rock-border',
    'rock-edge',
    'rope',
    'rope-ladder',
    'section',
    'slope',
    'steps',
    'survey',
    'u',
    'via-ferrata',
    'walk-way',
    'wall',
    'water-flow',
  };

  THLine.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    required super.sameLineComment,
    required String lineType,
    required List<int> childrenMapiahID,
    required LinkedHashMap<String, THCommandOption> optionsMap,
    required super.originalLineInTH2File,
  })  : _lineType = lineType,
        super.forCWJM() {
    this.childrenMapiahID.addAll(childrenMapiahID);
    addOptionsMap(optionsMap);
  }

  THLine({
    required super.parentMapiahID,
    required String lineType,
    super.sameLineComment,
    super.originalLineInTH2File = '',
  })  : _lineType = lineType,
        super.addToParent();

  static bool hasLineType(String aLineType) {
    return _lineTypes.contains(aLineType);
  }

  @override
  THElementType get elementType => THElementType.line;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'lineType': _lineType,
      'childrenMapiahID': childrenMapiahID.toList(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THLine.fromMap(Map<String, dynamic> map) {
    return THLine.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      lineType: map['lineType'],
      childrenMapiahID: List<int>.from(map['childrenMapiahID']),
      optionsMap: LinkedHashMap<String, THCommandOption>.from(
        map['optionsMap']
            .map((key, value) => MapEntry(key, THCommandOption.fromMap(value))),
      ),
    );
  }

  factory THLine.fromJson(String jsonString) {
    return THLine.fromMap(jsonDecode(jsonString));
  }

  @override
  THLine copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? lineType,
    List<int>? childrenMapiahID,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THLine.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      lineType: lineType ?? _lineType,
      childrenMapiahID: childrenMapiahID ?? this.childrenMapiahID,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THLine other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other._lineType == _lineType &&
        deepEq(other.childrenMapiahID, childrenMapiahID) &&
        deepEq(other.optionsMap, optionsMap);
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        _lineType,
        childrenMapiahID,
        optionsMap,
      );

  @override
  bool isSameClass(Object object) {
    return object is THLine;
  }

  Rect getBoundingBox(THFile thFile) {
    _boundingBox ??= _calculateBoundingBox(thFile);

    return _boundingBox!;
  }

  Rect _calculateBoundingBox(THFile thFile) {
    if (childrenMapiahID.isEmpty) {
      return Rect.zero;
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    bool isFirst = true;
    Offset startPoint = Offset.zero;

    for (final int childMapiahID in childrenMapiahID) {
      final THElement child = thFile.elementByMapiahID(childMapiahID);

      if (child is! THLineSegment) {
        continue;
      }

      if (isFirst) {
        startPoint = child.endPoint.coordinates;
        isFirst = false;
      }

      final Rect childBoundingBox = child.getBoundingBox(startPoint);

      startPoint = child.endPoint.coordinates;

      if (childBoundingBox.left < minX) {
        minX = childBoundingBox.left;
      }
      if (childBoundingBox.right > maxX) {
        maxX = childBoundingBox.right;
      }
      if (childBoundingBox.top < minY) {
        minY = childBoundingBox.top;
      }
      if (childBoundingBox.bottom > maxY) {
        maxY = childBoundingBox.bottom;
      }
    }

    return MPNumericAux.orderedRectFromLTRB(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }

  String get lineType {
    return _lineType;
  }

  @override
  String get plaType {
    return lineType;
  }
}
